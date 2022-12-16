#!/bin/bash

function validateInput {
    # valid actions are to 'add' or 'remove' to the deniedNodesList

    local action=$1
    local validActions=("add" "remove")

    if [[ ! "$action" =~ $(echo ${validActions[*]} | tr ' ' '|') ]]; then
        echo "$action is not a valid option. Please select one of the follow: ${validActions[@]}"
        exit 1
    fi

}

function isConfigEmpty {
    # Dremio API URL, Username and Password are required for the Demio API.
    # These must be set as environment variables

    local configs="$@"

    for config in $configs
    do
        if [ $config == Null ]; then
            echo "Configuration not properly set."
            echo "Ensure that DREMIO_URL, DREMIO_USER, DREMIO_PASSWORD and PROMETHEUS_ENDPOINT are set as environment variables"
            exit 1
        fi
    done

}

function sendRequest {
    # Send a request to the Dremio API

    local url=$1
    local requestType=$2
    local authToken=$3
    local payload=$4

    payload=${payload:=Null}

    # TODO: figure out error handling for this
    local request=$(curl -S -s -X $requestType "$url" \
                         -H "Accept: application/json" \
                         -H "Content-Type:application/json" \
                         -H "Authorization: $authToken" \
                         -d $payload)
    echo $request

}

function getAuthToken {
    # Login to Dremio to receive an authentication token
    local baseUrl=$1
    local userName=$2
    local password=$3

    local payload="{\"userName\": \"$userName\", \"password\": \"$password\"}"

    local loginUrl="$baseUrl/apiv2/login"
    local loginOutput=$(curl -S -s -X POST "$loginUrl" \
                             -H "Accept: application/json" \
                             -H "Content-Type:application/json" \
                             -d "$payload")
    
    errorMessage=$(echo $loginOutput | grep -o '"errorMessage":"[^"]*' | grep -o '[^"]*$')
    if [[ ! -z "$errorMessage" ]]; then
        echo $errorMessage
        exit 1
    fi

    # Extract authentication token from login payload
    local token=$(echo $loginOutput | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

    echo $token

}

function getDeniedNodesList {
    # Retrieve nodesDeniedList from Dremio API
    # https://docs.dremio.com/software/rest-api/nodeCollections/view-denied-nodes/

    local aclUrl=$1
    local authToken=$2

    deniedNodesList=$(sendRequest $aclUrl "GET" $authToken)
    
    echo $deniedNodesList
    
}

function updateDeniedNodesList {
    # Send a POST to Dremio API to update deniedNodesList
    # https://docs.dremio.com/software/rest-api/nodeCollections/deny-nodes/

    local aclUrl=$1
    local authToken=$2
    local nodesDeniedList=$3

    updatedDeniedNodesList=$(sendRequest $aclUrl "POST" $authToken $nodesDeniedList)

    echo $updatedDeniedNodesList

}

function addNodeToDeniedNodesArray {
    # Add a node to the deniedNodesArray
    local newNode=$1
    shift
    local deniedNodesArray=("$@")

    # add new node to deniedNodesArray if it doesn't already exist
    if [[ ! "${deniedNodesArray[*]}" =~ "$newNode" ]]; then
        deniedNodesArray+=($newNode)
    fi

    echo ${deniedNodesArray[@]} 

}

function removeNodeFromDeniedNodesArray {
    # Remove a node from the deniedNodesArray

    local nodeToRemove=$1
    shift
    local deniedNodesArray="($@)"

    local output=()
    # build a new deniedNodesArray that excludes the nodeToRemove
    for node in ${deniedNodesArray[@]}; do
        # remove paranthesis
        nodeName=$(sed -e 's/(//' -e 's/)//' <<< $node)
        if [[ $nodeName != $nodeToRemove ]]; then
            output+=($nodeName) 
        fi
    done

    echo ${output[@]} 

}

function arrayAsArrayToString {
    # The deniedNodesList payload that is received from the Dremio API is a string.
    # This function converts an array into a string that can be accepted by the Dremio API.

    # replace spaces with commas
    local inputArray=("$@")
    local array=$(sed -e 's/ /,/g' <<< ${inputArray[@]})
    local arrayAsString="[$array]"

    echo $arrayAsString

}

function arrayAsStringToArray {
    # The deniedNodesList payload that is received from the Dremio API is a string.
    # This function converts deniedNodesList from a string to a Bash array for easy manipulation.

    local deniedNodesList=$1

    # strip brackets from deniedNodeList string
    deniedNodesList=$(sed -e 's/\[//g' -e 's/\]//g' <<< $deniedNodesList)
    
    # split nodeList string on commas and covert the string to an array
    local deniedNodesArray=($(echo $deniedNodesList | tr "," "\n"))

    echo ${deniedNodesArray[@]} 
    
}

function getActiveFragments {

    local nodeLocalIp=$1:9010
    local prometheusQueryEndpoint=$2
    local fragmentActiveQuery="fragments_active{instance=\"$nodeLocalIp\"}"

    # TODO: need error handling in case that value doesn't exist. aka no query results
    request=$(curl -S -s -g $prometheusQueryEndpoint?query=$fragmentActiveQuery)
    numActiveFragments=$(echo $request | sed -e 's/.*value":.//' | awk -F '"' '{print $2}')
    echo $numActiveFragments

}
function pollPrometheusActiveFragments {

    # will need to append prom ip port
    local nodeLocalIp="$1:9010"
    local prometheusQueryEndpoint=$2
    # initialize numActiveFragments
    local numActiveFragments=$(getActiveFragments $nodeLocalIp $prometheusQueryEndpoint)
    while [ $numActiveFragments -gt 0 ]
    do
        numActiveFragments=$(getActiveFragments $nodeLocalIp $prometheusQueryEndpoint)
        echo $numActiveFragments
    done

}

function main {
     
    local action=$1
    local baseUrl="${DREMIO_URL:-Null}"
    local userName="${DREMIO_USER:-Null}"
    local password="${DREMIO_PASSWORD:-Null}"
    local prometheusEndpoint="${PROMETHEUS_ENDPOINT:-Null}"
    local prometheusQueryEndpoint="$prometheusEndpoint/api/v1/query"

    local currentNodeHostname=\"$(hostname --fqdn)\"    
    local currentNodeLocalIp=$(hostname -I)

    validateInput $action
    isConfigEmpty $baseUrl $userName $password $prometheusEndpoint

    local aclUrl="$baseUrl/api/v3/nodeCollections/blacklist"

    # Login to dremio and retrieve authorization token. User must be a Dremio Admin
    local authToken=$(getAuthToken $baseUrl $userName $password)
    local deniedNodesList=$(getDeniedNodesList $aclUrl $authToken)
    local deniedNodesArray=$(arrayAsStringToArray $deniedNodesList)

    if [ $action == "remove" ]; then
        local deniedNodesArray=$(removeNodeFromDeniedNodesArray $currentNodeHostname ${deniedNodesArray[@]})
        local updatedDeniedNodesList=$(arrayAsArrayToString ${deniedNodesArray[@]})
        local finalList=$(updateDeniedNodesList $aclUrl $authToken $updatedDeniedNodesList)
        echo $finalList
    else
        local deniedNodesArray=$(addNodeToDeniedNodesArray $currentNodeHostname ${deniedNodesArray[@]})
        local updatedDeniedNodesList=$(arrayAsArrayToString ${deniedNodesArray[@]})
        local finalList=$(updateDeniedNodesList $aclUrl $authToken $updatedDeniedNodesList)
        echo $finalList
        pollPrometheusActiveFragments $currentNodeLocalIp $prometheusQueryEndpoint
    fi

    exit 0

}

while getopts a: flag
do
    case "${flag}" in
        a) action=${OPTARG};;
        ?) echo "Please use the '-a' option with either 'add' or 'remove'";
           exit 1;;
    esac
done

main $action
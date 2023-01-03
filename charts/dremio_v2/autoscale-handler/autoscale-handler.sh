#!/bin/bash

trap "exit 1" 10
CURRENT_PROCESS="$$"

function fatalError {
    # This function will echo an error message and kill the parent process

    echo "$@" >&2
    kill -10 $CURRENT_PROCESS

}

function validateInput {
    # Validate 'action' user input. Valid inputs are to 'add' or 'remove' to the deniedNodesList

    local action=$1
    local validActions=("add" "remove")

    if [[ ! "${action}" =~ $(echo ${validActions[*]} | tr ' ' '|') ]]; then
        fatalError "$action is not a valid option. Please select one of the following: ${validActions[@]}"
    fi

}

function isConfigEmpty {
    # Dremio API URL, Username and Password are required for the Demio API.
    # Promethes URL is required to query for active fragments
    # These must be set as environment variables

    local configs="$@"

    for config in ${configs[@]}
    do
        if [ ${config} == "Null" ]; then
            errorMessage="Configuration not properly set.
                          Ensure that DREMIO_URL, DREMIO_USER, DREMIO_PASSWORD and PROMETHEUS_ENDPOINT
                          are set as environment variables"
            fatalError ${errorMessage}
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

    local request=$(curl -S -s -X ${requestType} "${url}" \
                         -H "Accept: application/json" \
                         -H "Content-Type:application/json" \
                         -H "Authorization: ${authToken}" \
                         -d ${payload})

    if [[ -z "${request}" ]]; then
        fatalError "Failed to send request to the Dremio API."
    fi

    errorMessage=$(echo ${request} | grep -o '"errorMessage":"[^"]*' | grep -o '[^"]*$')
    if [[ ! -z "${errorMessage}" ]]; then
        fatalError ${errorMessage}
    fi

    echo ${request}

}

function getAuthToken {
    # Login to Dremio to receive an authentication token
    # https://docs.dremio.com/software/rest-api/overview/#authentication
    local baseUrl=$1
    local userName=$2
    local password=$3

    local payload="{\"userName\": \"${userName}\", \"password\": \"${password}\"}"

    local loginUrl="${baseUrl}/apiv2/login"
    local loginOutput=$(curl -S -s -X POST "${loginUrl}" \
                             -H "Accept: application/json" \
                             -H "Content-Type:application/json" \
                             -d "${payload}")

    errorMessage=$(echo ${loginOutput} | grep -o '"errorMessage":"[^"]*' | grep -o '[^"]*$')
    if [[ ! -z "${errorMessage}" ]]; then
        fatalError ${errorMessage}
    fi

    # Extract authentication token from login payload
    local token=$(echo ${loginOutput} | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

    echo ${token}

}

function getDeniedNodesList {
    # Retrieve nodesDeniedList from Dremio API
    # https://docs.dremio.com/software/rest-api/nodeCollections/view-denied-nodes/

    local aclUrl=$1
    local authToken=$2

    deniedNodesList=$(sendRequest ${aclUrl} "GET" ${authToken})

    echo ${deniedNodesList}

}

function updateDeniedNodesList {
    # Send a POST to Dremio API to update deniedNodesList
    # https://docs.dremio.com/software/rest-api/nodeCollections/deny-nodes/

    local aclUrl=$1
    local authToken=$2
    local nodesDeniedList=$3

    updatedDeniedNodesList=$(sendRequest ${aclUrl} "POST" ${authToken} ${nodesDeniedList})

    echo ${updatedDeniedNodesList}

}

function addNodeToDeniedNodesArray {
    # Add a node to the deniedNodesArray

    local newNode=$1
    shift
    local deniedNodesArray=("$@")

    # add new node to deniedNodesArray if it doesn't already exist
    if [[ ! "${deniedNodesArray[*]}" =~ "${newNode}" ]]; then
        deniedNodesArray+=(${newNode})
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
    for ${node} in ${deniedNodesArray[@]}; do
        # remove paranthesis
        local nodeName=$(sed -e 's/(//' -e 's/)//' <<< $node)
        if [[ ${nodeName} != ${nodeToRemove} ]]; then
            output+=(${nodeName})
        fi
    done

    echo ${output[@]}

}

function arrayAsArrayToString {
    # The deniedNodesList payload that is received from the Dremio API is a string.
    # This function converts an array into a string that can be accepted by the Dremio API.

    local inputArray=("$@")
    # replace spaces with commas
    local array=$(sed -e 's/ /,/g' <<< ${inputArray[@]})
    local arrayAsString="[${array}]"

    echo ${arrayAsString}

}

function arrayAsStringToArray {
    # The deniedNodesList payload that is received from the Dremio API is a string.
    # This function converts deniedNodesList from a string to a Bash array for easy manipulation.

    local deniedNodesList=$1

    # remove square brackets from deniedNodeList string
    deniedNodesList=$(sed -e 's/\[//g' -e 's/\]//g' <<< ${deniedNodesList})

    # split nodeList string on commas and covert the string to an array
    local deniedNodesArray=($(echo ${deniedNodesList} | tr "," "\n"))

    echo ${deniedNodesArray[@]}

}

function getActiveFragments {
    # Query Prometheus for fragments_active for a host by IP address

    local nodeLocalIp=$1
    local prometheusPort=$2
    local prometheusQueryEndpoint=$3
    local fragmentActiveQuery="fragments_active{instance=\"${nodeLocalIp}:${prometheusPort}\"}"

    request=$(curl -S -s -g ${prometheusQueryEndpoint}?query=${fragmentActiveQuery})

    if [[ "${request}" != *"value"* ]]; then
        fatalError "No results recevied from Prometheus. Prometheus Query: ${fragmentActiveQuery}"
    fi

    numActiveFragments=$(echo $request | sed -e 's/.*value":.//' | awk -F '"' '{print $2}')

    echo $numActiveFragments

}

function pollPrometheusActiveFragments {
    # Poll Prometheus for fragments_active (running queries)

    local nodeLocalIp=$1
    local prometheusPort=$2
    local prometheusQueryEndpoint=$3
    local prometheusQueryWaitTimeInSeconds=$4
    local prometheusQueryMaxRetries=$5

    # initialize numActiveFragments
    local numActiveFragments=$(getActiveFragments ${nodeLocalIp} ${prometheusPort} ${prometheusQueryEndpoint})

    while [ ${numActiveFragments} -gt 0 ]
    do
        if [[ prometheusQueryMaxRetries -eq 0 ]]
        then
            fatalError "Max retries exceeded while waiting for queries to complete."
        else
            numActiveFragments=$(getActiveFragments ${nodeLocalIp} ${prometheusPort} ${prometheusQueryEndpoint})
            prometheusQueryMaxRetries=$((${prometheusQueryMaxRetries} - 1))
            sleep ${prometheusQueryWaitTimeInSeconds}
        fi
    done

}

function main {

    local action=$1
    local baseUrl="${DREMIO_URL:-"Null"}"
    local userName="${DREMIO_USER:-"Null"}"
    local password="${DREMIO_PASSWORD:-"Null"}"

    local prometheusEndpoint="${PROMETHEUS_ENDPOINT:-"Null"}"
    local prometheusPort="${PROMETHEUS_PORT:-9010}"
    local prometheusQueryEndpoint="${prometheusEndpoint}/api/v1/query"
    local prometheusQueryWaitTimeInSeconds="${PROMETHEUS_WAIT_TIME:-5}"
    local prometheusQueryMaxRetries="${PROMETHEUS_QUERY_MAX_RETRIES:-1000}"

    local currentNodeHostname=\"$(hostname --fqdn)\"
    local currentNodeLocalIp=$(hostname -I)

    validateInput ${action}
    isConfigEmpty ${baseUrl} ${userName} ${password} ${prometheusEndpoint}

    local aclUrl="${baseUrl}/api/v3/nodeCollections/blacklist"

    # Login to dremio and retrieve authorization token. User must be a Dremio Admin
    local authToken=$(getAuthToken ${baseUrl} ${userName} ${password})
    local deniedNodesList=$(getDeniedNodesList ${aclUrl} ${authToken})
    local deniedNodesArray=$(arrayAsStringToArray ${deniedNodesList})

    if [ ${action} == "remove" ]; then
        local deniedNodesArray=$(removeNodeFromDeniedNodesArray ${currentNodeHostname} ${deniedNodesArray[@]})
        local updatedDeniedNodesList=$(arrayAsArrayToString ${deniedNodesArray[@]})
        local finalList=$(updateDeniedNodesList $aclUrl $authToken $updatedDeniedNodesList)
        echo ${finalList}
    else
        local deniedNodesArray=$(addNodeToDeniedNodesArray ${currentNodeHostname} ${deniedNodesArray[@]})
        local updatedDeniedNodesList=$(arrayAsArrayToString ${deniedNodesArray[@]})
        local finalList=$(updateDeniedNodesList ${aclUrl} ${authToken} ${updatedDeniedNodesList})
        echo ${finalList}
        pollPrometheusActiveFragments ${currentNodeLocalIp} ${prometheusPort} ${prometheusQueryEndpoint} \
                                      ${prometheusQueryWaitTimeInSeconds} ${prometheusQueryMaxRetries}

    fi

    exit 0

}

while getopts a: flag
do
    case "${flag}" in
        a) action=${OPTARG};;
        ?) echo "Please use the '-a' option with either 'add' or 'remove'";
           exit 2;;
    esac

done

main ${action}
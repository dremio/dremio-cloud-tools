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
            echo "Ensure that DREMIO_URL, DREMIO_USER and DREMIO_PASSWORD are set as environment variables"
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

    local deniedNodesArray=$1
    local newNode=$2

    # add new node to deniedNodesArray if it doesn't already exist
    if [[ ! "${deniedNodesArray[*]}" =~ "$newNode" ]]; then
        deniedNodesArray+=($newNode)
    fi

    echo ${deniedNodesArray[@]} 

}

function removeNodeFromDeniedNodesArray {
    # Remove a node from the deniedNodesArray

    local deniedNodesArray=$1
    local nodeToRemove=$2
    local output=()

    # build a new deniedNodesArray that excludes the nodeToRemove
    for node in ${deniedNodesArray[@]}; do
        if [[ $node != $nodeToRemove ]]; then
            output+=($node) 
        fi
    done

    echo ${output[@]} 

}

function arrayAsArrayToString {
    # The deniedNodesList payload that is received from the Dremio API is a string.
    # This function converts an array into a string that can be accepted by the Dremio API.

    local array=("$@")

    # replace spaces with commas
    local output=$(sed -e 's/ /,/g' <<< ${array[@]})

    local output="[$output]"

    echo $output

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

function main {
     
    local action=$1
    local baseUrl="${DREMIO_URL:-Null}"
    local userName="${DREMIO_USER:-Null}"
    local password="${DREMIO_PASSWORD:-Null}"
    # # TODO: doesn't work on Mac so re-enable once testing in kube
    # local currentNodeHostname=\"$(hostname --fqdn)\"
    local currentNodeHostname=\"dremio-executor-1.dremio-cluster-pod.dx-58905.svc.cluster.local\"

    validateInput $action
    isConfigEmpty $baseUrl $userName $password

    local aclUrl="$baseUrl/api/v3/nodeCollections/blacklist"

    # Login to dremio and retrieve authorization token. User must be a Dremio Admin
    local authToken=$(getAuthToken $baseUrl $userName $password)

    local deniedNodesList=$(getDeniedNodesList $aclUrl $authToken)
    echo $deniedNodesList
    local deniedNodesArray=$(arrayAsStringToArray $deniedNodesList)

    # if [ $action == "remove" ]; then
    #     local deniedNodesArray=$(removeNodeFromDeniedNodesArray $deniedNodesArray $currentNodeHostname)
    # else
    #     local deniedNodesArray=$(addNodeToDeniedNodesArray $deniedNodesArray $currentNodeHostname)
    # fi

    # local updatedDeniedNodesList=$(arrayAsArrayToString $deniedNodesArray)
    
    # local finalList=$(updateDeniedNodesList $aclUrl $authToken $updatedDeniedNodesList)
    echo $finalList

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
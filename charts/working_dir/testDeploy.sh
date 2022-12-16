#!/bin/bash

time=$(date +%s)
image="gcr.io/dremio-1093/dremio-ee"
imageTag="bngo-$time"

docker build --no-cache -t "$image:$imageTag" . 
docker push "$image:$imageTag"
helm upgrade bngo-1 /Users/brianngo/Documents/dremio-home/dremio-cloud-tools/charts/dremio_v2/ -f /Users/brianngo/Documents/dremio-home/dremio-cloud-tools/charts/dremio_v2/values.yaml --set imageTag=$imageTag
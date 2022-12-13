#!/bin/bash

docker build --no-cache -t gcr.io/dremio-1093/dremio-ee:bngo-1213-$1 . 
docker push gcr.io/dremio-1093/dremio-ee:bngo-1213-$1
helm upgrade bngo-1 /Users/brianngo/Documents/dremio-home/dremio-cloud-tools/charts/dremio_v2/ -f /Users/brianngo/Documents/dremio-home/dremio-cloud-tools/charts/dremio_v2/values.yaml
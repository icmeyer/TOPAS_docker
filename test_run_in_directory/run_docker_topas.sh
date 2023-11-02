#!/bin/bash
if [ $# -eq 1 ]; then
    docker run --rm -it -v $(pwd):/root/topas_run_temp topas_3_9 bash /root/run_topas_on_container.sh $1
else
    echo "Must pass TOPAS parameter file as argument"
fi

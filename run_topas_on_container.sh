#!/bin/bash
cd /root/topas_run_temp
echo $(pwd)
echo $(ls)
if [ $# -eq 1 ]; then
    topas $1 | tee "$1.out"
else
    echo "Must pass TOPAS parameter file as argument"
fi

#!/bin/bash

set -u

echo -n "   now waiting for postprocessing jobs to finish:"

finished=0
while (( ! finished ))
do
    finished=1
    for (( proc = 0; proc < ${NPOST}; ++proc ))
    do
        if [ -z "${jobid_post[$proc]}" ]; then
            continue
        fi
        answer=`squeue --job ${jobid_post[$proc]} 2>/dev/null | tail -1 | awk '{print $5}'`
        if [ -z "${answer}" -o "${answer}" == "ST" ]; then
            jobid_post[$proc]=
            echo -n ".. post .. ${proc}"
        else
            echo -n "."
            finished=0
            sleep ${MONITORINTERVAL}
        fi
    done
done

echo " postprocess done"

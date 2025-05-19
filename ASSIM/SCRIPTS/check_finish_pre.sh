#!/bin/bash

set -u

echo -n "   now waiting for all preprocessing jobs to finish:"

finished=0
while (( ! finished ))
do
    finished=1
    for (( proc = 0; proc < ${NPRE}; ++proc ))
    do
        if [ -z "${jobid_pre[$proc]}" ]; then
            continue
        fi
        answer=`squeue --job ${jobid_pre[$proc]} 2>/dev/null | tail -1 | awk '{print $5}'`
        sleep ${MONITORINTERVAL}
        if [ -z "${answer}" -o "${answer}" == "ST" ]; then
            echo -n "."${proc}
        else
            echo -n "."
            finished=0
            sleep ${MONITORINTERVAL}
        fi
    done
done

echo " done: " `date`

#!/bin/bash

echo -n "   waiting until ${jobid_clean} finish:"

answer=`squeue --job ${jobid_clean} 2>/dev/null | tail -1 | awk '{print $5}'`

while [ -n "${answer}" -a "${answer}" != "ST" ]; do
    echo -n ".. cleanup .."
    sleep ${MONITORINTERVAL}
    answer=`squeue --job ${jobid_clean} 2>/dev/null | tail -1 | awk '{print $5}'`
done


#!/bin/bash

answer=`squeue --job ${jobid_enkf} 2>/dev/null | tail -1 | awk '{print $5}'`

while [ -n "${answer}" -a "${answer}" != "ST" ]
do
   echo -n "."
   sleep ${MONITORINTERVAL}
   answer=`squeue --job ${jobid_enkf} 2>/dev/null | tail -1 | awk '{print $5}'`
   if [ -r break.out ]; then
      answer="C"
      echo "exit!"
      exit
   fi
done

status=`cat ${ANALYSISDIR}/enkf_0.out | grep EnKF: | grep -c Finished`

if (( ${status} != ${NPROC} ))
then
   echo
   echo "ERROR: EnKF has not finished"
   echo
   exit 1
else
   echo "   EnKF finished"
fi

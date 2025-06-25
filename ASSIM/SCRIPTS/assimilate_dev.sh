#!/bin/bash

set -e # exit on error
set -u # exit on unset variables
set -p # nothing is inherited from the shell
#set -x

echo ""
echo " -- assimilate.sh"
echo ""

MONITORINTERVAL=10 # time interval for periodic checks on job status
MONITORINTERVAL2=30 # time interval for periodic checks on job status
LAUNCHINTERVAL=5 # time interval for launching parallel jobs
nre=0 # number of members reassembled

#
# 1. Read and report specifications for the assimilation
#
echo "  1. Reading specifications and checking configuration:"
echo "   source assimilation_specs.sh"
source assimilation_specs.sh

export ANALYSISDIR BINDIR RESULTSDIR JULDAY ENSSIZE NPROC FORECASTDIR BACKUPBUFDIR MODELDIR HYCOMPREFIX PREPOBSDIR OUTPUTDIR NESTINGDIR OBSDIR ROOTDIR

echo "   JULDAY = ${JULDAY}"

# clean up
#
rm -rf ${ANALYSISDIR} ${PREPOBSDIR}
mkdir ${ANALYSISDIR}

echo "   Data types:"
for datatype in $OBSTYPES
do
    echo "     $datatype"
done


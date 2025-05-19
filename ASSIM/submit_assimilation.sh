#!/bin/bash
#
# package for submitting assimilation job
#
set -euo pipefail

rfactor=$1
gdaynow=$2
jdaynow=$3
jdaynxt=$4
JULDAYSTART=$5
var=$6

source ../common_specs.sh
enssize=$ENSSIZE

cat ./FILES/enkf.in |\
        awk -f SCRIPTS/setparameter.awk -v PRM=rfactor1 -v VAL=${rfactor} |\
        awk -f SCRIPTS/setparameter.awk -v PRM=enssize -v VAL=${enssize} \
        > enkf.prm

echo " "
echo "  -- perform ${var} assimilation at ${gdaynow}"
echo " "
[ -f assimilation_specs.sh ] && rm assimilation_specs.sh
cat ../common_specs.sh             >> assimilation_specs.sh
echo " "                           >> assimilation_specs.sh
echo "JULDAY=${jdaynow}"           >> assimilation_specs.sh
echo "JULDAYNXT=${jdaynxt}"        >> assimilation_specs.sh
echo "JULDAYSTART=${JULDAYSTART}"  >> assimilation_specs.sh
echo "CWD="`pwd`                   >> assimilation_specs.sh
cat assimilation_specs_${var,,}.in >> assimilation_specs.sh

[ -f analysisfields.in ] && rm analysisfields.in
cat FILES/analysisfields_${var,,}.in >> analysisfields.in

bash ./SCRIPTS/assim_test.sh
#./SCRIPTS/assimilate_dev.sh
# ./SCRIPTS/assimilate.sh

exit

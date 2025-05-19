#!/bin/bash
#
# package to submit propagation job
#
set -euo pipefail

gdaynow=$1
gdaynxt=$2
jdaynow=$3
jdaynxt=$4
JULDAYSTART=$5

echo " "
echo "  -- perform propagation from ${gdaynow} to ${gdaynxt}"
echo " "

[ -f propagation_specs.sh ] &&    rm propagation_specs.sh
cat ../common_specs.sh            >> propagation_specs.sh
echo " "                          >> propagation_specs.sh
echo "JULDAY=${jdaynow}"          >> propagation_specs.sh
echo "JULDAYNXT=${jdaynxt}"       >> propagation_specs.sh
echo "JULDAYSTART=${JULDAYSTART}" >> propagation_specs.sh
echo "CWD="`pwd`                  >> propagation_specs.sh

#./SCRIPTS/propagate_sr.sh

exit

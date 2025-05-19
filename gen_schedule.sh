#!/bin/bash
#
# gen_schedule.sh
#
#
set -u

ynow=$1            # target year     [YYYY]
yold=$((ynow - 1)) # target year - 1 [YYYY]
ynxt=$((ynow + 1)) # target year + 1 [YYYY]
interval=7         # cycle interval  [day]

output=schedule/cycle_${ynow}.txt
mkdir -p schedule

[ -f $output ] && rm $output

HYCOMDAYORIGIN='1950 1 1' # do not remove

PHYASSIMGDAY0="$yold 9 1"  # PHY assimilation starts from September 1
BIOASSIMGDAY0="$ynow 1 1"  # BGC assimilation starts from January 1
CYCLEENDGDAY="$ynxt 1 1"   # Cycle ends after forecasting to January 1 in next year

source common_specs.sh

PHYASSIMJDAY0=$(BIN/datetojul $PHYASSIMGDAY0 $HYCOMDAYORIGIN)
BIOASSIMJDAY0=$(BIN/datetojul $BIOASSIMGDAY0 $HYCOMDAYORIGIN)
CYCLEENDJDAY=$(BIN/datetojul $CYCLEENDGDAY $HYCOMDAYORIGIN)

echo "--------------------------------------"
echo "   PHY DA starts at $PHYASSIMGDAY0"
echo "   BGC DA starts at $BIOASSIMGDAY0"
echo " PHY/BGC DA ends at $CYCLEENDGDAY"
echo "--------------------------------------"

maxcycle=500

ncycle=0
JDAYNOW=$PHYASSIMJDAY0
bioassimstart="true"
DATYPE=PHYDA

while (( ncycle < maxcycle )); do
    ((ncycle++))

    if (( $ncycle <= 9 )); then
	RFACTOR=8
    elif (( $ncycle <= 16 )); then
	RFACTOR=4
    elif (( $ncycle <= 21 )); then
        RFACTOR=2
    else
        RFACTOR=1
    fi

    # set DA type

    if [ $JDAYNOW -lt $BIOASSIMJDAY0 ]; then
	DAYTPE=PHYDA  # Physics only
    else
	DATYPE=WCPLD  # Physics only (PHYDA) + Biogeochemistry only (BGCDA)
    fi
    
    # set current starting day
    
    GDAYNOW=$(BIN/jultodate $JDAYNOW $HYCOMDAYORIGIN)
    
    # set next starting day

    JDAYNXT=$(( JDAYNOW + interval))

    # apply adjustment in inerval before January 1st.
    
    if [ $JDAYNXT -ge $BIOASSIMJDAY0 ] && [ "$bioassimstart" == "true" ]; then
	JDAYNXT=$BIOASSIMJDAY0
	bioassimstart="false"
    fi
    if [ $JDAYNXT -ge $CYCLEENDJDAY ]; then
	JDAYNXT=$CYCLEENDJDAY
	maxcycle=$ncycle
    fi
    
    GDAYNXT=$(BIN/jultodate $JDAYNXT $HYCOMDAYORIGIN)

    # save analysis schedule to external file
    
    echo $ncycle $JDAYNOW $JDAYNXT $GDAYNOW $GDAYNXT $RFACTOR $DATYPE
    echo $ncycle $JDAYNOW $JDAYNXT $GDAYNOW $GDAYNXT $RFACTOR $DATYPE >> $output
    
    JDAYNOW=$JDAYNXT
done

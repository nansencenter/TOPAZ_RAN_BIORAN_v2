#!/bin/bash
#
# gen_obs.sh
#
# This the top level script for run prepobs over analysis cycles
#
set -euo pipefail

datypes=("PHYDA" "BGCDA" "WCPLD") # leave this for later use to check valid DA type

ynow=$1
idini=$2
idend=$3
config=TP2

PREOBSDIR=preobs_bgc

schedule_file=schedule/cycle_${ynow}.txt

if [ ! -f ${schedule_file} ]; then
    echo "Can not fine ${schedule_file}. Run:"
    echo " bash gen_schedule.sh $ynow" 
    echo "first. EIXT"
    exit
fi    

# Read the first line of a schedule file
read -r first_line < ${schedule_file}
IFS=' ' read -r -a fields <<< "$first_line"
JULDAYSTART="${fields[1]}"

echo "JULDAYSTART=$JULDAYSTART"

#source common_specs.sh # configure folder structure
#./SCRIPTS/check_directories.sh

while read -r line; do
    read -ra vars <<< "$line"

    cycleid="${vars[0]}" # cycle ID
    jdaynow="${vars[1]}" # Julian date (refrenced to 1950 1 1) at start
    jdaynxt="${vars[2]}" # Julian date (refrenced to 1950 1 1) at end
    gdaynow="${vars[3]}" # Gregotian date [YYYYMMDD] at start
    gdaynxt="${vars[4]}" # Gregotian date [YYYYMMDD] at end
    rfactor="${vars[5]}" # EnKF R factor
    datype="${vars[-1]}" # type of DA [PHYDA/BGCDA/WCPLD/(SCPLD)/NODA]

    if [ "$cycleid" -ge "$idini" ] && [ "$cycleid" -le "$idend" ]; then
	echo ""	
        echo "-----------------------------------------"
        echo "${vars[@]}"
        echo "-----------------------------------------"

    #-- run prepobs

    if [ ! "$datype" == "NODA" ]; then # only ensemble propagation
	cd $PREOBSDIR

        #-- perform PHY DA
        if [ "$datype" == "PHYDA" ] || [ "$datype" == "WCPLD" ]; then # PHYDA or WCPLD
	   #-- SST
           echo "bash prep_OSTIA_SST.sh   $gdaynow $config"
	   bash prep_OSTIA_SST.sh $gdaynow $config
	   #-- ICEC
           echo "bash prep_OSISAF_ICEC.sh $gdaynow $config"
	   bash prep_OSISAF_ICEC.sh $gdaynow $config
	fi
	
        #-- perform BGC DA
        if [ "$datype" == "BGCDA" ] || [ "$datype" == "WCPLD" ]; then # BGCDA or WCPLD
	   #-- SCHL
           echo "bash prep_ESACCI_SCHL.sh $gdaynow $config"
	   bash prep_ESACCI_SCHL.sh $gdaynow $config
	fi   
    fi
	
	cd ..
    fi	
    
done < ${schedule_file}

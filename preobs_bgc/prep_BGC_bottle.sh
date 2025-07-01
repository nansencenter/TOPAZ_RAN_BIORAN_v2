#!/bin/bash

# preprocessing tool1

WRKDIR=/cluster/home/wakamatsut/bioran_v2
PREPOBS_BGC=${WRKDIR}/prepobs_bgc   

EXEC_PROC_BTTL=${WRKDIR}/topaz_ran/preobs_bgc/src/proc_bottle
EXEC_EXTR_DATA=${WRKDIR}/prepobs_bgc/extract_data_bioran.sh

# command line arguments

std=30    # [%]
gdate=$1  # Gregorian date [YYYYMMDD]
CNFG=$2   # short name of hycom configuration [TP5|TP2]
mode=new  # [new/old]

# set range of dates

# preprocess prepobs_bgc files

BGCDIR=/nird/projects/NS9481K/BGCDATA/prepobs_bgc # annualy binned aggregated BGC data

mkdir -p bgc_data_tmp # SCRATCH

pushd ${PREPOBS_BGC} > /dev/null

#bash ${EXEC_EXTR_DATA} $gdate

popd > /dev/null

cd bgc_data_tmp

file_float=${PREPOBS_BGC}/bgc_data_extracted/bgc_float_${gdate}.txt
file_in_situ=${PREPOBS_BGC}/bgc_data_extracted/bgc_in_situ_${gdate}.txt
file_bgc=bgc_${gdate}.txt

if [ -f ${file_float} ] && [ -f ${file_in_situ} ]; then
    cat ${file_in_situ} > ${file_bgc}
    tail -n +3 ${file_float} >> ${file_bgc}
else
   if [ -f ${file_float} ]; then
      cat ${file_float} > ${file_bgc}
   elif [ -f ${file_in_situ} ]; then
      cat ${file_in_situ} > ${file_bgc}
   else
      echo "No files available"
   fi
fi

cd ..

# preprocess BGC data files for prep_obs

${EXEC_PROC_BTTL} $std $gdate $mode

for DVAR in CHL NIT SIL PHO #OXY
do
    file=bgc_data_tmp/${DVAR,,}_${gdate}.txt
    if [ -f $file ]; then
       echo "Save $file to CMEMS/BGC_bottle"
       mv $file CMEMS/BGC_bottle
    fi
done

# perform prep_obs

mkdir -p TMP

for DVAR in CHL NIT SIL PHO #OXY
do
   DSRC=BGC_bottle
   echo "#-------------------------"
   echo "# prep_obs.sh $gdate $CNFG $DSRC $DVAR"
   echo "#-------------------------"
   bash prep_obs.sh $gdate $CNFG $DSRC $DVAR
done

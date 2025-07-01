#!/bin/bash

PATH=$PATH:.

gdate=$1        # Gregorian date [YYYYMMDD]
CNFG=TP2        # short name of hycom configuration [TP5|TP2]
isload="false"  # load data files or not [true/false]
DSRC=CMEMS_CORA_MY

# data aggregation window in time for 7 days assimilation window

juldini=$(( $(datetojul.sh $gdate) - 3 ))
juldend=$(( $(datetojul.sh $gdate) + 3 ))

# create EnKF observation files

for juldnow in $(seq $juldini $juldend); do
    gdnow=$(jultodate.sh $juldnow); echo $gdnow
#    bash prep_CMEMS_CORA_MY.sh $gdnow $CNFG $isload
done

# aggregate EnKF observation files

sys_dir=/cluster/home/wakamatsut/bioran_v2 # TOPAZ reanalysis sytem folder

for DVAR in TEM SAL
do
    pobs_dir=${sys_dir}/topaz_ran/DATA/${CNFG}/${DSRC}/${DVAR} # pre-processed observation files by prepobs
    Fnc=${pobs_dir}/obs_${DVAR}_${gdate}.nc
    Fuf=${pobs_dir}/obs_${DVAR}_${gdate}.uf

if [ -f $Fnc ] && [ -f $Fuf ]; then
    echo "$Fnc exists already, SKIP"
    echo "$Fuf exists already, SKIP"
else
    uffile_list=()
    ncfile_list=()
    for juldnow in $(seq $juldini $juldend); do
	gdnow=$(jultodate.sh $juldnow); echo $gdnow
	for file in ${pobs_dir}/obs_${DVAR}_${gdnow}_*.uf ; do
	    if [ -f "$file" ]; then
		uffile_list+=("$file")
		ncfile="${file%.uf}.nc"
		ncks --mk_rec_dmn nobs $ncfile -O -o $ncfile
		ncfile_list+=("$ncfile")
		echo $file $ncfile
	    fi
	done
    done
    
    if [ ${#uffile_list[@]} -eq 0 ]; then
	echo "file list is empty"
    else
	cat    "${uffile_list[@]}" >  $Fuf
	ncrcat "${ncfile_list[@]}" -o $Fnc
    fi
	
    [ -f $Fnc ] && echo "$Fnc saved"
    [ -f $Fuf ] && echo "$Fuf saved"
fi

done    


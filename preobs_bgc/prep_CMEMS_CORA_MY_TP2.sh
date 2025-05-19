#!/bin/bash
#
# download CMEMS CORA data
#
set -u

gdate=20160901     # Gregorian date [YYYYMMDD]
CNFG=TP2           # short name of hycom configuration [TP5|TP2]
DSRC=CMEMS_CORA_MY # short name of dataset
isload="true"     # load files or not

#

sys_dir=/cluster/home/wakamatsut/bioran_v2 # TOPAZ reanalysis sytem folder

ran_dir=${sys_dir}/topaz_ran               # absolute path to reanalysis package
hyc_dir=${sys_dir}/topaz_hyc               # absolute path to hycom package
enkf_dir=${sys_dir}/topaz_enkf             # absolute path to enkf package
dobs_dir=${ran_dir}/preobs_bgc/CMEMS/$DSRC # absolute path to original observation files

cnfg_dir=${ran_dir}/CONFIG/$CNFG         # hycom configuration files (copy from topo folder)
infl_dir=${ran_dir}/preobs_bgc/Infile    # template of infile.data
swork_dir=${ran_dir}/preobs_bgc/TMP       # scratch folder

#-- define available instrument types
#list_type=("BO" "CT" "SM" "BA" "GL" "OS" "RE" "TE" "XT" "PF")
list_type=("BO" "CT" "XT" "PF")

if $isload; then
    types_string=$(IFS=' '; echo "${list_type[*]}")
    echo "#-------------------------"
    echo "# cmems_cora_loader.py ${gdate} MY \"$types_string\" $isload"
    echo "#-------------------------"
    python cmems_cora_loader.py ${gdate} MY "$types_string" $isload
else
    echo "Skip loading files from CMEMS"
fi

pushd ./CMEMS/${DSRC}

# prepare Hycom configuration files

ln -sf ${cnfg_dir}/blkdat.input
ln -sf ${cnfg_dir}/regional.* .
ln -sf ${cnfg_dir}/grid.info .

#

idm=$(awk 'NR==1 {print $1}' regional.grid.b); echo "idm: $idm"
jdm=$(awk 'NR==2 {print $1}' regional.grid.b); echo "jdm: $jdm"
ln -sf ${ran_dir}/FILES/newpos.uf .
ln -sf ${ran_dir}/FILES/depths${idm}x${jdm}.uf .

# set PATH to MSCPROGS and Prep_Routines

PATH=$PATH:${hyc_dir}/hycom/MSCPROGS/bin:${enkf_dir}/Prep_Routines

# observation files for EnKF

for DVAR in TEM SAL
do

pobs_dir=${ran_dir}/DATA/${CNFG}/${DSRC}/${DVAR} # pre-processed observation files by prepobs
mkdir -p ${pobs_dir}

dobs_dir=${ran_dir}/OBS/$DVAR
mkdir -p ${dobs_dir}
    
# set error variance
if [ "$DVAR" = "SAL" ]; then
   OVAR=0.02
elif [ "$DVAR" = "TEM" ]; then
   OVAR=0.5
fi
    
if [ -s ${infl_dir}/infile.data.$DSRC ]; then
    sed "s/SDATE/${gdate}/; s/DVAR/${DVAR}/; s/OVAR/${OVAR}/" \
	${infl_dir}/infile.data.$DSRC > infile.data
    cat infile.data
else
    echo "Can not find ${infl_dir}/infile.data.$DSRC , EXIT"
    exit
fi
    
echo "#-------------------------"
echo "# prep_obs $DVAR"
echo "#-------------------------"

# Enable nullglob so the array is empty if no files match
shopt -s nullglob

# Get a list of files matching a pattern

files=(CO*${gdate}*.nc)

# Loop over the list
if [ ${#files[@]} -eq 0 ]; then
    echo "No files found!"
else
    for file in "${files[@]}"; do
	basename="${file%.nc}"
        type="${basename##*_}"
        if [[ " ${list_type[@]} " =~ " $type " ]]; then
           echo "Processing $file"
	   symlink=${gdate}_${DVAR}.nc
	   [ -f $symlink ] && rm $symlink
	   ln -sf $file $symlink
	   echo "ln -sf $file $symlink $type"
	   
           Fnc=${pobs_dir}/obs_${DVAR}_${gdate}_${type}.nc
           Fuf=${pobs_dir}/obs_${DVAR}_${gdate}_${type}.uf

           prep_obs
           if [ -s observations-${DVAR}.nc -a observations.uf ]; then
              mv observations-${DVAR}.nc ${Fnc}
              mv observations.uf         ${Fuf}

	      pushd ${dobs_dir}
	      ln -sf ${Fnc} .
	      ln -sf ${Fuf} .
	      popd
	      for file in superobs*.nc superobs.txt; do
		 [ -f $file ] && (echo "rm $file"; rm $file)
              done			  
	   else
	      echo "Failed in creation of observations.uf"
           fi
	fi
    done
fi

done

popd

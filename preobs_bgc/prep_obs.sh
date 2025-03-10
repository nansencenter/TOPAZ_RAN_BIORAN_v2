#!/bin/bash
#
# prep_obs.sh
#

gdate=$1 # Gregorian date [YYYYMMDD]
CNFG=$2  # short name of hycom configuration [TP5|TP2]
DSRC=$3  # name of dataset [OSTIA_SST|OCCI_SCHL|]
DVAR=$4  # name of parameter [SST|ICEC|SCHL]

sys_dir=/cluster/home/wakamatsut/bioran_v2 # TOPAZ reanalysis sytem folder

ran_dir=${sys_dir}/topaz_ran             # absolute path to reanalysis package
hyc_dir=${sys_dir}/topaz_hyc             # absolute path to hycom package
enkf_dir=${sys_dir}/topaz_enkf           # absolute path to enkf package
dobs_dir=${ran_dir}/preobs_bgc/CMEMS/$DSRC   # absolute path to original observation files

cnfg_dir=${ran_dir}/CONFIG/$CNFG         # hycom configuration files (copy from topo folder)
infl_dir=${ran_dir}/preobs_bgc/Infile        # template of inile.data
work_dir=${ran_dir}/preobs_bgc/TMP           # scratch folder
pobs_dir=${ran_dir}/DATA/${CNFG}/${DSRC}/${DVAR} # pre processed observation files by prepobs

fdobs=${dobs_dir}/${DVAR}_${gdate}.nc  # input data file (e.g. SST_20190101.nc)

mkdir -p ${pobs_dir}
mkdir -p ${work_dir}

pushd ${work_dir} > /dev/null

# prepare Hycom configuration files

ln -sf ${cnfg_dir}/blkdat.input
ln -sf ${cnfg_dir}/regional.* .
ln -sf ${cnfg_dir}/grid.info .

# set PATH to MSCPROGS and Prep_Routines

PATH=$PATH:${hyc_dir}/hycom/MSCPROGS/bin:${enkf_dir}/Prep_Routines

# observation files for EnKF

Fnc=${pobs_dir}/obs_${DVAR}_${gdate}.nc
Fuf=${pobs_dir}/obs_${DVAR}_${gdate}.uf

Fini=${gdate}_${DVAR,,}.nc

if [[ ! -s "${Fnc}" || ! -s "${Fuf}" ]]; then
    if [ -s ${infl_dir}/infile.data.$DSRC ]; then
       sed "s/SDATE/${gdate}/" ${infl_dir}/infile.data.$DSRC > infile.data
       cat infile.data
    else
       echo "Can not find ${infl_dir}/infile.data.$DSRC , EXIT"
       exit
    fi
    if [ -s ${fdobs} ]; then
       echo "$(basename $fdobs) > ${Fini}"
       ln -sf ${fdobs} ${Fini}
    else
       echo "Can not find ${fdobs}"
       exit
    fi
    prep_obs
    if [ -s observations-${DVAR}.nc -a observations.uf ]; then
       mv observations-${DVAR}.nc ${Fnc}
       mv observations.uf         ${Fuf}
    fi
    rm -rf ${Fini} 
else
    echo "Both $(basename ${Fnc}) and $(basename ${Fuf}) exist, SKIP"
fi

popd > /dev/null

rm -rf ${work_dir}

exit

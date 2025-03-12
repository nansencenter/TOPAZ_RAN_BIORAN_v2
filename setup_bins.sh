#!/bin/bash

#-- user defined

export EnKF_HOME=/cluster/home/wakamatsut/bioran_v2/enkf-topaz_BIORANv2  # EnKF package directory
export HYCOM_HOME=/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2 # hycom package directory
export HYCOM_BIN=${HYCOM_HOME}/hycom/MSCPROGS/bin                        # MSCPROGS bin directry

#-- 

[ -d BIN -a ! -d BIN.org ] && mv BIN BIN.org
mkdir -p BIN

#----------------------------------
# jultodate
#----------------------------------

pushd BIN

[ -f jultodate ] && rm jultodate
ln -sf ${HYCOM_BIN}/jultodate .

popd

#----------------------------------
# EnKF
#----------------------------------

pushd ASSIM

[ -d BIN -a ! -d BIN.org ] && mv BIN BIN.org
mkdir -p BIN

popd

pushd ASSIM/BIN

[ -f EnKF ] && rm EnKF
ln -sf ${EnKF_HOME}/EnKF .

for exec in consistency EnKF_assemble EnKF_assemble.sh fixhycom
do
   [ -f $exec ] && rm $exec
   ln -sf ${EnKF_HOME}/Tools/$exec .
done
   
ln -sf ../../BIN/jultodate .
ln -sf ../../SSHFromState_HYCOMICE/restart2nc  .
ln -sf ../../SSHFromState_HYCOMICE/extract2ssh .

popd

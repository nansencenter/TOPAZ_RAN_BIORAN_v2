#!/bin/bash

#-- user defined

export RAN_WORK=/cluster/work/users/wakamatsut/bioran_v2      # hycom work directory
export RAN_HOME=/cluster/home/wakamatsut/bioran_v2/topaz_ran  # TOPAZ reanalysis package directory

#-- 

export PREOBSDIR=${RAN_HOME}/PREOBS
export DATADIR=${RAN_WORK}/DATA

cd ${RAN_HOME}

if [ -d $DATADIR ]; then
    ln -sf ${RAN_WORK}/DATA .
else
    echo "Can not find DATADIR: $DATADIR , EXIT"
    exit 1
fi



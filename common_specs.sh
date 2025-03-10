#!/bin/bash

# parameters common to both propagation and assimilation
#
MSCPROGSBIN="/cluster/home/wakamatsut/bioran_v2/topaz_hyc/hycom/MSCPROGS/bin"
ROOTDIR="/cluster/work/users/wakamatsut/bioran_v2"
FORECASTDIR="${ROOTDIR}/FORECAST"
TAPEDIR="${ROOTDIR}"
BACKUPBUFDIR="${ROOTDIR}/TOBACKUP"
RESULTSDIR="${ROOTDIR}/RESULTS"
ANALYSISDIR="${ROOTDIR}/ANALYSIS"
MODELDIR="${ROOTDIR}/TP2a0.10/expt_03.0"
OUTPUTDIR="${ROOTDIR}/OUTPUT"
NESTINGDIR="${ROOTDIR}/NESTING"
HYCOMPREFIX="TP2"
ENSSIZE=100

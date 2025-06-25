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
 
JULDAY=24462
JULDAYNXT=24469
JULDAYSTART=24350
CWD=/cluster/home/wakamatsut/bioran_v2/topaz_ran/ASSIM
# assimilation specific parameters
#
NPROC=72 # number of processors engaged in the EnKF analysis

# Possible observation types:
#
# TSLA  - track SLA
# SST   - SST
# SAL   - in-situ salinity from ARGO
# TEM   - in-situ temperature from ARGO
# ICEC  - ice concentration
# ICEH  - ice thickness
# IDRFT - ice drift
#
OBSTYPES="SST TEM SAL ICEC"        # List of observation types

# do not edit below unless you have to
#
PREPOBSDIR="${ROOTDIR}/PREPOBS"
OBSDIR="${ROOTDIR}/OBS"
CWD=`pwd`
BINDIR=`pwd`"/BIN"
FILESDIR=`pwd`"/FILES"

# check if listed observations types are available
#

echo ""
echo "      check observations"

OBSREADY=1    # else =0
if [ ${OBSREADY} == 1 ]; then
    pushd ${OBSDIR} > /dev/null
    echo "      in $PWD"
    count=0
    for obstype in ${OBSTYPES}; do
	if [ -d $obstype ]; then
	    echo "$obstype"
	    count=$(expr $count + 1)
	fi
    done
    popd > /dev/null
    if [ $count == 0 ]; then
	echo "Ther is no observations"
	OBSREADY=0
    fi
fi


#OBSREADY=1 # else =0
#if [ ${OBSREADY} == 1 ]; then
#   Tdir=$(pwd)
#   cd ${OBSDIR}
#   Obslink="${ROOTDIR}/DATA"
#   o=0
#   for obstype in ${OBSTYPES}; do
#     [ -r ${obstype} ] && ((o++))
#   done
#   if [ $o == 0 ]; then
#      for obsty in ${OBSTYPES} ; do
#         ln -sf ${Obslink}/${obsty} .
#      done
#    fi
#   cd ${Tdir}
#fi

#[ $o == 1 ] && OBSREADY=0

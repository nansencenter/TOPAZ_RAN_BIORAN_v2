#!/bin/bash

set -e # exit on error
set -u # exit on unset variables

. common_specs.sh

echo "Checking principal directories:"

[ ! -d "${ROOTDIR}" ] && echo "ERROR: no ROOTDIR=\"${ROOTDIR}\" found" && exit 1
echo "  ROOTDIR = ${ROOTDIR}"

#[ ! -d "${BACKUPBUFDIR}" ] && mkdir -p ${BACKUPBUFDIR} && lfs setstripe ${BACKUPBUFDIR} 0 -1 -1
#[ ! -d "${BACKUPBUFDIR}" ] && mkdir -p ${BACKUPBUFDIR} && lfs setstripe ${BACKUPBUFDIR} -s 32M -c 4
[ ! -d "${BACKUPBUFDIR}" ] && mkdir -p ${BACKUPBUFDIR} && lfs setstripe ${BACKUPBUFDIR} -c 4
echo "  BACKUPBUFDIR = ${BACKUPBUFDIR}"

#[ ! -d "${TAPEDIR}" ] && echo "ERROR: no TAPEDIR=\"${TAPEDIR}\" found" && exit 1
#echo "  TAPEDIR = ${TAPEDIR}"

[ ! -d "${RESULTSDIR}" ] && mkdir -p ${RESULTSDIR}
echo "  RESULTSDIR = ${RESULTSDIR}"

[ ! -d "${OUTPUTDIR}" ] && mkdir -p ${OUTPUTDIR} 
echo "  OUTPUTDIR = ${OUTPUTDIR}"

[ ! -d "${MODELDIR}" ] && echo "ERROR: no MODELDIR=\"${MODELDIR}\" found" && exit 1
echo "  MODELDIR = ${MODELDIR}"

#[ ! -d "${NESTINGDIR}" ] && echo "ERROR: no NESTINGDIR = \"${NESTINGDIR}\" found" && exit 1
#echo "  NESTINGDIR = ${NESTINGDIR}"

echo "  (directories OK)"

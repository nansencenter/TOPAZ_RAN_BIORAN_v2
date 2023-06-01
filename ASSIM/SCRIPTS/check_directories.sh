#!/bin/bash

set -e # exit on error
set -u # exit on unset variables

. assimilation_specs.sh

[ ! -d "${BINDIR}" ] && echo "assimilate.sh: ERROR: BINDIR = \"${BINDIR}\": no such directory" && exit 1
echo "     BINDIR = ${BINDIR}"

[ ! -d "${PREPOBSDIR}" ] && mkdir -p ${PREPOBSDIR}
echo "     PREPOBSDIR = ${PREPOBSDIR}"

#[ ! -d "${ANALYSISDIR}" ] && mkdir -p ${ANALYSISDIR} && lfs setstripe ${ANALYSISDIR} 0 -1 -1
[ ! -d "${ANALYSISDIR}" ] && mkdir -p ${ANALYSISDIR} && lfs setstripe ${ANALYSISDIR} -s 32M -c 4
echo "     ANALYSISDIR = ${ANALYSISDIR}"

[ ! -d "${OBSDIR}" ] && echo "assimilate.sh: ERROR: OBSDIR = \"${OBSDIR}\": no such directory" && exit 1
echo "     OBSDIR = ${OBSDIR}"

[ ! -d "${FORECASTDIR}" ] && echo "assimilate.sh: ERROR: FORECASTDIR = \"${FORECASTDIR}\": no such directory" && exit 1
echo "     FORECASTDIR = ${FORECASTDIR}"

[ ! -d "${RESULTSDIR}/${JULDAY}" ] && mkdir ${RESULTSDIR}/${JULDAY}
[ ! -d "${RESULTSDIR}/${JULDAY}/ANALYSIS" ] && mkdir ${RESULTSDIR}/${JULDAY}/ANALYSIS
[ ! -d "${RESULTSDIR}/${JULDAY}/FORECAST" ] && mkdir ${RESULTSDIR}/${JULDAY}/FORECAST
[ ! -d "${RESULTSDIR}/${JULDAY}/LOG" ] && mkdir ${RESULTSDIR}/${JULDAY}/LOG

[ ! -d "${OUTPUTDIR}/${JULDAY}" ] && mkdir -p ${OUTPUTDIR}/${JULDAY}


[ ! -d "${BACKUPBUFDIR}/${JULDAY}/FORECAST" ] && mkdir -p ${BACKUPBUFDIR}/${JULDAY}/FORECAST
[ ! -d "${BACKUPBUFDIR}/ANALYSIS" ] && mkdir -p ${BACKUPBUFDIR}/ANALYSIS
[ ! -d "${BACKUPBUFDIR}/RESULTS" ] && mkdir -p ${BACKUPBUFDIR}/RESULTS
[ ! -d "${BACKUPBUFDIR}/OUTPUT" ] && mkdir -p ${BACKUPBUFDIR}/OUTPUT
[ ! -d "${BACKUPBUFDIR}/NESTING" ] && mkdir -p ${BACKUPBUFDIR}/NESTING
echo "     (directories OK)"

#!/bin/bash

set -e # exit on error
set -u # exit on unset variables

. propagation_specs.sh

[ ! -d ${RESULTSDIR}/${JULDAY}/LOG ] && mkdir -p ${RESULTSDIR}/${JULDAY}/LOG
[ ! -d ${RESULTSDIR}/${JULDAY}/FORECAST ] && mkdir -p ${RESULTSDIR}/${JULDAY}/FORECAST
[ ! -d ${BACKUPBUFDIR}/${JULDAY}/FORECAST ] && mkdir -p ${BACKUPBUFDIR}/${JULDAY}/FORECAST
[ ! -d ${BACKUPBUFDIR}/${JULDAY}/ANALYSIS ] && mkdir -p ${BACKUPBUFDIR}/${JULDAY}/ANALYSIS
echo "   (directories OK)"

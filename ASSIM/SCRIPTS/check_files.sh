#!/bin/bash

set -e # exit on error
set -u # exit on unset variables

CWD=`pwd`
. ./assimilation_specs.sh

HYCOMFILES=\
"analysisfields.in
analysisfields_ice.in
blkdat.input
depths.uf
grid.info
meanssh.uf
re_sla.nc
regional.grid.a
regional.grid.b
regional.depth.a
regional.depth.b"

#meanssh800x760.nc

#OBSFILES=\
#"psn12lats_v2.dat
#psn12lons_v2.dat"

BINFILES=\
"jultodate
EnKF
EnKF_assemble.sh
EnKF_assemble
consistency
fixhycom"

#restart2nc"

ENKFFILES=\
"point2nc.txt"
#"jmap.txt
#point2nc.txt"

PRMFILES=\
"enkf.prm"

echo -n "   Checking for necessary configuration files..."

cd "${ANALYSISDIR}"
for file in $HYCOMFILES
do
    if [ ! -r "$file" ]; then
	cd ${CWD}
	if [ -r "${FILESDIR}/${file}" ]; then
	    cp ${FILESDIR}/${file} "${ANALYSISDIR}"
	else
	    echo
	    echo "ERROR: check_files.sh: \"$file\" not found"
	    exit 1
	fi
    fi
    ln -sf ${ANALYSISDIR}/$file $PREPOBSDIR
done

#cd "${PREPOBSDIR}"
#for file in $OBSFILES
#do
#    if [ ! -r "$file" ]
#    then
#	cd ${CWD}
#	if [ -r "${FILESDIR}/${file}" ]
#        then
#	    cp ${FILESDIR}/${file} "${PREPOBSDIR}"
#	else
#	    echo
#	    echo "ERROR: check_files.sh: \"$file\" not found"
#	    exit 1
#	fi
#    fi
#done

cd "${ANALYSISDIR}"

for file in $ENKFFILES
do
    if [ ! -r -" $file" ]; then
	cd ${CWD}
	if [ -r "${FILESDIR}/${file}" ]; then
	    cp ${FILESDIR}/${file} "${ANALYSISDIR}"
	else
	    echo
	    echo "ERROR: check_files.sh: \"$file\" not found in ${CWD}"
	    exit 1
	fi
    fi
done

for file in $PRMFILES
do
    if [ ! -r -" $file" ]; then
	cd ${CWD}
	if [ -r "${file}" ]; then
	    cp ${file} "${ANALYSISDIR}"
	else
	    echo
	    echo "ERROR: check_files.sh: \"$file\" not found in ${CWD}"
	    exit 1
	fi
    fi
done
echo "OK"

echo -n "   Checking for necessary executables..."
cd ${BINDIR}
for file in $BINFILES
do
    echo $file
    if [ ! -x "$file" ]; then
	echo
	echo "ERROR: check_files.sh: \"$file\" not found in ${BINDIR}"
	exit 1
    fi
done
echo "OK"

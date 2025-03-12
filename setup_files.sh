#!/bin/bash

#-- user defined

CNFG=TP2a0.10   # Hyom configuration
EXPN=expt_03.0  # Hycom experiment folder
TOPOVER=04      # Bathymetry version number

export HYCOM_WORK=/cluster/work/users/wakamatsut/bioran_v2/TP2a0.10      # hycom work directory
export HYCOM_HOME=/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2 # hycom package directory
export HYCOM_BIN=${HYCOM_HOME}/hycom/MSCPROGS/bin                        # MSCPROGS bin directry
export HYCOM_ARCH=/nird/datalake/NS9481K/shuang/TP2_output/expt_04.2     # hycom archive (archm**) directory

#-- 

[ -d FILES -a ! -d FILES.org ] && mv FILES FILES.org
mkdir -p FILES

cd FILES

#--------------------------------
# copy hycom configuration files
#--------------------------------

CNFGDIR=${HYCOM_HOME}/$CNFG/topo

[ -f grid.info ] && rm grid.info
[ -f regional.grid.a ] && rm regional.grid.a
[ -f regional.grid.b ] && rm regional.grid.b
[ -f regional.depth.a ] && rm regional.depth.a
[ -f regional.depth.b ] && rm regional.depth.b

ln -sf $CNFGDIR/grid.info .
ln -sf $CNFGDIR/regional.grid.a .
ln -sf $CNFGDIR/regional.grid.b .
ln -sf $CNFGDIR/depth_${CNFG}_${TOPOVER}.a regional.depth.a
ln -sf $CNFGDIR/depth_${CNFG}_${TOPOVER}.b regional.depth.b

#--------------------------------
# copy blkdat.input
#--------------------------------

WORKDIR=${HYCOM_WORK}/${EXPN}

[ -f blkdat.input ] && rm blkdat.input

echo "${EXPN}/blkdat.input > blkdat.input"
ln -sf $WORKDIR/blkdat.input .

#--------------------------------
# prep depths.uf
#--------------------------------

BINDIR=${HYCOM_HOME}/hycom/MSCPROGS/src/Tools_Conf

[ -f depths.uf ] && rm depths.uf

idm=$(awk 'NR==1 {print $1}' regional.grid.b); echo "idm: $idm"
jdm=$(awk 'NR==2 {print $1}' regional.grid.b); echo "jdm: $jdm"

if [ ! -f depths${idm}x${jdm}.uf ]; then
    echo "Can not find depths${idm}x${jdm}.uf. Calculate depths.uf:"
    ${BINDIR}/get_depths
fi    
echo "depths${idm}x${jdm}.uf > depths.uf"
ln -sf depths${idm}x${jdm}.uf depths.uf

#--------------------------------
# prep newpos.uf
#--------------------------------

BINDIR=${HYCOM_HOME}/hycom/MSCPROGS/bin_setup

[ -f newpos.uf ] && rm newpos.uf

if [ ! -f newpos${idm}x${jdm}.uf ]; then
    echo "Can not find newpos${idm}x${jdm}.uf. Calculate newpos.uf"
    ${BINDIR}/grid
    mv newpos.uf newpos${idm}x${jdm}.uf
fi    
echo "newpos${idm}x${jdm}.uf > newpos.uf"
ln -sf newpos${idm}x${jdm}.uf newpos.uf

#--------------------------------
# prep meanssh.uf and re_slp.uf
#--------------------------------

BINDIR=${HYCOM_HOME}/hycom/MSCPROGS/src/Tools_Conf

[ -f meanssh.uf ] && rm meanssh.uf
[ -f re_slp.uf ] && rm re_slp.uf

ln -sf ../ASSIM/SCRIPTS/calc_ssh_stat.sh .

if [ ! -f meanssh${idm}x${jdm}.uf -o ! re_slp${idm}x${jdm}.nc ]; then
   bash calc_ssh_stat.sh
   ln -sf meanssh${idm}x${jdm}.nc meanssh.nc
   ${BINDIR}/get_meanssh # convert .nc to .uf
   mv meanssh.uf meanssh${idm}x${jdm}.uf
fi
echo "meanssh${idm}x${jdm}.nc > meanssh.uf"
ln -sf meanssh${idm}x${jdm}.uf meanssh.uf
echo "re_sla${idm}x${jdm}.nc > re_sla.nc"
ln -sf re_sla${idm}x${jdm}.nc re_sla.nc

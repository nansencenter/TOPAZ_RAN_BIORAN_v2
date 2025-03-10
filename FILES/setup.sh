#!/bin/bash

CNFG=TP2a0.10
TOPOVER="04"

CNFGDIR="/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/TP2a0.10/topo"

[ -f grid.info ] && rm grid.info
[ -f regional.grid.a ] && rm regional.grid.a
[ -f regional.grid.b ] && rm regional.grid.b
[ -f regional.depth.a ] && rm regional.depth.a
[ -f regional.depth.b ] && rm regional.depth.b

ln -sf $CNFGDIR/grid.info .
ln -sf $CNFGDIR/regional.grid.a .
ln -sf $CNFGDIR/regional.grid.b .
ln -sf $CNFGDIR/depth_TP2a0.10_${TOPOVER}.a regional.depth.a
ln -sf $CNFGDIR/depth_TP2a0.10_${TOPOVER}.b regional.depth.b

WORKDIR="/cluster/work/users/wakamatsut/bioran_v2/TP2a0.10/expt_03.0"

[ -f blkdat.input ] && rm blkdat.input

ln -sf $WORKDIR/blkdat.input .


CNFGDIR="/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/TP2a0.10/topo"

[ -f meanssh.uf ] && rm meanssh.uf

ln -sf Rio22_TP5_corrected.uf meanssh.uf 

[ -f depths.uf ] && rm depths.uf

idm=$(awk 'NR==1 {print $1}' regional.grid.b); echo "idm: $idm"
jdm=$(awk 'NR==2 {print $1}' regional.grid.b); echo "jdm: $jdm"

BINDIR="/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/hycom/MSCPROGS/src/Tools_Conf"
${BINDIR}/get_depths

file=depths${idm}x${jdm}.uf
echo $file

[ -f depths${idm}x${jdm}.uf ] && ln -sf depths${idm}x${jdm}.uf depths.uf 

[ -f newpos.uf ] && rm newpos.uf

BINDIR=/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/hycom/MSCPROGS/bin_setup
${BINDIR}/grid

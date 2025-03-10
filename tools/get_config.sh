#!/bin/bash

BINSDIR=/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/hycom/MSCPROGS/bin_setup

mkdir -p TMP
cd TMP

CNFGDIR=/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/TP2a0.10/topo

ln -sf $CNFGDIR/grid.info .
ln -sf $CNFGDIR/depth_TP2a0.10_04.a region.depth.a
ln -sf $CNFGDIR/depth_TP2a0.10_04.b region.depth.b
ln -sf $CNFGDIR/regional.grid.* .

CNFGDIR=/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/hycom/MSCPROGS/src/Conf_grid
ln -sf $CNFGDIR/grid.bathy .

$BINSDIR/grid



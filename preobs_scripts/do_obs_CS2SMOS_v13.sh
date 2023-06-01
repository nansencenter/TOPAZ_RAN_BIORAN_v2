Mdir=/cluster/home/xiejp/REANALYSIS_TP5/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*x*.uf .
ln -sf ${Mdir}/re_sla.nc .

#Idir=/cluster/home/xiejp/TP4_Reanalysis/preobs_scripts/
Idir=/cluster/home/xiejp/REANALYSIS_TP5/preobs_scripts/

Odir0=/cluster/work/users/xiejp/data0/SIT_2022
Odir=/cluster/work/users/xiejp/TP5_Reanalysis/OBS/HICE
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

if [ ! -s ./prep_obs ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Fram/prep_obs_hice prep_obs
fi



Jd1=25202
Jd1=26260
Jd2=26410


for Jdy in `seq ${Jd1} ${Jd2}`; do
  #rm ?????_hice.nc infile.data
  let Ndy=Jdy-6
  Sdate0=`jultodate ${Ndy} 1950 1 1`
  Sdate=`jultodate ${Jdy} 1950 1 1`
#  Fnc=cs2smos_ice_thickness_${Sdate0:0:8}_${Sdate:0:8}_v1.3.nc
  #Fnc="W_XX-ESA,SMOS_CS2,NH_25KM_EASE2_${Sdate0:0:8}_${Sdate:0:8}_r_v202_01_l4sit.nc"
  Fnc="W_XX-ESA,SMOS_CS2,NH_25KM_EASE2_${Sdate0:0:8}_${Sdate:0:8}_r_v204_01_l4sit.nc"   # updated at 6th August 2021
  echo ${Fnc} ${Jdy}
  if [ -s ${Odir0}/${Fnc} -a ! -s ${Odir}/obs_HICE_${Jdy}.nc ]; then
    sed "s/JULDDATE/${Jdy}/" ${Idir}Infile/infile.data_CYSMOShice > infile.data
    echo ${Fnc}
    ln -sf ${Odir0}/${Fnc} ${Jdy}_hice.nc
    ./prep_obs
    if [ -s observations-HICE.nc -a observations.uf ]; then
      mv observations-HICE.nc ${Odir}/obs_HICE_${Jdy}.nc
      mv observations.uf ${Odir}/obs_HICE_${Jdy}.uf
    fi
  fi
done




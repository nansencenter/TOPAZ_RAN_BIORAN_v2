
Mdir=/home/nersc/xiejp/REANALYSIS/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*.uf .
ln -sf ${Mdir}/re_sla.nc .

Idir=/home/nersc/xiejp/work_2015/TOPAZ_Reanalysis/script/pre_obs/

Odir0=/work/xiejp/work_2016/TP4_SMOS/smos_sea_ice_thickness
Odir=/work/xiejp/work_2016/Data/HICE3.1
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

if [ ! -s ./prep_obs ]; then
  ln -sf /home/nersc/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Routines/prep_obs .
fi

Jd1=21914  # 2009/12/31
Jd2=24471  # 2016/12/31

#Jd1=23710
#Jd2=24106

for Jdy in `seq ${Jd1} ${Jd2}`; do
  rm ?????_hice.nc infile.data
  let Ndy=Jdy-1
  Sdate=`jultodate ${Ndy} 1950 1 1`
  Fnc=SMOS_Icethickness_v3.1_north_${Sdate:0:8}.nc
  if [ -s ${Odir0}/${Fnc} -a ! -s ${Odir}/obs_HICE_${Jdy}.nc ]; then
    sed "s/JULDDATE/${Ndy}/" ${Idir}/Infile/infile.data_SMOShice > infile.data
    echo ${Fnc}
    ln -sf ${Odir0}/${Fnc} ${Ndy}_hice.nc 
    ./prep_obs
    if [ -s observations-HICE.nc -a observations.uf ]; then
      mv observations-HICE.nc ${Odir}/obs_HICE_${Jdy}.nc
      mv observations.uf ${Odir}/obs_HICE_${Jdy}.uf
    fi 
  fi
done



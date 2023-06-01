HomeAdir=/cluster/home/xiejp/REANALYSIS_TP5

Rundir=$(pwd)

#Modir=/cluster/home/xiejp/REANALYSIS/FILES
Modir=${HomeAdir}/FILES
ln -sf ${Modir}/blkdat.input
ln -sf ${Modir}/regional.* .
ln -sf ${Modir}/grid.info .
ln -sf ${Modir}/depths*.uf .
ln -sf ${Modir}/meanssh.uf .
#ln -sf ${Modir}/re_sla.nc .

Idir=${HomeAdir}/PREOBS/Infile/

Odir0=/cluster/work/users/xiejp/DATA/data0/sst
Odir=/cluster/work/users/xiejp/TP2_Reanalysis/DATA/
cd ${Odir}
if [ ! -s ./SST ]; then
  mkdir SST 
fi
Odir=/cluster/work/users/xiejp/TP2_Reanalysis/DATA/SST

cd ${Rundir}

if [ ! -s ./prep_obs ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Fram/prep_obs .
fi

Jdy0=24450
Jdy1=25100

Jdy0=20800
Jdy1=21200

#Jdy1=24500

echo ${Odir}

for Jdy in `seq ${Jdy0} ${Jdy1}`; do
  Sdate=`jultodate ${Jdy} 1950 1 1`
#  Ny=`echo ${Sdate:0:4}`
#  Nm=`echo ${Sdate:4:2}`
#  Nd=`echo ${Sdate:6:2}`
  echo ${Ny} ${Nm} ${Nd}
  Fnc=obs_SST_${Jdy}.nc
  Fuf=obs_SST_${Jdy}.uf
  if [ ! -s ${Odir}/${Fnc} ]; then
    sed "s/JULDDATE/${Jdy}/" ${Idir}/infile.data_ostia > infile.data
    Fini=ncof_sst_${Jdy}.nc
    if [ -s ${Odir0}/${Fini} ]; then
      echo ${Fini}
      ln -sf ${Odir0}/${Fini} ${Jdy}_sst.nc 
      if [ ${Jdy} -gt 23410 ]; then
        ./prep_obs
      else
        ./prep_obs
      fi
       if [ -s observations-SST.nc -a observations.uf ]; then
         mv observations-SST.nc ${Odir}/${Fnc}
         mv observations.uf ${Odir}/${Fuf}
       fi 
       rm ${Jdy}_sst.nc
     fi
  fi
done


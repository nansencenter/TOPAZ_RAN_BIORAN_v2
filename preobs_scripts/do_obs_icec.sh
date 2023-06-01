
Mdir=/cluster/home/xiejp/REANALYSIS_TP5/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*.uf .
ln -sf ${Mdir}/re_sla.nc .

Idir=/cluster/home/xiejp/REANALYSIS_TP5/PREOBS/Infile/

Odir0=/cluster/work/users/xiejp/DATA/data0/conc
#Odir0=/cluster/work/users/xiejp/DATA/data0/conc_all
Odir=/cluster/work/users/xiejp/work_2023/Data_TP5/ICEC
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

if [ ! -s ./prep_obs ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Fram/prep_obs .
fi

for iy in `seq 2020 2022` ; do
  if [ $iy -eq 2020 ]; then
    m1=12
    m2=12
  else
    m1=1
    m2=12
  fi
  echo $iy $m1 $m2
  J1=$(datetojul ${iy} ${m1} 1 1950 1 1)
  if [ $m2 -eq 12 ]; then
     J2=$(datetojul ${iy} 12 31 1950 1 1)
  else
     (( m2 = m2 + 1 ))
     J2=$(datetojul $iy ${m2} 0 1950 1 1)
  fi
  isat='conc'
  for Jdy in `seq $J1 $J2`; do
      (( jjdy = Jdy + 1 ))
      Jdate0=$(jultodate ${Jdy} 1950 1 1)
      Sdate0=${Jdate0:0:8}
      Ny0=${Sdate0:0:4}
      Fnc=ice_${isat}_nh_ease2-250_icdr-v3p0_${Sdate0}12000.nc
      Odir1=${Odir0}/${Ny0}
      Fout=${Odir}/obs_ICEC_${jjdy}.uf
      if [ -s ${Odir1}/${Fnc} -a ! -s ${Fout} ]; then
         echo ${Fnc}
         sed "s/JULDDATE/${Jdy}/" ${Idir}/infile.data_icec > infile.data
         ln -sf ${Odir1}/${Fnc} ${Jdy}_icec.nc 
         ./prep_obs
         if [ -s observations-ICEC.nc -a -s observations.uf ]; then
            mv observations-ICEC.nc ${Odir}/obs_ICEC_${jjdy}.nc
            mv observations.uf ${Odir}/obs_ICEC_${jjdy}.uf
         fi 
         rm ${Jdy}_icec.nc
      fi
   done   # end of each date
done

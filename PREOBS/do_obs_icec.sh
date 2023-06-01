
Mdir=/cluster/home/xiejp/REANALYSIS_TP5/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*.uf .
ln -sf ${Mdir}/re_sla.nc .

Idir=/cluster/home/xiejp/REANALYSIS_TP5/PREOBS/Infile/

Odir0=/cluster/work/users/xiejp/DATA/data0/conc_hist
Odir=/cluster/work/users/xiejp/work_2020/Data/ICEC
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

if [ ! -s ./prep_obs ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Fram/prep_obs .
fi

for iy in `seq 2016 2017` ; do
  if [ $iy -gt 2017 ]; then
    m1=1
    m2=1
  else
    m1=1
    m2=12
  fi
  for im in `seq $m1 $m2` ; do
    for idy in `seq 1 31`; do
      i0=0
      Sdate=`datetojul ${iy} ${im} ${idy} 1950 1 1`
      Sday=${iy}`echo 00${im}|tail -3c``echo 00${idy}|tail -3c`
      sed "s/JULDDATE/${Sdate}/" ${Idir}/infile.data_icec > infile.data
      for isat in conc ; do
        #Fnc=ice_${isat}_nh_polstere-100_reproc_${Sday}1200.nc
        Fnc=ice_${isat}_nh_polstere-100_cont-reproc_${Sday}1200.nc
        Fnc=ice_${isat}_nh_ease2-250_icdr-v2p0_${Sday}1200.nc
        echo ${Fnc}
        Fout=${Odir}/obs_ICEC_${Sdate}.uf
        if [ -s ${Odir0}/${Fnc} -a ! -s ${Fout} ]; then
          echo ${Fnc}
          ln -sf ${Odir0}/${Fnc} ${Sdate}_icec.nc 
          ./prep_obs
          if [ -s observations-ICEC.nc -a -s observations.uf ]; then
            mv observations-ICEC.nc ${Odir}/obs_ICEC_${Sdate}.nc
            mv observations.uf ${Odir}/obs_ICEC_${Sdate}.uf
          fi 
          rm ${Sdate}_icec.nc
        fi
      done 
    done   # end of each date
  done
done

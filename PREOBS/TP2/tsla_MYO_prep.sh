
HomeAdir=/cluster/home/xiejp/REANALYSIS_TP5
#Mdir=/cluster/home/xiejp/REANALYSIS/FILES
Mdir=${HomeAdir}/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*.uf .
ln -sf ${Mdir}/re_sla.nc re_sla.nc 

if [ ! -s ./prep_obs ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ5/Prep_Fram/prep_obs .
fi

Idir=${HomeAdir}/PREOBS/Infile

Outdir=/cluster/work/users/xiejp/TP2_Reanalysis/DATA/TSLA
if [ ! -s ${Outdir} ]; then
  mkdir ${Outdir}
fi

Jdy0=24474
Jdy1=24474
#Jdy1=25100

#Satn="al c2 e1 e2 en enn g2 h2 j1 j1g j1n j2 tp tpn"
#Satn="al alg c2 h2 j2 j2n j3"

Satn="al alg c2 h2 h2g j2g j2n j3 s3a"

#Satn="alg"


for jday in `seq ${Jdy0} ${Jdy1}`; do
  rm observations*
  rm observations*
  if [ ! -s ${Outdir}/obs_TSLA_${jday}.nc -o ! -s ${Outdir}/obs_TSLA_${jday}.uf ]; then
     ifile=0
     for isat in ${Satn}; do
       Fnam=sla_${jday}_${isat}.nc
       if [ -r ./data1/${Fnam} ]; then
          ln -sf ./data1/${Fnam} .
          let ifile=ifile+1
       fi
     done
     if [ ${ifile} -gt 0 ]; then
        sed "s/JULDDATE/${jday}/" ${Idir}/infile.data_tslaMYO > infile.data
        exit
       ./prep_obs TSLA 1 

        if [ -s observations.uf -a -s observations-TSLA.nc ]; then
           mv observations.uf ${Outdir}/obs_TSLA_${jday}.uf
           mv observations-TSLA.nc ${Outdir}/obs_TSLA_${jday}.nc
           rm sla_${jday}_*.nc
        fi
     fi
  fi  
done

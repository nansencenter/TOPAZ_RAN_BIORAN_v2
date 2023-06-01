
Mdir=/cluster/home/xiejp/REANALYSIS/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*.uf .
ln -sf ${Mdir}/re_sla.nc re_sla.nc 

if [ ! -s ./prep_obs ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Fram/prep_obs .
fi

Idir=/cluster/home/xiejp/TP4_Reanalysis/preobs_scripts/Infile/
Odir0=/cluster/work/users/xiejp/DATA/data0/tsla
Odir1=/cluster/work/users/xiejp/DATA/data0/tsla_nrt
Odir=/cluster/work/users/xiejp/work_2018/Data/TSLA
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

Ndir=./data0
if [ ! -r ${Ndir} ]; then
  mkdir ${Ndir}
fi

Jdy0=23892
Jdy1=23953
#Jdy1=24441


Jdy0=24800
Jdy1=25230

#Satn="al c2 e1 e2 en enn g2 h2 j1 j1g j1n j2 tp tpn"
#Satn="al alg c2 h2 j2 j2n j3"

Satn="al alg c2 h2 h2g j2g j2n j3 s3a"


ilink=0
# change the linking name
if [ ${ilink} -eq 1 ]; then
  for Jdy in `seq ${Jdy0} ${Jdy1}`; do
    Sdate=`jultodate ${Jdy} 1950 1 1`
    Ny=`echo ${Sdate:0:4}`
    Nm=`echo ${Sdate:4:2}`
    Nd=`echo ${Sdate:6:2}`
    for isat in ${Satn}; do
      Fstr=${isat}_phy_vxxc_l3_${Sdate:0:8}
      nn=$(ls ${Odir0}/dt_global_${Fstr}_*.nc | wc -l)
      if [ ${nn} -eq 1 ]; then
        ls ${Odir0}/dt_global_${Fstr}_*.nc >00.txt
        Fnam0=`cat 00.txt`
        ln -sf ${Fnam0} ${Ndir}/sla_${Jdy}_${isat}.nc 
      fi
    done   # cycle for satellite
  done
fi

for jday in `seq ${Jdy0} ${Jdy1}`; do
  rm observations*
  rm observations*
  if [ ! -s ${Odir}/obs_TSLA_${jday}.nc -o ! -s ${Odir}/obs_TSLA_${jday}.uf ]; then

  ifile=0
  #module restore system
  module load NCO/4.6.6-intel-2017a 
  for isat in ${Satn}; do
     # combine the daily into the 7 days
     lday=0
     rm out*.nc
     for idy in `seq 0 6`; do
       let Ndy=jday-idy-1
       Fnam=data0/sla_${Ndy}_${isat}.nc
       echo ${Fnam} ${lday}
       if [ -s ${Fnam} ]; then
         echo ${Fnam} ${lday} ${Ndy}
         cp ${Fnam} tmp.nc
         ncks -x -v adt_unfiltered tmp.nc out.nc
         ncrename -d time,record out.nc  
         ncks --mk_rec_dmn record out.nc out${lday}.nc
         rm tmp.nc out.nc
         let lday=lday+1
       fi
     done
     if [ ${lday} -gt 0 ]; then
       Fnam=sla_${jday}_${isat}.nc
       [ -f ${Fnam} ] && rm ${Fnam}
       case ${lday} in
         2) ncrcat out0.nc out1.nc ${Fnam} ;;
         3) ncrcat out0.nc out1.nc out2.nc ${Fnam} ;;
         4) ncrcat out0.nc out1.nc out2.nc out3.nc ${Fnam} ;;
         5) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc ${Fnam} ;;
         6) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc out5.nc ${Fnam} ;;
         7) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc out5.nc out6.nc ${Fnam} ;;
         *) cp out0.nc ${Fnam} ;;
       esac
       ncrename -d record,time ${Fnam}  
       let ifile=ifile+1
       rm *.tmp
     fi
  done
  if [ ${ifile} -gt 0 ]; then
     sed "s/JULDDATE/${jday}/" ${Idir}/infile.data_tslaMYO > infile.data

#    module restore system
#    source /nird/home/xiejp/bash_profile_enkf-default

    ./prep_obs TSLA 1 

     if [ -s observations.uf -a -s observations-TSLA.nc ]; then
        mv observations.uf ${Odir}/obs_TSLA_${jday}.uf
        mv observations-TSLA.nc ${Odir}/obs_TSLA_${jday}.nc
        rm sla_${jday}_*.nc
     fi
     rm out*.nc
  fi

  fi  
done

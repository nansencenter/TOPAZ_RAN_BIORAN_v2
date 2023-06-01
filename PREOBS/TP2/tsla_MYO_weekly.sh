# link the download tsla file and change the file name with juliandate
# To create the collected file for during the previous week.
#


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

Odir0=/cluster/work/users/xiejp/DATA/data0/tsla
Odir1=/cluster/work/users/xiejp/DATA/data0/tsla_nrt

Odir=/cluster/work/users/xiejp/TP2_Reanalysis/DATA/TSLA
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

Ndir=./data0
if [ ! -r ${Ndir} ]; then
  mkdir ${Ndir}
fi

Jdy0=24451
#Jdy1=24451
Jdy1=25100

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
      #Fstr=${isat}_phy_vxxc_l3_${Sdate:0:8}
      Fstr=${isat}_phy_l3_${Sdate:0:8}
      nn=$(ls ${Odir0}/dt_global_${Fstr}_*.nc | wc -l)
      if [ ${nn} -eq 1 ]; then
        ls ${Odir0}/dt_global_${Fstr}_*.nc >00.txt
        Fnam0=`cat 00.txt`
        ln -sf ${Fnam0} ${Ndir}/sla_${Jdy}_${isat}.nc 
      fi
    done   # cycle for satellite
  done
fi

# Switch for debugging the script
#Jdy1=24452
#Satn="alg"

module load StdEnv
module restore system
#module load NCO/4.6.6-intel-2017a 
##module load NCO/4.7.2-intel-2018a 
module load NCO/4.7.7-intel-2018b
## there are a bug to broken out when ncrename
##module swap HDF5/1.8.18-intel-2017a-HDF5-1.8.18 HDF5/1.10.5-iimpi-2019a
module swap HDF5/1.10.2-intel-2018b HDF5/1.10.5-iimpi-2019a


for jday in `seq ${Jdy0} ${Jdy1}`; do
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
     echo ${lday}
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
     if [ -r ${Fnam} ]; then
        mv ${Fnam} data1/.
     fi
     rm *.tmp
   fi
done
done

module load StdEnv

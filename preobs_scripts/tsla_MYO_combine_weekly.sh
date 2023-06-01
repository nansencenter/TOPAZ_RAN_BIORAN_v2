

#Odir0=/cluster/work/users/xiejp/DATA/data0/tsla
Odir0=/cluster/work/users/xiejp/TP4_Reanalysis/downobs_2022/tsla0


Ndir=./daily
if [ ! -r ${Ndir} ]; then
  mkdir ${Ndir}
fi

[ ! -r ./weekly ] && mkdir weekly

Jdy_0=$(datetojul 1993 1 1 1950 1 1)
Jdy_1=$(datetojul 2021 1 1 1950 1 1)

#Satn="al c2 e1 e2 en enn g2 h2 j1 j1g j1n j2 tp tpn"
#Satn="al alg c2 h2 h2g j2 j2g j2n j3 s3a s3b"

# reprocess for the satellites in 2022:
Satsall2022="al alg c2 c2n e1 e1g e2 en enn g2 h2a h2ag h2b j1 j1g j1n j2 j2g j2n j3 s3a s3b tp tpn"
Sats="al alg c2 c2n e1 e1g e2 en enn g2 h2a h2ag h2b j1 j1g j1n j2 j2g j2n j3 s3a s3b tp tpn"



ilink=1
# change the linking name
if [ ${ilink} -eq 1 ]; then
  for Jdy in `seq ${Jdy_0} ${Jdy_1}`; do
    Sdate=`jultodate ${Jdy} 1950 1 1`
    Ny=`echo ${Sdate:0:4}`
    Nm=`echo ${Sdate:4:2}`
    Nd=`echo ${Sdate:6:2}`
    for isat in ${Sats}; do
      Fstr=${isat}_phy_l3_${Sdate:0:8}
      ls ${Odir0}/dt_global_${Fstr}_*.nc > ${isat}_link.log
      #nn=$(ls ${Odir0}/dt_global_${Fstr}_*.nc | wc -l)
      nn=$(sed -n '$=' ${isat}_link.log)
      if [ -s ${isat}_link.log ]; then
         nn=$(sed -n '$=' ${isat}_link.log)
	 if [ $nn -eq 1 ]; then     
            Fnam0=`cat ${isat}_link.log`
	    echo ${Fnam0}
            ln -sf ${Fnam0} ${Ndir}/sla_${Jdy}_${isat}.nc 
         fi
	 rm ${isat}_link.log
      fi
    done   # cycle for satellite
  done
fi

Sats="al alg c2 c2n en enn g2 h2a h2ag h2b j2 j2g j2n j3 s3a s3b"
Jdy1=$(datetojul 2017 1 1 1950 1 1)
Jdy2=$(datetojul 2021 1 1 1950 1 1)

#(( Jdy1 = ${Jdy_0} + 6 ))
#(( Jdy2 = ${Jdy_1} + 0 ))
#let Jdy0=Jdy0+6

#module restore system
#module load NCO/4.7.2-intel-2018a 
module load NCO/4.7.9-intel-2018b

for jday in `seq ${Jdy1} ${Jdy2}`; do

  for isat in ${Sats}; do
     # combine the daily into the 7 days
     lday=0
     rm out*.nc
     for idy in `seq 0 6`; do
       let Ndy=jday-idy-1
       Fnam=${Ndir}/sla_${Ndy}_${isat}.nc
       echo ${Fnam} ${lday}
       if [ -s ${Fnam} ]; then
         echo ${Fnam} ${lday} ${Ndy}
         cp ${Fnam} tmp.nc
       #  ncks -x -v adt_unfiltered tmp.nc out.nc
         ncrename -d time,record tmp.nc  
         ncks --mk_rec_dmn record tmp.nc out${lday}.nc
         rm tmp.nc 
         let lday=lday+1
       fi
     done
     echo 'lday=' $lday
     if [ ${lday} -gt 0 ]; then
       Fnam=sla_${jday}_${isat}.nc
       [ -f ${Fnam} ] && rm ${Fnam}
       case ${lday} in
         2) ncrcat out0.nc out1.nc ${Fnam} ;;
         3) ncrcat out0.nc out1.nc out2.nc ${Fnam} ;;
         4) ncrcat out0.nc out1.nc out2.nc out3.nc  ${Fnam} ;;
         5) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc  ${Fnam} ;;
         6) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc out5.nc  ${Fnam} ;;
         7) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc out5.nc out6.nc  ${Fnam} ;;
         *) cp out0.nc ${Fnam} ;;
       esac
       ncrename -d record,time ${Fnam}  
       rm *.tmp
       [ -f ${Fnam} ] && mv ${Fnam} weekly/.
     fi
  done
done


Mdir=/home/nersc/xiejp/REANALYSIS/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*.uf .
ln -sf ${Mdir}/re_sla.nc re_sla.nc 

Idir=/home/nersc/xiejp/work_2015/TOPAZ_Reanalysis/script/pre_obs/
if [ ! -s ./prep_obs ]; then
  ln -sf /home/nersc/xiejp/enkf/EnKF-MPI-TOPAZ2015/Prep_Routines/prep_obs .
fi

Odir0=/work/xiejp/work_2015/Data/data0/tsla
Odir=/work/xiejp/work_2015/Data/TSLA
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

Ndir=./data0
if [ ! -r ${Ndir} ]; then
  mkdir ${Ndir}
fi

Jdy0=23350
Jdy1=23741

ilink=0
# change the linking name
if [ ${ilink} -eq 0 ]; then
  for Jdy in `seq ${Jdy0} ${Jdy1}`; do
    Sdate=`jultodate ${Jdy} 1950 1 1`
    Ny=`echo ${Sdate:0:4}`
    Nm=`echo ${Sdate:4:2}`
    Nd=`echo ${Sdate:6:2}`
    for isat in al c2 en j1 g2 h2 enn j1g j1n j2 ; do
      Fstr=${isat}_sla_vxxc_${Sdate:0:8}
      nn=$(ls ${Odir0}/dt_global_${Fstr}_*.nc | wc -l)
      if [ ${nn} -eq 1 ]; then
        ls ${Odir0}/dt_global_${Fstr}_*.nc >00.txt
        Fnam0=`cat 00.txt`
        ln -sf ${Fnam0} ${Ndir}/sla_${Jdy}_${isat}.nc 
      fi
    done   # cycle for satellite
  done
fi


module load nco

for jday in `seq ${Jdy0} ${Jdy1}`; do
#for jday in `seq 21189 21189`; do
  lday=0
  rm observations*
  rm observations*
  for idy in `seq 0 6`; do
     let Ndy=jday-idy
     rm sla_?????_*.nc     
     ifile=0
     for isat in c2 en j1 g2 enn j1g j1n j2 ; do
        Fnam=./data0/sla_${Ndy}_${isat}.nc
        if [ -s ${Fnam} ]; then
          let ifile=ifile+1
          ln -sf ${Fnam} .
        fi
     done
     if [ ${ifile} -gt 0 ]; then
        sed "s/JULDDATE/${Ndy}/" ${Idir}Infile/infile.data_tslaMYO > infile.data
        ./prep_obs tsla ${idy}
        if [ -s observations.uf -a -s observations-TSLA.nc ]; then
           if [ ${idy} -eq 0 ]; then
             mv observations.uf obs_TSLA_${jday}.uf
             mv observations-TSLA.nc obs_TSLA_${jday}.nc
           else
             mv observations.uf obs_TSLA_${jday}_${idy}.uf
             mv observations-TSLA.nc obs_TSLA_${jday}_${idy}.nc
             let lday=lday+1
           fi
        fi
     fi
  done
  
  if [ ${lday} -gt 0 ];then
    # combine the nc files
    rm out*
    # prepare the first observation file
    ncecat -O obs_TSLA_${jday}.nc out0.nc
    ncpdq -O -a nobs,record out0.nc out0.nc
    ncwa -O -a record out0.nc out0.nc
    # change the dimension of nobs in other files from fixed into unlimited
    for ii in `seq 1 ${lday}`; do
      ncecat -O obs_TSLA_${jday}_${ii}.nc out${ii}.nc
      ncpdq -O -a nobs,record out${ii}.nc out${ii}.nc
      ncwa -O -a record out${ii}.nc out${ii}.nc
    done
    # series connect the files 
    rm obs_TSLA_${jday}*.nc 
    case ${lday} in
      1) ncrcat out0.nc out1.nc obs_TSLA_${jday}.nc ;;
      2) ncrcat out0.nc out1.nc out2.nc obs_TSLA_${jday}.nc ;;
      3) ncrcat out0.nc out1.nc out2.nc out3.nc obs_TSLA_${jday}.nc ;;
      4) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc obs_TSLA_${jday}.nc ;;
      5) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc out5.nc obs_TSLA_${jday}.nc ;;
      *) ncrcat out0.nc out1.nc out2.nc out3.nc out4.nc out5.nc out6.nc obs_TSLA_${jday}.nc ;;
    esac
    #echo 'lday=' ${lday}
    # change the dimension of nobs from unlimited into fixed
    ncecat -O -h obs_TSLA_${jday}.nc out.nc
    ncwa -O -a record out.nc out.nc
    mv out.nc obs_TSLA_${jday}.nc

    for ii in `seq 1 ${lday}` ; do
    #  cmdstr=$(echo ${cmdstr}"observations-TSLA-"${ii}".nc ")
       Fnam=obs_TSLA_${jday}_${ii}.uf
       if [ -s ${Fnam} ]; then
          cat ${Fnam} >> obs_TSLA_${jday}.uf
       fi
    done
  fi
  if [ -s obs_TSLA_${jday}.uf ]; then
     mv obs_TSLA_${jday}.uf ${Odir}/.
     mv obs_TSLA_${jday}.nc ${Odir}/.
  fi
  rm obs_TSLA_${jday}_*.uf
done


Mdir=/cluster/home/xiejp/REANALYSIS_TP5/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths*.uf .
ln -sf ${Mdir}/meanssh*.uf .
ln -sf ${Mdir}/re_sla.nc .

Idir=/cluster/home/xiejp/REANALYSIS_TP5/preobs_scripts/Infile/

Odir0=/cluster/work/users/xiejp/DATA/data0/idrft
Odir=/cluster/work/users/xiejp/work_2023/Data_TP5/IDRFT
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi

if [ ! -s ./prep_obs ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Fram/prep_obs .
fi

Jdy0=25700
Jdy1=26700


for Jdy in `seq ${Jdy0} ${Jdy1}`; do
  Sdate=`jultodate ${Jdy} 1950 1 1`
  Ny=`echo ${Sdate:0:4}`
  Nm=`echo ${Sdate:4:2}`
  Nd=`echo ${Sdate:6:2}`

  for ii in `seq 1 5`; do
    let j_dy2=Jdy-ii
    let j_dy1=j_dy2-2
    sday1=$(jultodate ${j_dy1} 1950 1 1)
    sday2=$(jultodate ${j_dy2} 1950 1 1)
    #Fnc=ice_drift_nh_polstere-625_multi-oi_${sday1}1200-${sday2}1200.nc
    Fnc=ice_drift_nh_polstere-625_multi-oi_${sday2}1200.nc

    if [ -s ${Odir0}/${Fnc} ]; then
      sed "s/JULDDATE/${Jdy}/" ${Idir}/infile.data_idrft_osisaf | sed "s/idrfS/idrf${ii}/" > infile.data
      ln -sf ${Idir}/idrft_osisaf.hdr .
      ln -sf ${Odir0}/${Fnc} ${Jdy}_idrft.nc
      Ffix=${ii}_${Jdy}
      echo ${Fnc} ${Ffix}
      if [ ! -s ${Odir}/obs_IDRFT${Ffix}.uf ]; then
        ./prep_obs
        if [ -s observations.uf ]; then
          mv observations.uf ${Odir}/obs_IDRFT${Ffix}.uf
          mv observations-DX${ii}.nc ${Odir}/obs_DX${Ffix}.nc
          mv observations-DY${ii}.nc ${Odir}/obs_DY${Ffix}.nc
        fi 
     fi

      rm ${Jdy}_idrft.nc
    fi
  done  # end cycle in one date
done


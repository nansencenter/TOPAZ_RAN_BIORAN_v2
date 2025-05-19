#!/bin/bash
#
# Create SSH statistics in netcdf files:
#
#   re_sla.nc : ssh representativeness error (variance [m2])
#   meanssh.nc: mean ssh [m]
#
# from hycom hindcast files (archm*.[a,b])
#

#-- HYCOM_BIN and HYCOM_ARCH should be predefined

#HYCOM_BIN=/cluster/home/wakamatsut/TP2/NERSC-HYCOM-CICE_BIORANv2/hycom/MSCPROGS/bin # location of ensstat_field
#HYCOM_ARCH=/nird/datalake/NS9481K/shuang/TP2_output/expt_04.2                       # hycom archive files

#[ -d TMP ] && rm -rf TMP
mkdir -p TMP

#-- range of years for statistics

Y1=1999
Y2=2018

#-- 

pushd TMP

ln -sf ../regional* .
ln -sf ../blkdat.input .

#for iy in `seq $Y1 $Y2`; do
#    ln -sf ${HYCOM_ARCH}/archm.${iy}*.? .
#done

for ii in $(seq 1 7); do
    echo "lag-$ii day statistics"
    Fnew=srfhgt_$ii.nc
    if [ ! -r ${Fnew} ]; then
        echo "Calc ${Fnew}"
        for iy in `seq $Y1 $Y2`; do
           jj=0
           while [ $jj -le 366 ]; do
              jj=$((jj + ii))
              Fab=${HYCOM_ARCH}/archm.${iy}_$(printf "%03d\n" $jj)_12
              if [ -r ${Fab}.a -a -r ${Fab}.b ]; then
		  #echo $Fab
                  ln -sf ${Fab}.? .
              fi
           done
        done

	#-- calculate statistics of sequenstial data
	${HYCOM_BIN}/ensstat_field srfhgt 0 srfhgt 0 archm.*.a
        if [ -r ensstat_field.nc ]; then
            mv ensstat_field.nc ${Fnew}
	    echo "mv ensstat_field.nc ${Fnew}"
        fi
        rm archm.*.?
    else
	echo "Skip"
    fi
done

idm=$(awk 'NR==1 {print $1}' regional.grid.b); echo "idm: $idm"
jdm=$(awk 'NR==2 {print $1}' regional.grid.b); echo "jdm: $jdm"

#
# create ensemble mean of covariances
#

module load NCO/5.1.9-iomkl-2022a

#-- daily ssh mean

varname0="ave_asrfhgt00"
rm meanssh.nc
ncks -v ${varname0} srfhgt_1.nc out.nc
ncrename -O -v ${varname0},meanssh out.nc
ncap2 -O -s "meanssh=meanssh/9.806" out.nc meanssh.nc
rm out.nc

#-- ssh variance ensemble mean (representativeness error)

varname0="cov_asrfhgt00_bsrfhgt00"

for ii in $(seq 1 7); do
  ncks -v ${varname0} srfhgt_$ii.nc out.nc
  ncrename -O -v ${varname0},var_ssh1 out.nc
  ncap2 -O -s "var_ssh1=var_ssh1/(9.806*9.806)" out.nc out${ii}.nc
  rm out.nc
done

rm re_sla.nc
ncea -O out*.nc mean.nc
ncatted -a _FillValue,var_ssh1,o,f,0.0 mean.nc out0.nc
ncrename -v var_ssh1,re_sla out0.nc re_sla.nc
rm out*.nc mean.nc

module unload NCO/5.1.9-iomkl-2022a

popd

if [ -r TMP/meanssh.nc ]; then
    echo "TMP/meanssh.nc > meanssh${idm}x${jdm}.nc"
    mv TMP/meanssh.nc meanssh${idm}x${jdm}.nc
    
fi

if [ -r TMP/re_sla.nc ]; then
    echo "TMP/re_sla.nc > re_sla${idm}x${jdm}.nc"
    mv TMP/re_sla.nc re_sla${idm}x${jdm}.nc
fi

    

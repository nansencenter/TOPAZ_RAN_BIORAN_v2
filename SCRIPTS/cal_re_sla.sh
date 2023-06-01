
bin_ensstat=/cluster/home/xiejp/NERSC-HYCOM-CICE/hycom/MSCPROGS/src/Ensstat/ensstat_field

wrkdir=/cluster/work/users/xiejp/TOPAZ/TP5a0.06/expt_03.0/SCRATCH

cd ${wrkdir}

# years
Y1=1993
Y2=2012

varnam='srfhgt'
Fini=ensstat_field.nc

# create the variance for different lag days
for ii in `seq 1 7`; do
  rm archm.*.?
  Fnew=${varnam}_$ii.nc
  if [ ! -r ${Fnew} ]; then
     if [ $ii -eq 1 ]; then
        for iy in `seq $Y1 $Y2`; do
           ln -sf ../data/archm.${iy}*.? .
        done
     else
        for iy in `seq $Y1 $Y2`; do
           jj=0
           while [ $jj -le 366 ]; do
              jj=$(( $jj + $ii ))
              Fab=../data/archm.${iy}_`echo 00${jj}|tail -4c`_12
              if [ -r ${Fab}.a -a -r ${Fab}.b ]; then
                 ln -sf ${Fab}.? .
              fi
           done
        done
     fi
     ${bin_ensstat} srfhgt 0 srfhgt 0 archm.*.a
     if [ -r ${Fini} ]; then
        mv ${Fini} ${Fnew} 
     fi
  fi
done


stop

module load NCO/4.6.6-intel-2017a

rm out*.nc

varname0="cov_asrfhgt00_bsrfhgt00"

ncks -v ${varname0} srfhgt_1.nc out.nc
ncrename -O -v ${varname0},var_ssh1 out.nc
ncap2 -O -s "var_ssh1=var_ssh1/(9.806*9.806)" out.nc out1.nc
rm out.nc

for ii in `seq 2 7`; do
  ncks -v ${varname0} srfhgt_$ii.nc out.nc
  ncrename -O -v ${varname0},var_ssh1 out.nc
  ncap2 -O -s "var_ssh1=var_ssh1/(9.806*9.806)" out.nc out${ii}.nc
  rm out.nc
  #ncrename -v var_asrfhgt00,var_assh$ii srfhgt_$ii.nc out.nc
  #ncks -A out.nc out0.nc
  #rm out.nc
done

#ncap2 -s "var_1=var_assh4-var_assh1" -v out0.nc out_1.nc
#ncap2 -s "var_1=var_assh5-var_assh1" -v out0.nc out_2.nc
#ncap2 -s "var_1=var_assh5-var_assh2" -v out0.nc out_3.nc
#ncap2 -s "var_1=var_assh6-var_assh2" -v out0.nc out_4.nc
#ncap2 -s "var_1=var_assh7-var_assh3" -v out0.nc out_5.nc
#
#ncatted -a _FillValue,var_nm,o,f,0.0 in.nc out.nc

ncea -O out*.nc mean.nc
ncatted -a _FillValue,var_ssh1,o,f,0.0 mean.nc out0.nc
ncrename -v var_ssh1,re_sla out0.nc re_sla.nc
rm out*.nc mean.nc

# mask the nagative values

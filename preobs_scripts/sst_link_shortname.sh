
# used to link the initial SST: 2017/01/20170128120000-C3S-L4_GHRSST-SSTdepth-OSTIA-GLOB_ICDR2.0-v02.0-fv01.0.nc 
# to the current diretory by the shorten nick name
# as cdr2_sst_<juliandate>.nc


Y1=2022
Y2=2022

[ ! -r ./data0 ] && mkdir data0

for iyy in `seq $Y1 $Y2`; do
   J1=$(datetojul $iyy 1 1 1950 1 1)
   J2=$(datetojul $iyy 12 31 1950 1 1)
   echo $iyy ': ' $J1 '~' $J2
   Sdate1=$(jultodate $J1 1950 1 1)
   Sdate2=$(jultodate $J2 1950 1 1)
   #echo  '    : ' $Sdate1 '~' $Sdate2

   for ii in `seq $J1 $J2`; do
      Sdate=$(jultodate $ii 1950 1 1)
      Subdir=/cluster/work/users/xiejp/DATA/data0/sst/${Sdate:0:4}/${Sdate:4:2}/
      Fini=${Sdate:0:8}120000-C3S-L4_GHRSST-SSTdepth-OSTIA-GLOB_ICDR2.0-v02.0-fv01.0.nc
      Fupd=cdr2_sst_${ii:0:5}.nc

      if [ -s ${Subdir}${Fini} ]; then
         ln -sf ${Subdir}${Fini} ./data0/${Fupd}
         [ $ii -eq $J2 ] && echo ${Subdir}${Fini} ${Fupd}
      fi



   done











done

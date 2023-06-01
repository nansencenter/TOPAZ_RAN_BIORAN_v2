
Sourdir='/cluster/projects/nn9481k/jiping/TP5_preobs/'


Rundir='/cluster/work/users/xiejp/TP5_Reanalysis/OBS'

[ ! -r ${Rundir} ] && exit "No directory of ${Rundir}"

cd ${Rundir}


# if now any input parameters

if [ $# -lt 1 ]; then
   #tarfiles="ICEC_TP5 SAL_TP5 SST_TP5 TEM_TP5 TSLA_TP5_24472-25932"
   tarfiles="ICEC_TP5 SAL_TP5 SST_TP5 TEM_TP5"

   for itar in ${tarfiles}; do
      ifile=${itar}.tgz
      if [ -s ${Sourdir}${ifile} ]; then
         tar -xzvf ${Sourdir}${ifile}
      fi
   done

else
   # freshening the present files
   Obsname="ICEC SAL TEM SST TSLA"
   for iobs in ${Obsname}; do
      cd ${Rundir}
      if [ -s ./${iobs} ]; then
         cd ./${iobs}
         [ ! -r ./tmp ] && mkdir tmp
         cp obs_${iobs}_*.* tmp/.
         mv tmp/*.* .
      fi
   done
fi


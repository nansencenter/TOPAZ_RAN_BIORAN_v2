#!/bin/bash

set -euo pipefail

echo "     in $PWD"
echo ""
echo "     JULDAY    = ${JULDAY}"
echo "     JULDAYNXT = ${JULDAYNXT}"

# specs for analysis day
#
year=`${BINDIR}/jultodate $JULDAY 1950 1 1 | cut -c1-4`
echo "     year = $year"
(( day = ${JULDAY} - `${BINDIR}/datetojul $year 1 1 1950 1 1`  + 1 ))
day=`printf "%03d" $day`
echo "     day = $day"

(( iday = ${JULDAY} ))
Sdate=$(${BINDIR}/jultodate ${iday} 1950 1 1)
Strdate=${Sdate:0:4}-${Sdate:4:2}-${Sdate:6:2}

# link the hycom restart files
#
forecast_prefix="${FORECASTDIR}/restart.${year}_${day}_00_0000"
forecast_ice_prefix="${FORECASTDIR}/cice/iced.${Strdate}-00000"

echo "     forecast_prefix=${forecast_prefix}"
echo "     forecast_ice_prefix=${forecast_ice_prefix}"

echo ""
cd ${ANALYSISDIR}
echo "     in $PWD"

for ((e = 1; e <= ${ENSSIZE}; ++e))
do
    mem=`printf "%03d\n" $e`
    prefix="${forecast_prefix}_mem${mem}"
    ice_prefix="${forecast_ice_prefix}_mem${mem}"

    echo "     ln -sf ${prefix}.a      forecast${mem}.a"
    echo "     ln -sf ${prefix}.b      forecast${mem}.b"
    echo "     ln -sf ${ice_prefix}.nc ice_forecast${mem}.nc"
done

# link the hycom daily files (archm.*)
#
modeldaily_prefix="${FORECASTDIR}/archm."   

echo ""
echo "     modeldaily_prefix=${modeldaily_prefix}"

# # size of analysis window [day]
#
(( dwindow = $JULDAYNXT - $JULDAY )) 
echo $dwindow
(( iend = $dwindow - 1 ))

#
# TP4 Reanalysis system assimilate past 7 days TSLA data. In order to match timing of
# TSLA data with model output, preoare 7 days daily mean file from previous analysis.
#
if (( `expr match "${OBSTYPES}" TSLA` > 0 ))
then
	
for ((i = 0; i <= $iend; i++))
do
    (( juldaynow = $JULDAY - $i - 1))
    yearnow=`${BINDIR}/jultodate $juldaynow 1950 1 1 | cut -c1-4`
    Jday=`${BINDIR}/datetojul $yearnow 1 1 1950 1 1`

    if [ ${juldaynow} -eq ${Jday} ]; then
      daynow=0
    else
      let daynow=${juldaynow}-${Jday} 
    fi
    daynow=`printf "%03d" $daynow`
    
    Fdaily=${modeldaily_prefix}${yearnow}_${daynow}_12
    Fnew=forecast_daily_`echo 0$i|tail -3c`
    
    echo "     ln -sf ${Fdaily}.a ${Fnew}.a "
    echo "     ln -sf ${Fdaily}.b ${Fnew}.b "

    Fdaily_SSH=${Fdaily}_SSH
    Fnew_SSH=model_TSSH_`echo 0$i|tail -3c`

    echo "     ln -sf ${Fdaily_SSH}.uf ${Fnew_SSH}.uf"
done

fi

#
# TP4 Reanalysis system assimilate past 7 days ice drift data. In order to match timing of
# TSLA data with model output, preoare 7 days daily mean file from previous analysis.
#
if (( `expr match "${OBSTYPES}" ICEDRIFT` > 0 ))
then
	
for ((i = 0; i <= $iend; i++))
do
    (( juldaynow = $JULDAY - $i - 1))

    # link the ice snapshot including ice drift
    #
    Datenow=$(${BINDIR}/jultodate ${juldaynow} 1950 1 1)
    Ficesnap=${FORECASTDIR}/cice/iceh.${Datenow:0:4}-${Datenow:4:2}-${Datenow:6:2}_ens.nc 
    Ficenew=model_ICEDRIFT_0"$i".nc

    echo "     ln -sf ${Ficesnap} ${Ficenew}"
    echo "     ln -sf ${Ficesnap} ."
    echo ""
done

# linking the ice drift files simulated by model daily.
#
if [ -s "${PREPOBSDIR}/observations.uf.IDRFT" ]; then
   cd "${ANALYSISDIR}"
   for ii in `seq 1 5`; do
       (( juldaynow = $JULDAY - $ii ))
       Ddate=$(jultodate ${juldaynow} 1950 1 1)
       Ficesnap=iceh.${Ddate:0:4}-${Ddate:4:2}-${Ddate:6:2}_ens.nc 
       Ficedrift=iceh.${Ddate:0:4}-${Ddate:4:2}-${Ddate:6:2}_ens.uf 
       echo ${ii} ${Ficedrift} ${Ddate}
       ${BINDIR}/pre_icedrift.sh ${Ficesnap} model_ICEDRIFT_OSISAF${ii}.uf 
   done
   exit
fi

fi

# link observations
#
if [ -f "{PREPOBSDIR}/observations.uf" ]; then
    #ln -sf "${PREPOBSDIR}"/observations.uf .
    echo "ln -sf "${PREPOBSDIR}"/observations.uf ."
    
    #cp "${PREPOBSDIR}"/observations-*.nc .
    for obsfile in "${PREPOBSDIR}"/observations-*.nc
    do
	[ -f $obsfile ] && cp $obsfile . 
    done
fi

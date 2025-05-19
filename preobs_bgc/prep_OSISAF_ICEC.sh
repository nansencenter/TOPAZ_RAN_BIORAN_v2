#!/bin/bash

gdate=$1         # Gregorian date [YYYYMMDD]
CNFG=$2          # short name of hycom configuration [TP5|TP2]
DSRC=OSISAF_ICEC # name of dataset
DVAR=ICEC        # name of parameter
isplot="false"    # plot/save on map projections

if [ ! -s CMEMS/${DSRC}/${DVAR}_${gdate}.nc ]; then
  echo "#-------------------------"
  echo "# cmems_loader.py ${gdate} ${DSRC} full"
  echo "#-------------------------"
  python cmems_loader.py ${gdate} ${DSRC} full
fi

echo "#-------------------------"
echo "# prep_obs.sh $gdate $CNFG $DSRC $DVAR"
echo "#-------------------------"
bash prep_obs.sh $gdate $CNFG $DSRC $DVAR

if [ "$isplot" == "true" ]; then
  echo "#-------------------------"
  echo "# plot_prepobs.py $gdate $CNFG $DVAR"
  echo "#-------------------------"
  python plot_prepobs.py $gdate $CNFG $DSRC $DVAR
fi

exit 0

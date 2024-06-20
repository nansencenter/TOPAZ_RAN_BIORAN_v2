#!/bin/bash

gdate=20190601   # Gregorian date [YYYYMMDD]
CNFG=TP2         # short name of hycom configuration [TP5|TP2]
DSRC=ESACCI_SCHL # name of dataset
DVAR=SCHL        # name of parameter
isplot="true"    # plot/save on map projections

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

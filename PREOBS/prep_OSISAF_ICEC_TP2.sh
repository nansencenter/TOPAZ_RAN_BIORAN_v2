#!/bin/bash

gdate=20190601   # Gregorian date [YYYYMMDD]
CNFG=TP2         # short name of hycom configuration [TP5|TP2]
DSRC=OSISAF_ICEC # name of dataset
DVAR=ICEC        # name of parameter
isplot="true"    # plot/save on map projections

if [ ! -s CMEMS/${DSRC}/${DVAR}_${gdate}.nc ]; then
  echo "#-------------------------"
  echo "# cmems_loader.py"
  echo "#-------------------------"
  python cmems_loader.py ${gdate} ${DSRC} full
fi

echo "#-------------------------"
echo "# prep_obs.sh"
echo "#-------------------------"
bash prep_obs.sh $gdate $CNFG $DSRC $DVAR

if [ "$isplot" == "true" ]; then
  echo "#-------------------------"
  echo "# prep_obs.sh"
  echo "#-------------------------"
  python plot_prepobs.py $gdate $CNFG $DVAR
fi

exit 0

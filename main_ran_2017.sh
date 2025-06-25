#!/bin/bash

year=2017
cycle_ini=17
cycle_end=17

if [ ! -f schedule/cycle_$year.txt ]; then
    echo "Create analysis cycle table for $year"
    bash gen_schedule.sh $year
fi    

bash main_ran.sh $year $cycle_ini $cycle_end

exit

#!/bin/bash

year=2017

if [ ! -f schedule/cycle_$year.txt ]; then
    echo "Create analysis cycle table for $year"
    bash gen_schedule.sh $year
fi    

bash main_ran.sh 2017 17 17

exit

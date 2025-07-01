#!/bin/bash

julian_day=$1 # Julian day with origin at 1950 1 1
days_to_add=$((julian_day - 1))
gdate=$(date -d "1950-01-01 + $days_to_add days" +%Y%m%d) # YYYYMMDD

echo $gdate

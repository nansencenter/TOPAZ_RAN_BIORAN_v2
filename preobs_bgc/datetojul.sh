#!/bin/bash

target_date=$1 # YYYYMMDD
origin_secs=$(date -d "1950-01-01" --utc +%s)
target_secs=$(date -d "$target_date" --utc +%s)
juld=$(( (target_secs - origin_secs) / 86400 + 1 )) #  Julian day since 19491231

echo $juld

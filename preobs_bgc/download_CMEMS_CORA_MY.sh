#!/bin/bash

gdate=$1           # Gregorian date [YYYYMMDD/YYYYMM/YYYY]
isload="true"

#-- define available instrument types
#list_type=("BO" "CT" "SM" "BA" "GL" "OS" "RE" "TE" "XT" "PF")
list_type=("BO" "CT" "XT" "PF")

types_string=$(IFS=' '; echo "${list_type[*]}")
echo "#-------------------------"
echo "# cmems_cora_loader.py ${gdate} MY \"$types_string\" $isload"
echo "#-------------------------"
python cmems_cora_loader.py ${gdate} MY "$types_string" $isload

#!/bin/bash
#
# generate bgc data for prepobs from aggregated annual data file
#

sys_dir=/cluster/home/wakamatsut/bioran_v2 # TOPAZ reanalysis sytem folder

source ../common_specs.sh
BINDIR=$MSCPROGSBIN
echo $BINDIR

exit

gdnow=20170108

gdini=20170105
gdend=20170111

yini=${gdini:0:4}
yend=${gdend:0:4}

pushd ${sys_dir}/prepobs_bgc

mkdir -p bgc_data_extracted

for type in in_situ float
do	    

echo "Extract $type data for $gdnow"

mkdir -p bgc_data_tmp

#-- link corresponding annual files
cd bgc_data_tmp
for year in $yini $yend ; do
    ln -sf  ../bgc_data/bgc_${type}_${year}0101.txt .
done
echo $(ls bgc*.txt)
cd ..

#-- extract data machted with the specified range
cd config
sed \
  -e "s/DATEMIN/$gdini/g" \
  -e "s/DATEMAX/$gdend/g" \
  extract_data_${type}_bioran.toml > extract_data.toml
cd ..
make run-extract-data

#-- save extracted data for prepobs
cd bgc_data_extracted
if [ -f extracted_domain_data.txt ]; then
    mv extracted_domain_data.txt bgc_${type}_${gdini}-${gdend}.txt
    ln -sf bgc_${type}_${gdini}-${gdend}.txt bgc_${type}_${gdnow}.txt
fi    
cd ..

rm -rf bgc_data_tmp

done

popd

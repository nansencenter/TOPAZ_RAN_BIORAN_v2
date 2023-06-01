
cmem='025'

Inidir=$(pwd)

Rundir=/cluster/work/users/xiejp/TP5_Reanalysis/ANALYSIS

prg=/cluster/home/xiejp/REANALYSIS_Test/ASSIM/BIN/fixhycom

cd ${Rundir}

# clean the previous files
rm *fix*${cmem}* 


${prg} analysis${cmem}.a ${cmem} forecast${cmem}.nc ice_forecast${cmem}.nc 217


${Inidir}/test_icefield.sh ${cmem}  



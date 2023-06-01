

source /cluster/home/xiejp/bash_Python2.7_2018b

Rundir=/cluster/work/users/xiejp/TP5_Reanalysis/ANALYSIS
cd ${Rundir}

#cmem='025'

cmem=$1

prg=/cluster/home/xiejp/NERSC-HYCOM-CICE/bin/hycom_plot_field.py

for ivar in `seq 1 3`; do
   if [ $ivar -eq 1 ]; then
     ilev=514
     varnam='ficem'
     ${prg} 800 760 analysis${cmem}.a ${ilev} --clim=0,1
   elif [ $ivar -eq 2 ]; then
     ilev=515
     varnam='hicem'
     ${prg} 800 760 analysis${cmem}.a ${ilev} --clim=0,5
   elif [ $ivar -eq 3 ]; then
     ilev=516
     varnam='hsnwm'
     ${prg} 800 760 analysis${cmem}.a ${ilev} --clim=0,.5
   fi
   [ -s tst${ilev}.png ]  && mv tst${ilev}.png analysis${cmem}_${varnam}.png
done

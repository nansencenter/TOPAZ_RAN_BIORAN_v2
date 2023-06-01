
Mdir=/cluster/home/xiejp/REANALYSIS_TP5/FILES

ln -sf ${Mdir}/blkdat.input
ln -sf ${Mdir}/regional.* .
ln -sf ${Mdir}/grid.info .
ln -sf ${Mdir}/depths800x760.uf .
ln -sf ${Mdir}/newpos.uf .

# linking the performed program and infile
Idir=/cluster/home/xiejp/REANALYSIS_TP5/preobs_scripts/Infile/

if [ ! -s ./prep_obs_profile ]; then
  ln -sf /cluster/home/xiejp/enkf/EnKF-MPI-TOPAZ/Prep_Fram/prep_obs_profile .
fi

Odir0=/cluster/work/users/xiejp/DATA/data0/profile
Odir=/cluster/work/users/xiejp/work_2022/DataTP5/TSprofile
if [ ! -s ${Odir} ]; then
  mkdir ${Odir}
fi
for ity in SAL TEM ; do
  if [ ! -s ${Odir}/${ity} ]; then
    mkdir ${Odir}/${ity}
  fi
done

Tblist=0         # output the profile sources

Tmix=1          # try to find the combined profiles


Jdy0=24700
Jdy1=25933

for Jdy in `seq ${Jdy0} ${Jdy1}`; do
  Fobs=${Odir}/TEM/obs_TEM_${Jdy}.nc
  echo ${Fobs}
  if [ ! -s ${Fobs} ]; then
    rm *_prof.nc P_??_*.nc infile.data0 infiles.txt
 #   sed "s/OTY/${otype}/" ${Idir}/Infile/infile.data_coriolis | sed "s/OVAR/${var}/" > infile.data 
    i0=0
    for idy in `seq 0 6`; do
      let Ndy=Jdy-idy
      # deal with Argo profile
#      Fnam=${Odir0}/${Ndy}_prof.nc
#      if [ -s ${Fnam} ]; then
#        ln -sf ${Fnam} ${Ndy}_prof.nc      
#        if [ ${i0} -eq 0 ]; then
#          Sline=${Ndy}_prof.nc
#        else
#          Sline=$(echo ${Sline} ${Ndy}_prof.nc)
#        fi
#        let i0=i0+1
#      fi
      # add other profile
      if [ ${Tmix} -eq 1 ]; then
        Ndate=$(jultodate ${Ndy} 1950 1 1);
        echo $Ndate
        #for OTHP in BA CT GL OS RE TE XT ; do    # without Argo profiles
        #for OTHP in BA CT GL OS RE TE XT PF ; do   # including Argo profiles
        for OTHP in BA CT GL OS RE TE XT PF XB OC SH; do   # including Argo profiles
          if [ ${Ndate:0:4}x = '2021'x ]; then   #-a ${Ndate:4:2} -gt 6 ]; then
            Odir1=${Odir0}/2021
            Fnam=${Odir1}/CO_NRTOAGL01_${Ndate}_PR_${OTHP}.nc
          else
            Odir1=${Odir0}/${Ndate:0:4}
            Fnam=${Odir1}/CO_DMQCGL01_${Ndate}_PR_${OTHP}.nc
          fi
          echo $Fnam
          if [ -s ${Fnam} ]; then
            ln -sf ${Fnam} P_${OTHP}${idy}.nc      
            if [ ${i0} -eq 0 ]; then
               Sline=P_${OTHP}${idy}.nc
            else
               Sline=$(echo ${Sline} P_${OTHP}${idy}.nc)
            fi
            let i0=i0+1
          fi
        done   # cycle for different profiles
        # adding more in-situ data type from research ships/mooring data
        for OTHP in TS MO; do
          if [ ${Ndate:0:4}x = '2021'x ]; then   #-a ${Ndate:4:2} -gt 6 ]; then:/T:/T
            Odir1=${Odir0}/2021
            Fnam=${Odir1}/CO_NRTOAGL01_${Ndate}_TS_${OTHP}.nc
          else
            Odir1=${Odir0}/${Ndate:0:4}
            Fnam=${Odir1}/CO_DMQCGL01_${Ndate}_TS_${OTHP}.nc
          fi
          if [ -s ${Fnam} ]; then
            ln -sf ${Fnam} T_${OTHP}${idy}.nc      
            if [ ${i0} -eq 0 ]; then
               Sline=T_${OTHP}${idy}.nc
            else
               Sline=$(echo ${Sline} T_${OTHP}${idy}.nc)
            fi
            let i0=i0+1
          fi
        done
      fi
    done
    echo "i0=" $i0

    # preprare the infile.data0 saved as toto
    if [ ${i0} -gt 0 ]; then
       echo ${Jdy}
       echo ${Sline}
       sed "s/JDATE_coriolis.nc/${Sline}/" ${Idir}/infile.data_coriolis > infile.data0

       # deal with SAL and TEM respectively 
       for otype in SAL TEM ; do
          if [ ${otype}x = "SAL"x ]; then
             var=0.02
          elif [ ${otype}x = "TEM"x ]; then
             var=0.5
          fi
          sed "s/OTY/${otype}/" infile.data0 | sed "s/OVAR/${var}/" > infile.data 

          ./prep_obs_profile
          if [ -s observations-${otype}.nc -a observations.uf ]; then
             mv observations-${otype}.nc ${Odir}/${otype}/obs_${otype}_${Jdy}.nc
             mv observations.uf ${Odir}/${otype}/obs_${otype}_${Jdy}.uf
          fi 

          if [ ${Tblist} -eq 1 ]; then
             for bfile in Blacklist_Prof_QC observations_info AfterQC-${otype} ; do
                if [ -s ${bfile}.nc ]; then
                   mv ${bfile}.nc ${Odir}/${otype}/${bfile}-${Jdy}.nc  
                elif [ -s ${bfile}.uf ]; then
                   mv ${bfile}.uf ${Odir}/${otype}/${bfile}-${Jdy}.uf  
                elif [ -s ${bfile}.txt ]; then
                   mv ${bfile}.txt ${Odir}/${otype}/${bfile}-${Jdy}.txt  
                fi
             done
          fi
       done
    fi
    rm T_*.nc P_*.nc
  fi
done


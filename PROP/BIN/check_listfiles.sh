#!/bin/bash -l
#-rw-rw-r--. 1 xiejp xiejp 3861 Mar 25 16:27 cice_text.1
#-rw-rw-r--. 1 xiejp xiejp 3500 Mar 25 21:27 hycom_text.1

if [ $# != 1 ]; then
   echo "Require to one input for $0"
   echo " The input is the files list"
   exit 0
fi
Hlist=$1
if [ -s ${Hlist} ]; then
   N0=`sed -n "$=" ${Hlist}`

   # first check: file size
   Fsize=0
   for ii in `seq 1 $N0`; do
      Fmod=`sed -n "${ii}p" ${Hlist}`
      i0=${#Fmod}
      if [ ${ii} -eq 1 ]; then
         Flag=${Fmod:i0-2:2}
         Fsize=`stat -c%s ${Fmod}`
      else
         Ftmp=`stat -c%s ${Fmod}`
         [ ${Fsize} -lt ${Ftmp} ] && Fsize=${Ftmp}
      fi
   done
   Ftemp=${Hlist}_1 
   [ -s ${Ftemp} ] && rm ${Ftemp}
   echo `touch ${Ftemp}`
   for ii in `seq 1 $N0`; do
      Fmod=`sed -n "${ii}p" ${Hlist}`
      Ftmp=`stat -c%s ${Fmod}`
      if [ ${Ftmp} -eq ${Fsize} ]; then
         echo ${Fmod} >> ${Ftemp}
      fi
   done
   N0=`sed -n "$=" ${Ftemp}`
   mv ${Ftemp} ${Hlist}

   # second check: ncdump 
   if [  ${Flag}'aa' == 'ncaa' ]; then
      for ii in `seq 1 $N0`; do
         Fmod=`sed -n "${ii}p" ${Hlist}`
         i0=${#Fmod}
         Fchar='nc'
         if [ $ii -eq 1 ]; then
            Ftemp=${Fchar}_dump_${Hlist}.log
            [ -s ${Ftemp} ] && rm ${Ftemp}
            touch ${Ftemp} 
         fi
         Fline=$(ncdump -h ${Fmod} | sed -n '/time = UNLIMITED/p' | sed -n '/1 currently/p') 
         if [ ! -z "${Fline}" ]; then
            echo "${Fmod}" >> ${Ftemp}
         fi
      done 
      N0=`sed -n "$=" ${Ftemp}`
      mv ${Ftemp} ${Hlist}

   elif [  ${Flag}'aa' == '.aaa' ]; then
      echo 'checking .b file in hycom ' 
      Fsize=0
      for ii in `seq 1 $N0`; do
         Fmod0=`sed -n "${ii}p" ${Hlist}`
         i0=${#Fmod0}
         Fmod=${Fmod0:0:i0-1}b
         if [ ${ii} -eq 1 ]; then
            Fsize=`stat -c%s ${Fmod}`
         else
            Ftmp=`stat -c%s ${Fmod}`
            [ ${Fsize} -lt ${Ftmp} ] && Fsize=${Ftmp}
         fi 
      done
      Ftemp=${Hlist}_2 
      [ -s ${Ftemp} ] && rm ${Ftemp}
      echo `touch ${Ftemp}`
      for ii in `seq 1 $N0`; do
         Fmod0=`sed -n "${ii}p" ${Hlist}`
         i0=${#Fmod0}
         Fmod=${Fmod0:0:i0-1}b
         Ftmp=`stat -c%s ${Fmod}`
         if [ ${Ftmp} -eq ${Fsize} ]; then
            echo ${Fmod0} >> ${Ftemp}
         fi
      done
      N0=`sed -n "$=" ${Ftemp}`
      mv ${Ftemp} ${Hlist}
   fi

else
   echo "Cannot find the list: ${Hlist}"
   exit 0
fi


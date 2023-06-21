#! /usr/bin/env python
from netCDF4 import Dataset,MFDataset
import numpy as np
import sys
import os


# reading the enemble ice file to replaceing the hicem/aicem in another ncfile with the input ensemble member
#
# Requires the input two file names and the member number in the ensemble.

#
if len(sys.argv)<2:
   print("")
   print("Usage:") 
   print(sys.argv[0]+" <ice_ensemble.nc> <number in ensemble>") 
   print("")
   sys.exit("Missing th basic input information!") 

File0=sys.argv[1]
imem=int(sys.argv[2])

Cmm='{:0>3}'.format(imem)
File2='forecast'+Cmm+'.nc'

# checking the file existence:
for ii in File0,File2:
   isEx=os.path.exists(ii)
   if isEx==False:
      print(ii)
      sys.exit("sorry, goodbye") 

# reading the Imem field in the ensemble results
nc1=Dataset(File0)
Sfice=nc1.variables['aisnap_d'][imem-1,:,:]
Shice=nc1.variables['hisnap_d'][imem-1,:,:]
nc1.close()
#print(np.shape(Sfice))


# Start to replac
nc0=Dataset(File2,'r+')
Ffice=nc0.variables['ficem'][:,:]
Fhice=nc0.variables['hicem'][:,:]
nc0['ficem'][:]=Sfice
nc0['hicem'][:]=Shice
nc0.close()

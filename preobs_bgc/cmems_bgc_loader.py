#
# Download CMEMS CORA PHY data with Copernicus Marine Toolbox:
#   https://help.marine.copernicus.eu/en/collections/9080063-copernicus-marine-toolbox
#
# Product ID:
#
#   INSITU_GLO_BGC_DISCRETE_MY_013_046           # MY
#   INSITU_GLO_PHYBGCWAV_DISCRETE_MYNRT_013_030  # NRT
#
# Dataset ID:
#
#   INSITU_GLO_BGC_DISCRETE_MY_013_046:
#     cmems_obs-ins_glo_bgc-chl_my_na_irr
#     cmems_obs-ins_glo_bgc-nut_my_na_irr
#     cmems_obs-ins_glo_bgc-ox_my_na_irr
#
#   INSITU_GLO_PHYBGCWAV_DISCRETE_MYNRT_013_030:
#     cmems_obs-ins_arc_phybgcwav_mynrt_na_irr
#   

import sys
import copernicusmarine as cm
import pandas as pd
import yaml
from IPython.display import display, HTML

def download_cmems_data(dataset_id,output_directory,filter,config):
    cm.get(dataset_id=dataset_id,
           output_directory=output_directory,
           filter=filter,
           force_download=True,
           no_directories=True,
           username=config.get('uname', ''),
           password=config.get('psswd', ''))

#-----------------------------------
# Load CMEMS credentials
#-----------------------------------

with open("config_user.yaml", 'r') as file:
    config = yaml.safe_load(file)

#-----------------------------------
# Set configurations
#-----------------------------------

#-- read year, process type, satellite

if len(sys.argv) < 5:
    print("Number of arguments must be 3:")
    print(f"  {sys.argv[0]} <date> <process> <satellite> <isload>")
    print(f"     date     : YYYYMMDD       # date ")
    print(f"     process  : MY/NRT         # reprocessed / near real time")
    print(f"  instrument  : \"all\" or \"CT PF BO ..\"")
    print(f"     isload   : True/False     # download files or not")
    exit()
else:
    date = str(sys.argv[1])
    proc = str(sys.argv[2])
    inst = str(sys.argv[3]).split(' ')
    test = str(sys.argv[4])
    year = date[:4]

if test.lower() == 'true':
    isload = True
elif test.lower() == 'false':
    isload = False
    
#-- Storage
data_directory = f"./CMEMS"

#-----------------------------------
# download files 
#-----------------------------------

output_directory=f"{data_directory}/CMEMS_CORA_{proc}"
print(f"Files be downloaded to {output_directory}")

#-- Download selected files
    
if proc == "MY":
    dataset_id = f"cmems_obs-ins_glo_phy-temp-sal_my_cora_irr"
    if inst == "all": # All profiles
        filter = f"arctic/{year}/CO_DMQCGL01_{date}*_PR_*.nc"  
        if isload:
            download_cmems_data(dataset_id,output_directory,filter,config)
    else:             # Selected profiles
        for marker in inst:
            filter = f"arctic/{year}/CO_DMQCGL01_{date}*_PR_{marker}.nc"
            print(filter)
            if isload:
                download_cmems_data(dataset_id,output_directory,filter,config)
elif proc == "NRT":
    dataset_id = f"cmems_obs-ins_arc_phybgcwav_mynrt_na_irr"
    if inst == "all": # All profiles
        filter = f"latest/{date}/*_PR_*_{date}.nc"  
        if isload:
            download_cmems_data(dataset_id,output_directory,filter,config)
    else:             # Selected profiles
        for marker in inst:
            filter = f"latest/{date}/*_PR_{marker}_*_{date}.nc"  
            print(filter)
            if isload:
                download_cmems_data(dataset_id,output_directory,filter,config)
    exit()
    
            


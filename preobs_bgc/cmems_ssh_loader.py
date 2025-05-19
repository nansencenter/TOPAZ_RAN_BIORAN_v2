#
# Download CMEMS INSTAC BGC data with Copernicus Marine Toolbox:
#   https://help.marine.copernicus.eu/en/collections/9080063-copernicus-marine-toolbox
#
# Product ID:
#
#   SEALEVEL_GLO_PHY_L3_MY_008_062
#   SEALEVEL_GLO_PHY_L3_NRT_008_044
#
# Dataset ID:
#
#   SEALEVEL_GLO_PHY_L3_MY_008_062:
#     cmems_obs-sl_glo_phy-ssh_my_c2-l3-duacs_PT1S      CryoSat-2
#     cmems_obs-sl_glo_phy-ssh_my_c2n-l3-duacs_PT1S     CryoSat-2 new orbit
#     cmems_obs-sl_glo_phy-ssh_my_en-l3-duacs_PT1S      Envisat
#     cmems_obs-sl_glo_phy-ssh_my_enn-l3-duacs_PT1S     Envisat new orbit
#     cmems_obs-sl_glo_phy-ssh_my_e1-l3-duacs_PT1S      ERS-1
#     cmems_obs-sl_glo_phy-ssh_my_e1g-l3-duacs_PT1S     ERS-1 geodetic phase
#     cmems_obs-sl_glo_phy-ssh_my_e2-l3-duacs_PT1S      ERS-2
#     cmems_obs-sl_glo_phy-ssh_my_g2-l3-duacs_PT1S      GFO
#     cmems_obs-sl_glo_phy-ssh_my_h2a-l3-duacs_PT1S     HaiYang-2A
#     cmems_obs-sl_glo_phy-ssh_my_h2ag-l3-duacs_PT1S    HaiYang-2A geodetic orbit
#     cmems_obs-sl_glo_phy-ssh_my_h2b-l3-duacs_PT1S     HaiYang-2B
#     cmems_obs-sl_glo_phy-ssh_my_j1-l3-duacs_PT1S      Jason-1
#     cmems_obs-sl_glo_phy-ssh_my_j1g-l3-duacs_PT1S     Jason-1 geodetic orbit
#     cmems_obs-sl_glo_phy-ssh_my_j1n-l3-duacs_PT1S     Jason-1 new orbit
#     cmems_obs-sl_glo_phy-ssh_my_j2-l3-duacs_PT1S      Jason-2
#     cmems_obs-sl_glo_phy-ssh_my_j2n-l3-duacs_PT1S     Jason-2 interleaved orbit
#     cmems_obs-sl_glo_phy-ssh_my_j2g-l3-duacs_PT1S     Jason-2 long-repeat orbit
#     cmems_obs-sl_glo_phy-ssh_my_j3-l3-duacs_PT1S      Jason-3
#     cmems_obs-sl_glo_phy-ssh_my_j3n-l3-duacs_PT1S     Jason-3 interleaved orbit 
#     cmems_obs-sl_glo_phy-ssh_my_al-l3-duacs_PT1S      Saral/AltiKa
#     cmems_obs-sl_glo_phy-ssh_my_alg-l3-duacs_PT1S     Saral/AltiKa geodetic orbit 
#     cmems_obs-sl_glo_phy-ssh_my_s3a-l3-duacs_PT1S     Sentinel-3A
#     cmems_obs-sl_glo_phy-ssh_my_s3b-l3-duacs_PT1S     Sentinel-3B
#     cmems_obs-sl_glo_phy-ssh_my_s6a-lr-l3-duacs_PT1S  Sentinel-6A LRM
#     cmems_obs-sl_glo_phy-ssh_my_swon-l3-duacs_PT1S    SWOT nadir
#     cmems_obs-sl_glo_phy-ssh_my_swonc-l3-duacs_PT1S   SWOT nadir CalVal
#     cmems_obs-sl_glo_phy-ssh_my_tp-l3-duacs_PT1S      TOPEX/Poseidon
#     cmems_obs-sl_glo_phy-ssh_my_tpn-l3-duacs_PT1S     TOPEX/Poseidon new orbit
#
#   SEALEVEL_GLO_PHY_L3_NRT_008_044:
#     cmems_obs-sl_glo_phy-ssh_nrt_c2n-l3-duacs_PT1S    CryoSat-2 new orbit, 1 Hz
#     cmems_obs-sl_glo_phy-ssh_nrt_h2b-l3-duacs_PT1S    HaiYang-2B, 1 Hz
#     cmems_obs-sl_glo_phy-ssh_nrt_j3n-l3-duacs_PT1S    Jason-3 interleaved orbit, 1 Hz
#     cmems_obs-sl_glo_phy-ssh_nrt_al-l3-duacs_PT1S     Saral/AltiKa, 1 Hz
#     cmems_obs-sl_glo_phy-ssh_nrt_s3a-l3-duacs_PT1S    Sentinel-3A, 1 Hz
#     cmems_obs-sl_glo_phy-ssh_nrt_s3b-l3-duacs_PT1S    Sentinel-3B, 1 Hz 
#     cmems_obs-sl_glo_phy-ssh_nrt_s6a-hr-l3-duacs_PT1S Sentinel-6A SAR, 1 Hz
#     cmems_obs-sl_glo_phy-ssh_nrt_swon-l3-duacs_PT1S   SWOT nadir, 1 Hz
#   

import sys
import copernicusmarine as cm
import pandas as pd
import yaml
from IPython.display import display, HTML

def register_ssh(proc):
    # register altimeter information of SEALEVEL_GLO_PHY_L3_MY_008_062

    dict_ssh_my = {
    "c2"   : {"name":"CryoSat-2"},
    "c2n"  : {"name":"CryoSat-2 new orbit"},
    "en"   : {"name":"Envisat"},
    "enn"  : {"name":"Envisat new orbit"},
    "e1"   : {"name":"ERS-1"},
    "e1g"  : {"name":"ERS-1 geodetic phase"},
    "e2"   : {"name":"ERS-2"},
    "g2"   : {"name":"GFO"},
    "h2a"  : {"name":"HaiYang-2A"},
    "h2ag" : {"name":"HaiYang-2A geodetic orbit"},
    "h2b"  : {"name":"HaiYang-2B"},
    "j1"   : {"name":"Jason-1"},
    "j1g"  : {"name":"Jason-1 geodetic orbit"},
    "j1n"  : {"name":"Jason-1 new orbit"},
    "j2"   : {"name":"Jason-2"},
    "j2n"  : {"name":"Jason-2 interleaved orbit"},
    "j2g"  : {"name":"Jason-2 long-repeat orbit"},
    "j3"   : {"name":"Jason-3"},
    "j3n"  : {"name":"Jason-3 interleaved orbit"},
    "al"   : {"name":"Saral/AltiKa"},
    "alg"  : {"name":"Saral/AltiKa geodetic orbit"},
    "s3a"  : {"name":"Sentinel-3A"},
    "s3b"  : {"name":"Sentinel-3B"},
    "s6a"  : {"name":"Sentinel-6A LRM"},
    "swon" : {"name":"SWOT nadir"},
    "swonc": {"name":"SWOT nadir CalVal"},
    "tp"   : {"name":"TOPEX/Poseidon"},
    "tpn"  : {"name":"TOPEX/Poseidon new orbit"},
    }

    # register altimeter information of SEALEVEL_GLO_PHY_L3_NRT_008_044

    dict_ssh_nrt = {
    "c2"   : {"name":"CryoSat-2"},
    "h2b"  : {"name":"HaiYang-2B 1Hz"},
    "j3n"  : {"name":"Jason-3 1Hz"},
    "al"   : {"name":"Saral/AltiKa 1Hz"},
    "alg"  : {"name":"Saral/AltiKa geodetic orbit"},
    "s3a"  : {"name":"Sentinel-3A 1Hz"},
    "s3b"  : {"name":"Sentinel-3B 1Hz"},
    "s6a"  : {"name":"Sentinel-6A 1Hz"},
    "swon" : {"name":"SWOT nadir 1Hz"},
    }

    if proc == 'MY':
        dict_ssh = dict_ssh_my
    elif proc == 'NRT':
        dict_ssh = dict_ssh_nrt

    return dict_ssh

def download_cmems_data(dataset_id,output_directory,marker,date,config):
    filter = f"dt_global_{marker}_phy_l3_1hz_{date}*.nc"
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
    print(f"  {sys.argv[0]} <year> <process> <satellite> <isload>")
    print(f"     date     : YYYYMMDD       # date ")
    print(f"     process  : MY/NRT         # reprocessed / near real time")
    print(f"     markers  : \"sat1,sat2,..\" # list of satellite markers")
    print(f"     isload   : True/False     # download files or not")
    exit()
oelse:
    date = str(sys.argv[1])
    proc = str(sys.argv[2])
    sat  = str(sys.argv[3]).split(',')
    test = str(sys.argv[4])

if test.lower() == 'true':
    isload = True
elif test.lower() == 'false':
    isload = False
    
dict_ssh = register_ssh(proc)

#-- Storage
data_directory = f"./CMEMS"

#-- List of satellite markers

if sat == 'all':
    markers_ssh = list(dict_ssh.keys()) # SEALEVEL_GLO_PHY_L3_MY_008_062
else:
    markers_ssh = sat                   # SEALEVEL_GLO_PHY_L3_NRT_008_044

#-----------------------------------
# download files 
#-----------------------------------

output_directory=f"{data_directory}/CMEMS_SSH_{proc}"

for marker in markers_ssh:
    if marker in list(dict_ssh.keys()):
        name = dict_ssh[marker]["name"]
        print(f"Download {name}")
    else:
        print(f"{marker} is not registered to satellite list, STOP")
        exit()

    #-- Download selected files
    
    dataset_id = f"cmems_obs-sl_glo_phy-ssh_{proc.lower()}_{marker}-l3-duacs_PT1S"
    print(f"Files be downloaded to {output_directory}")
    if isload:
        download_cmems_data(dataset_id,output_directory,marker,date,config)

#
# Download CMEMS INSTAC BGC data with Copernicus Marine Toolbox
#
# https://help.marine.copernicus.eu/en/collections/9080063-copernicus-marine-toolbox
#
# Product ID:
#
#   INSITU_GLO_BGC_DISCRETE_MY_013_046
#
# Dataset ID: 
#   cmems_obs-ins_glo_bgc-chl_my_na_irr
#   cmems_obs-ins_glo_bgc-nut_my_na_irr
#   cmems_obs-ins_glo_bgc-ox_my_na_irr
#

import sys
import copernicusmarine as cm
import pandas as pd
import yaml
from IPython.display import display, HTML

def download_cmems_data(dataset_id,file_list,output_directory,config):
    cm.get(dataset_id=dataset_id,
       output_directory=output_directory, 
       force_download=True,
       no_directories=True,
       file_list=file_list,
       username=config.get('uname', ''),
       password=config.get('psswd', ''))
    
def fetch_cmems_data_list(dataset_id, config, bbox, instrument, file_list):
    # read CMEMS credentials
    USER = config.get('uname', '')
    UWORD = config.get('psswd', '')
    
    # Fetch data_list from Copernicus Marine
    response = cm.get(
        dataset_id=dataset_id,
        index_parts=True,
        username=USER,
        password=UWORD
    )
    
    # Extract last modified date
    last_modified_dates = [file.last_modified_datetime.split('T')[0] for file in response.files]
    print(f"Last modified date: {last_modified_dates[0]}")
    
    # Adjust display settings for Jupyter Notebook
    display(HTML("<style>table.dataframe {font-size: 12px;}</style>"))
    pd.set_option('display.max_colwidth', None)
    
    # Extract dataset paths and read index file
    dataframes = []
    data_paths = {file.file_path.parent for file in response.files}
    
    for path in data_paths:
        file_path = f"{path}/index_history.txt"
        print(f"Index file: {file_path}")
        dataset_version = f"{path}"[-6:]
        print(f"Dataset version: {dataset_version}")
        
        # Read the file
        df = pd.read_csv(file_path, sep=',', skiprows=5)
        dataframes.append(df)
    
    # Combine dataframes if multiple index files exist
    if dataframes:
        final_df = pd.concat(dataframes, ignore_index=True)
    else:
        final_df = pd.DataFrame()

    # apply filter for Arctic

    pattern = rf"history/{instrument}"

    # Filter the dataframe based on the bounding box and instrument type
    df = final_df[
     (final_df['file_name'].str.contains(pattern,regex=True)) &
     (final_df['geospatial_lon_min'] >= bbox['longitude'][0]) & 
     (final_df['geospatial_lon_max'] <= bbox['longitude'][1]) &
     (final_df['geospatial_lat_min'] >= bbox['latitude'][0]) &
     (final_df['geospatial_lat_max'] <= bbox['latitude'][1]) &
     (final_df['time_coverage_start'] >= bbox['time'][0]) & 
     (final_df['time_coverage_end'] <= bbox['time'][1]) 
    ]

    print(df['file_name'])

    # Save the column to a text file
    df['file_name'].to_csv(file_list, index=False, header=False)

    print(f"")
    print(f"## list of selected files")
    print(f"")

    with open(file_list, 'r') as file:
        print(file.read())

    return dataset_version

#-----------------------------------
# Load CMEMS credentials
#-----------------------------------

with open("config_user.yaml", 'r') as file:
    config = yaml.safe_load(file)

#-----------------------------------
# Set configurations
#-----------------------------------

#-- read year, instrument type, variable

if len(sys.argv) < 5:
    print("Number of arguments must be 4:")
    print(f"  {sys.argv[0]} <year> <instrument> <variable> <isload>")
    print(f"     year      : YYYY")
    print(f"     instrument: PF/BO        # aunomous float / bottle sampled")
    print(f"     variable  : nut/chl/ox   # nutrients / chlorophyll-a / oxygen")
    print(f"     isload    : True/False   # download files or not")
    exit()
else:
    year = str(sys.argv[1])
    instrument = str(sys.argv[2])
    var = str(sys.argv[3])
    test = str(sys.argv[4])

if test.lower() == 'true':
    isload = True
elif test.lower() == 'false':
    isload = False
    
#-- Geographical and temporal filter
bbox = {"longitude": [-180, 180],
        "latitude": [50, 90],
        "time":['1997-01-01',year+'-12-31']}

#-- Instrument filter
#instrument = "PF"  # autonomous float data
#instrument = "BO"  # bottle sampled data

#-- Select variable
#var = "nut"
#var = "chl"
#var = "ox"

#-- Storage
data_directory = f"./data"

#-----------------------------------
# Fetch list of download files
#-----------------------------------

dataset_id = f"cmems_obs-ins_glo_bgc-{var}_my_na_irr"
file_list = f"INSITU_{instrument}-{var}.txt"
dataset_version = fetch_cmems_data_list(dataset_id,config,bbox,instrument,file_list)
print(f"List of download files: {file_list}")

#-----------------------------------
# Download selected files
#-----------------------------------

output_directory=f"{data_directory}/CMEMS_INSTAC_{dataset_version}/{instrument}"
print(f"Files be downloaded to {output_directory}")

if isload:
    download_cmems_data(dataset_id,file_list,output_directory,config)

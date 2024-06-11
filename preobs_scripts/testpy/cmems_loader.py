# COEPERCNIUS data laoder for ARC MFC reanalysis system
#
# version 1.0
#
#  Download CMEMS data with Copernicus Marine Toolbox API
#  (https://help.marine.copernicus.eu/en/collections/9080063-copernicus-marine-toolbox)
#

from datetime import datetime, timedelta
import copernicusmarine as cm
import yaml
import sys
import os

def read_yaml(file_path, target_key):
    with open(file_path, 'r') as file:
        config = yaml.safe_load(file)
    
    # Find the dataset with the specified TARGET key
    for dataset in config['datasets']:
        if dataset['TARGET'] == target_key:
            return dataset
    
    return None

def get_available_targets(file_path, year):
    with open(file_path, 'r') as file:
        config = yaml.safe_load(file)

    targets = [(dataset['TARGET'], dataset.get('PERIOD', '')) for dataset in config['datasets']]    
    targets = []
    for dataset in config['datasets']:
        period = dataset.get('PERIOD', '')
        target = dataset.get('TARGET', '')
        if period and target:
            start_year = int(period[:4])
            end_year = int(period[9:13])
            if start_year <= year <= end_year:
               targets.append((target, period))

    return targets

def main():
    if len(sys.argv) < 3:
        print("Usage: python cmems_loader.py <YYYYMMDD> <target>|avail (sample)")
        print("  to check available target for given year:")
        print("       python cmems_loader.py <YYYYMMDD> avail")
        print("  to check download sample file for given year:")
        print("       python cmems_loader.py <YYYYMMDD> <target> sample")
        sys.exit(1)
    
    try:
        #obs_datetime="20160401"
        obs_datetime = str(sys.argv[1])
        year = int(obs_datetime[:4])
        #year = str(sys.argv[1])

        print(f"year: {year}")
    except ValueError:
        print("The provided argument is not a valid integer.")
        sys.exit(1)

    try:
        target = str(sys.argv[2])
        if target != "avail":
            print(f"target: {target}")
    except ValueError:
        print("The provided argument is not a valid string.")
        sys.exit(1)

    issample = False
    if len(sys.argv) == 4:
       issample = True

    # Path to the YAML file
    file_path = "config_user.yaml"

    # Read the configuration
    with open(file_path, 'r') as file:
         config = yaml.safe_load(file)
         USER = config.get('uname', '')
         UWORD = config.get('psswd', '')

    # Path to the YAML file
    file_path = 'config_loader.yaml'

    # Specify the TARGET key to look for
    target_key = target

    # Read the dataset
    dataset = read_yaml(file_path, target_key)

    # Print the values if the dataset is found
    if dataset:
        dataset_id = dataset.get('DATASET_ID', '')
        var_list = []
        for var in ['NCVAR','NCSTD','NCFLG']:
            if var != "NA":
                var_list.append(dataset.get(var, ''))
        tpvar = dataset.get('TPVAR', '')
        try:
            isaggregate = dataset.get('AGGREGATE', '')
        except:
            isaggregate = False

        for key, value in dataset.items():
            print(f"{key}: {value}")
    else:
        if target != "avail":
            print(f"No dataset found with TARGET: {target_key}")
        available_targets = get_available_targets(file_path, year)
        max_target_length = max(len(target) for target, _ in available_targets)
        print("Available TARGET keys are:")
        for target, period in available_targets:
            print(f" - {target.ljust(max_target_length)} {period}")

        exit()

    # Only block to modify:
    for iy in range(year,year+1):
        YYYY=str(iy)

        if issample:

            # Searching filter for sample file download

            listname="*"+obs_datetime+"*.nc"
            print(listname)   

            # Call the get function to save data

            output_directory="./data/sample"
            os.makedirs(output_directory, exist_ok=True)

            cm.get(dataset_id=dataset_id,
                   output_directory=output_directory, 
                   filter=listname, 
                   force_download=True,
                   no_directories=True,
                   username=USER,
                   password=UWORD)

            print("file downloaded to "+output_directory)

        else:

            # Call the subset function to save data

            output_directory="./data/"+target
            os.makedirs(output_directory, exist_ok=True)

            target_date = datetime.strptime(obs_datetime, "%Y%m%d")
            start_date  = target_date - timedelta(days=3)
            end_date    = target_date + timedelta(days=3)
            obs_datetime_range = start_date.strftime("%Y%m%d")+"-"+end_date.strftime("%Y%m%d")

            start_datetime = start_date.strftime("%Y-%m-%d")+"T00:00:00"
            end_datetime   = end_date.strftime("%Y-%m-%d")+"T23:59:59"

            if isaggregate:
                output_filename = tpvar+"_"+obs_datetime_range+".nc"
            else:
                output_filename = tpvar+"_"+obs_datetime+".nc"

            cm.subset(
                dataset_id=dataset_id,
                variables=var_list,
                minimum_longitude=-180,   # TP domain
                maximum_longitude=180,    # TP domain
                minimum_latitude=50,      # TP domain
                maximum_latitude=90,      # TP domain
                start_datetime=start_datetime,
                end_datetime=end_datetime,
                minimum_depth=0,
                maximum_depth=1,
                output_filename=output_filename,
                output_directory=output_directory,
                force_download=True,
                username=USER,
                password=UWORD,
            )

if __name__ == "__main__":
    main()

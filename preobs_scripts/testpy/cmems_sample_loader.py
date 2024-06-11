# COEPERCNIUS data laoder for ARC MFC reanalysis system
#
# version 1.0
#

import copernicusmarine as cm
import yaml
import sys

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
    if len(sys.argv) != 3:
        print("Usage: python cmems_loader.py <year> <target>")
        sys.exit(1)
    
    try:
        year = int(sys.argv[1])
        print(f"year: {year}")
    except ValueError:
        print("The provided argument is not a valid integer.")
        sys.exit(1)

    try:
        target = str(sys.argv[2])
        print(f"target: {target}")
    except ValueError:
        print("The provided argument is not a valid string.")
        sys.exit(1)

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
    target_key = target  # Change this to the desired TARGET

    # Read the dataset
    dataset = read_yaml(file_path, target_key)

    # Print the values if the dataset is found
    if dataset:
        dataset_id = dataset.get('DATASET_ID', '')
        for key, value in dataset.items():
            print(f"{key}: {value}")
    else:
        print(f"No dataset found with TARGET: {target_key}")
        available_targets = get_available_targets(file_path, year)
        max_target_length = max(len(target) for target, _ in available_targets)
        print("Available TARGET keys are:")
        for target, period in available_targets:
            print(f" - {target.ljust(max_target_length)} {period}")

        exit()

    # Only block to modify:
    for iy in range(year,year+1):
        YY=str(iy)
        listname="*"+YY+"0101"+"*.nc"
        print(listname)   

        # Define output storage parameters
        OUTDIR="./data/sample"

        # Call the get function to save data
        cm.get(dataset_id=dataset_id,
               output_directory=OUTDIR, 
               filter=listname, 
               force_download=True,
               no_directories=True,
               username=USER,
               password=UWORD)

if __name__ == "__main__":
    main()

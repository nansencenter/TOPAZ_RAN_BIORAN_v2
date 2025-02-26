# COEPERNICUS data laoder for ARC MFC reanalysis system
#
# version 1.0
#
#  Download CMEMS data with Copernicus Marine Toolbox API
#    (https://help.marine.copernicus.eu/en/collections/9080063-copernicus-marine-toolbox)
#

from datetime import datetime, timedelta
import copernicusmarine as cm
import yaml
import sys
import os
import subprocess

def log_to_linear_std(log_std, mean_linear):
    """
    Convert standard deviation from log10 scale to linear scale.
    
    Parameters:
    log_std (numpy.ndarray or float): Standard deviation in the log10 scale.
    mean_linear (numpy.ndarray or float): Mean of the data in the linear scale.
    
    Returns:
    numpy.ndarray or float: Standard deviation in the linear scale.
    """
    linear_std = mean_linear * (10**log_std - 1)
    return linear_std

def concatenate_netcdf_cdo(file_list, output_file):
    # Construct the CDO command
    command = ['cdo', 'cat'] + file_list + [output_file]
    
    # Execute the command
    result = subprocess.run(command, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"Concatenation successful: {output_file}")
    else:
        print(f"Error: {result.stderr}")

def aggregate_netcdf_cdo(input_file, output_file):
    # Construct the CDO command
    command = ['cdo', 'timmean', input_file, output_file]
    
    # Execute the command
    result = subprocess.run(command, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"Aggregation successful: {output_file}")
    else:
        print(f"Error: {result.stderr}")

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
        print("Usage: python cmems_loader.py <YYYYMMDD> <target|avail> <full|subset|check>")
        print("  to check available target for given year:")
        print("       python cmems_loader.py <YYYYMMDD> avail")
        print("  to download full file for given year:")
        print("       python cmems_loader.py <YYYYMMDD> <target> full")
        print("  to download subset of file for given year:")
        print("       python cmems_loader.py <YYYYMMDD> <target> subset")
        sys.exit(1)

    daydelta=3 # define aggregation window size (=7)
    
    try:
        obs_date = str(sys.argv[1])
        year = int(obs_date[:4])

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

    # full file or subset file download

    isfull = False
    issubset = False
    if len(sys.argv) == 4:
        try:
            size = str(sys.argv[3])
            if size == "full":
                isfull = True
            elif size == "subset":
                issubset = True
        except ValueError:
            print("The provided argument is not a valid string.")
            sys.exit(1)

    # if target is ESACCI_SCHL, use archived files

    isesaoccci = False
    if target == "ESACCI_SCHL":
       isesaoccci = True

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
            ncvar = dataset.get(var, '')
            if ncvar != "NA":
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

    #
    for iy in range(year,year+1):
        YYYY=str(iy)

        output_directory="./CMEMS/"+target
        target_date = obs_date
        target_datetime = datetime.strptime(target_date, "%Y%m%d")

        if isfull:

            # Call the get function to save data

            if isaggregate:
                start_datetime  = target_datetime - timedelta(days=daydelta)
                end_datetime    = target_datetime + timedelta(days=daydelta)
                start_date = start_datetime.strftime("%Y%m%d")
                end_date   = end_datetime.strftime("%Y%m%d")
                obs_date_range = start_date+"-"+end_date 
            else:
                start_date = target_date
                end_date   = target_date
                start_datetime = datetime.strptime(start_date, "%Y%m%d")
                end_datetime   = datetime.strptime(end_date, "%Y%m%d")

            # Searching filter for sample file download

            ncfile_list = []

            current_datetime = start_datetime
            while current_datetime <= end_datetime:
                obs_date = current_datetime.strftime("%Y%m%d")
                listname="*"+obs_date+"*.nc"
                print(listname)   
                current_datetime += timedelta(days=1)
            
                os.makedirs(output_directory, exist_ok=True)

                if isesaoccci:
                    #
                    # Since ESA CCI OC data on CMEMS does not contain Chl-a uncertainty information,
                    # we use the original files from ESA OC-CCI
                    #
                    input_directory = "/cluster/projects/nn2993k/OCCCI/1D_4KM_GEO/v6.0/"+str(year)
                    ncfiles = os.listdir(input_directory)
                    for ncfile in ncfiles:
                       if obs_date in ncfile:
                           file_path_in = os.path.join(input_directory, ncfile)
                           file_path_out = os.path.join(output_directory, ncfile)
                           subprocess.run(['cp', file_path_in, file_path_out], check=True)                        
                    
                else:
                    cm.get(dataset_id=dataset_id,
                           output_directory=output_directory, 
                           filter=listname, 
                           force_download=True,
                           no_directories=True,
                           username=USER,
                           password=UWORD)

                # check which file is downloaded

                newest_file = None
                newest_timestamp = 0

                ncfiles = os.listdir(output_directory)
                for ncfile in ncfiles:
                   if obs_date in ncfile:
                      file_path = os.path.join(output_directory, ncfile)
                      file_timestamp = os.path.getmtime(file_path)
                      
                      if file_timestamp > newest_timestamp:
                         newest_timestamp = file_timestamp
                         newest_file = ncfile

                if newest_file:
                    current_time_utc = datetime.utcnow()
                    formatted_time = current_time_utc.strftime('%Y-%m-%dT%H:%M:%SZ')
                    file_path = os.path.join(output_directory, newest_file)
                    ncfile_list.append(file_path)
                    print("INFO - "+formatted_time+" - Successfully downloaded to "+file_path)

            if isaggregate:
                 ncfile = tpvar+"_"+obs_date_range+".nc"
                 file_path = os.path.join(output_directory, ncfile)
                 concatenate_netcdf_cdo(ncfile_list, file_path)
                 print("INFO - "+formatted_time+" - Successfully concatenated to "+file_path)
                 ncfile = tpvar+"_"+target_date+".nc"
                 file_path_out = os.path.join(output_directory, ncfile)
                 aggregate_netcdf_cdo(file_path, file_path_out)
                 print("INFO - "+formatted_time+" - Successfully aggregated to "+file_path_out)
            else:
                 work_directory = os.getcwd() # working directory
                 os.chdir(output_directory)
                 file_path = newest_file
                 ncfile = tpvar+"_"+obs_date+".nc"
                 symlink_path = ncfile
                 os.symlink(file_path, symlink_path)
                 os.chdir(work_directory)
                 print("INFO - "+formatted_time+" - Successfully simlinked to "+output_directory+'/'+symlink_path)

        if issubset:

            # Call the subset function to save data

            os.makedirs(output_directory, exist_ok=True)

            if isaggregate:
                start_datetime = target_datetime - timedelta(days=3)
                end_datetime   = target_datetime + timedelta(days=3)
                start_date = start_datetime.strftime("%Y-%m-%d")+"T00:00:00"
                end_date   = end_datetime.strftime("%Y-%m-%d")+"T23:59:59"
                obs_date_range = start_datetime.strftime("%Y%m%d")+"-"+end_datetime.strftime("%Y%m%d")
                output_filename = tpvar+"_"+obs_date_range+".nc"
            else:
                start_datetime = target_datetime.strftime("%Y-%m-%d")+"T00:00:00"
                end_datetime   = target_datetime.strftime("%Y-%m-%d")+"T23:59:59"
                output_filename = tpvar+"_"+obs_date+".nc"

            cm.subset(
                dataset_id=dataset_id,
                variables=var_list,
                minimum_longitude=-180,   # TP domain
                maximum_longitude=180,    # TP domain
                minimum_latitude=40,      # TP domain
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

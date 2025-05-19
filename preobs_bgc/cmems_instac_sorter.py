import os
import sys
import netCDF4 as nc
import numpy as np
import fnmatch
from datetime import datetime, timedelta

#TARGET_YEAR = 2017  # Change this to the desired year
#TYPE = "BO"
TARGET_YEAR = int(sys.argv[1])
TYPE        = str(sys.argv[2])

#-- Storage
#data_directory = f"./data"
data_directory = f"/nird/projects/NS9481K/CMEMS"

DATA_PATH = f"{data_directory}/CMEMS_INSTAC_202411/ALL"
SAVE_PATH = f"{data_directory}/CMEMS_INSTAC_202411/{TYPE}_{TARGET_YEAR}"

# Create SAVE_PATH folder if it doesn't exist
if not os.path.exists(SAVE_PATH):
    os.makedirs(SAVE_PATH)

def get_time_range(file_path):
    with nc.Dataset(file_path) as ds:
        time_var = ds.variables["TIME"][:]
        time_units = ds.variables["TIME"].units  # Expected format: "days since 1950-01-01T00:00:00Z"
        base_time = datetime(1950, 1, 1)
        if len(time_var) > 0:
            start_time = base_time + timedelta(days=float(np.min(time_var)))
            end_time = base_time + timedelta(days=float(np.max(time_var)))
            return start_time, end_time
    return None, None

matching_files = []

# List matching files
for file in os.listdir(DATA_PATH):
    file_path = os.path.join(DATA_PATH, file)
    if fnmatch.fnmatch(file, f"*_{TYPE}_*.nc"):
        start_time, end_time = get_time_range(file_path)
        if start_time and end_time and (start_time.year <= TARGET_YEAR <= end_time.year):
            matching_files.append(file)

# Create symlinks in SAVE_PATH
for file in matching_files:
#    print(file)
    src_file = os.path.join(DATA_PATH, file)
    dest_file = os.path.join(SAVE_PATH, file)
    if not os.path.exists(dest_file):  # Avoid overwriting existing symlinks
        os.symlink(src_file, dest_file)
        print(f"Created symlink for {file}")

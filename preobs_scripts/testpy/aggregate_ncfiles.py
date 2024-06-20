import matplotlib
matplotlib.use('GTK3Agg')  # Use the Qt5 backend

import matplotlib.pyplot as plt
from netCDF4 import Dataset
import numpy as np
import os

def calculate_mean_chl(input_file, output_file):
    
    nc = Dataset(input_file, 'r')   # Open the NetCDF file

    var_list = ['CHL','CHL_uncertainty','flags']
    for var_name in var_list:
       if var_name in nc.variables:
          var = nc.variables[var_name]
          if hasattr(var, '_FillValue'):
              fill_value = var._FillValue
              data = np.ma.masked_equal(var[:], fill_value)
              print(f"{var_name} variable has a _FillValue attribute: {fill_value}")
              data_mean = np.mean(data, axis=0)
          else:
              data = var[:]
              print(f"{var_name} variable does not have a _FillValue attribute")
          
          plt.imshow(data[0, :, :].squeeze(), origin='lower')
          plt.colorbar(label=var_name)
          plt.xlabel('Longitude')
          plt.ylabel('Latitude')
          plt.show()
          
    else:
        print(f"{var_name} variable not found in the NetCDF file")
    
    nc.close()                      # Close the NetCDF file

    # Save the mean CHL along with other variables to a new NetCDF file
#    with Dataset(output_file, 'w') as nc_out:
#        # Create dimensions
#        lat_dim = nc_out.createDimension('lat', chl_mean.shape[0])
#        lon_dim = nc_out.createDimension('lon', chl_mean.shape[1])
#        
#        # Create variables
#        lat_var = nc_out.createVariable('lat', np.float32, ('lat',))
#        lon_var = nc_out.createVariable('lon', np.float32, ('lon',))
#        chl_mean_var = nc_out.createVariable('CHL_mean', np.float32, ('lat', 'lon'))
#        flags_var = nc_out.createVariable('flags', np.byte, ('lat', 'lon'))
#        chl_uncertainty_var = nc_out.createVariable('CHL_uncertainty', np.short, ('lat', 'lon'))
#
#        # Assign data
#        lat_var[:] = nc.variables['lat'][:]
#        lon_var[:] = nc.variables['lon'][:]
#        chl_mean_var[:] = chl_mean
#        flags_var[:] = flags_data
#        chl_uncertainty_var[:] = chl_uncertainty_data

    print(f"New dataset saved to {output_file}")

if __name__ == "__main__":
    # Define input and output file names

    target="CMEMSGLB_SCHL"

    output_directory="./data/CMEMSGLB_SCHL"
    input_file = 'SCHL_20160529-20160604_full.nc'
    output_file = 'SCHL_20160601_full.nc'

    input_file_path = os.path.join(output_directory, input_file)
    output_file_path = os.path.join(output_directory, output_file)

    # Call the function
    calculate_mean_chl(input_file_path, output_file_path)

import copernicusmarine
import yaml

# Path to the YAML file
file_path = "config_user.yaml"

# Read the configuration
with open(file_path, 'r') as file:
     config = yaml.safe_load(file)
     USER = config.get('uname', '')
     UWORD = config.get('psswd', '')

copernicusmarine.subset(
  dataset_id="cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
  variables=["uo", "vo"],
  minimum_longitude=50,
  maximum_longitude=90,
  minimum_latitude=0,
  maximum_latitude=25,
  start_datetime="2022-01-01T00:00:00",
  end_datetime="2022-01-31T23:59:59",
  minimum_depth=0,
  maximum_depth=1,
  output_filename = "CMEMS_Indian_currents_Jan2022_surface.nc",
  output_directory = "./data/sample",
  force_download=True,
  username=USER,
  password=UWORD,
)

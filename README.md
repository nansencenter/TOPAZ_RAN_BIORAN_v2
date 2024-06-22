### main update

New prepobs scripts folder: ```preobs_bgc``` is added for integrating CMEMS data loader and prepobs. Main scripts are:
```bash
cmems_loader.py  # CMEMS data loader
prep_obs.sh      # for executing prep_obs
plot_prepobs.py  # for visual check of obs_[SST|ICEC|SCHL]_[YYYYMMDD].nc 
```

For the usage, see the following sample scripts under ```preobs_bgc```:
```bash
prep_OSISAF_ICEC_[TP5|TP2].sh   # OSISAF sea ice concentration preprocessor for [TP5|TP2] grid
prep_OSTIA_SST_[TP5|TP2].sh     # OSTIA sea surface temperature preprocessor for [TP5|TP2] grid
prep_CMEMS_SCHL_[TP5|TP2].sh    # CMEMS (GlobColour) sea surface preprocessor for [TP5|TP2] grid
prep_ESACCI_SCHL_[TP5|TP2].sh   # ESACCI sea surface chlorophyll preprocessor for [TP5|TP2] grid
```

For the usage of ```cmems_loader.py```, type:
```bash
python cmems_loader.py
```

#### notes:
- Before running ```prep_obs.sh```, make sure that executable ```Prep_Routines/prep_obs``` of the updated EnKF package [link](https://github.com/nansencenter/TOPAZ_ENKF_BIORAN_v2) is compiled and its location is set in ```PATH``` settings in ```prep_obs.sh```.
- hycom configuration files: ```regional.grid.(a,b)```, ```regional.depth.(a,b)```, ```grid.info``` and ```blkdat.input``` are copied from hycom folder to ```CONFIG``` folder.   
- To use ```cmems_loader.py```, you need to copy ```config_user_template.yaml``` to ```config_user.yaml``` and edit CMEMS user information.
- To add new dataset to CMEMS data loader, register dataset information to ```config_loader.yaml``` following existing cases. 
- ```ESACCI_SCHL``` is accessing pre-downloaded ESA OC-CCI v6.0 due to lack of uncertainty information in CMEMS product.
- ```SCHL``` data is aggregated to a target date over 7 days window with ±3 days range centered at the target date as default settings. To change the settings, edit ```cmems_loader.py```.
- prepobs preprocessed observation file is saved in ```obs_[SST|ICEC|SCHL]_[YYYYMMDD].nc``` file name format under ```DATA/[TP5|TP2]``` folder instead of in ```obs_[SST|ICEC|SCHL]_[JDate].nc``` format, where ```YYYYMMDD``` is Gregorian date and ```JDate``` is hycom Julian date counted from ```1950 0 0```.
- ```plot_prepobs.py``` uses ```basemap``` for map projection with Python3. You can add ```basemap``` with ```pip``` on Betsy.  

### TODO:

- integrate BGC data aggregator [prepobs_bgc](https://github.com/nansencenter/prepobs_bgc) for BGC in-situ and BGC Argo data.
- register CMEMS CORE Argo temperature and salinity profiles files to CMEMS data loader.

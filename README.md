# TOPAZ RAN with BGC assimilation

## main update

New prepobs scripts folder: ```preobs_bgc``` is added for integrating CMEMS data loader and prepobs. Main scripts are:
```bash
cmems_downloader.py  # CMEMS data loader
prep_obs.sh          # for executing prepobs
plot_prepobs.py      # for visual check of ```obs_[SST|ICEC|SCHL]_YYYYMMDD.nc``` 
```

For the usage, see the following sample scripts under ```preobs_bgc```:
```bash
prep_OSISAF_ICEC_[TP5|TP2].sh   # OSISAF sea ice concentration preprocessor for [TP5|TP2] grid
prep_OSTIA_SST_[TP5|TP2].sh     # OSTIA sea surface temperature preprocessor for [TP5|TP2] grid
prep_CMEMS_SCHL_[TP5|TP2].sh    # CMEMS (GlobColour) sea surface preprocessor for [TP5|TP2] grid
prep_ESACCI_SCHL_[TP5|TP2].sh   # ESACCI sea surface chlorophyll preprocessor for [TP5|TP2] grid
```
Note:
- To use ```cmems_downloader.py```, you need to copy ```config_user_template.yaml``` to ```config_user.yaml``` and edit CMEMS user information.
- To add new dataset to CMEMS data loader, register dataset information to ```config_loader.yaml``` following existing cases. 
- ```ESACCI_SCHL``` is accessing pre-downloaded ESA OC-CCI v6.0 due to lack of uncertainty information in CMEMS product.
- ```SCHL``` data is aggregated to a target date over 7 days window with ±3 days range centered at the target date as default settings.
- prepobs preprocessed observation file is saved in ```[TP5|TP2]/obs_[SST|ICEC|SCHL]_YYYYMMDD.nc``` file name format under ```DATA``` folder instead of in ```obs_[SST|ICEC|SCHL]_JDate.nc``` format, where ```JDate``` is hycom Jule date counted from ```1950 0 0```.  

For the usage of ```cmems_downloader.py```, type:
```bash
python cmems_downloader.py
```

## TODO:

- integrate BGC data aggregator [prepobs_bgc](https://github.com/nansencenter/prepobs_bgc) for BGC in-situ and BGC Argo data.

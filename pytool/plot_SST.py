from mpl_toolkits.basemap import Basemap, cm
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('TkAgg')  # Use an interactive backend
import pylab as pl
import netCDF4 as nc
import numpy as np
import os

date='25202'
cnfg='TP5'

#------------------------------
# read obs file dumped by prepobs
#------------------------------

data_dir = '/cluster/home/wakamatsut/bioran_v2/TOPAZ_RAN_BIORAN_v2/DATA'
file_name = 'obs_SST_'+date+'.nc'
base_name, extension = os.path.splitext(file_name)

file_path = data_dir+'/SST/'+file_name

dataset = nc.Dataset(file_path, mode='r') # Open the NetCDF file  

lon = dataset.variables['lon'][:]
lat = dataset.variables['lat'][:]
dat = dataset.variables['d'][:]
var = dataset.variables['var'][:]
dep = dataset.variables['depth'][:]

#------------------------------
# plot on a map projection
#------------------------------

directory_path = 'figs'
os.makedirs(directory_path, exist_ok=True)
file_path = directory_path+'/'+'prep'+base_name+'_'+cnfg+'.png'

title = cnfg+' prep'+base_name
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(22, 6))

m1 = Basemap(projection='npaeqd',resolution='c',boundinglat=50,lon_0=0, ax=ax1)
x_plot, y_plot = m1(lon,lat)
cs1 = m1.scatter(x_plot,y_plot,s=2,c=dat,edgecolors='none',marker='o',alpha=1.0,cmap='coolwarm',vmin=-2.0,vmax=20.0)
cb1 = m1.colorbar(cs1,location='right',pad='13%')
m1.drawcoastlines(linewidth=0.5,color='dimgray')
m1.fillcontinents(color='whitesmoke',lake_color='whitesmoke')
lbs_lon=[1, 0, 0, 1]
lbs_lat=[0, 1, 1, 0]
m1.drawmeridians(range(-180,180,20),labels=lbs_lon,color='gray');
m1.drawparallels(range(-90,90,10),labels=lbs_lat,color='gray');
ax1.set_title(title, pad=20)

m2 = Basemap(projection='cass',resolution='i',llcrnrlon=-20,llcrnrlat=55,urcrnrlon=60,urcrnrlat=75,lon_0=0,lat_0=70,ax=ax2)
x_plot, y_plot = m2(lon,lat)
cs2 = m2.scatter(x_plot,y_plot,s=4,c=dat,edgecolors='none',marker='o',alpha=1.0,cmap='coolwarm',vmin=-2.0,vmax=20.0)
cb2 = m2.colorbar(cs2,location='right',pad='13%')
m2.drawcoastlines(linewidth=0.5,color='dimgray')
m2.fillcontinents(color='whitesmoke',lake_color='whitesmoke')
lbs_lon=[1, 0, 0, 1]
lbs_lat=[0, 1, 1, 0]
m2.drawmeridians(range(-180,180,20),labels=lbs_lon,color='gray');
m2.drawparallels(range(-90,90,10),labels=lbs_lat,color='gray');
ax2.set_title(title, pad=20)

m3 = Basemap(projection='cass',resolution='i',llcrnrlon=170,llcrnrlat=50,urcrnrlon=240,urcrnrlat=67.5,lon_0=180,lat_0=60,ax=ax3)
#m3 = Basemap(projection='cass',resolution='i',llcrnrlon=160,llcrnrlat=55,urcrnrlon=240,urcrnrlat=75,lon_0=180,lat_0=70,ax=ax3)
x_plot, y_plot = m3(lon,lat)
cs3 = m3.scatter(x_plot,y_plot,s=2,c=dat,edgecolors='none',marker='o',alpha=1.0,cmap='coolwarm',vmin=-2.0,vmax=20.0)
cb3 = m3.colorbar(cs3,location='right',pad='13%')
m3.drawcoastlines(linewidth=0.5,color='dimgray')
m3.fillcontinents(color='whitesmoke',lake_color='whitesmoke')
lbs_lon=[1, 0, 0, 1]
lbs_lat=[0, 1, 1, 0]
m3.drawmeridians(range(-180,180,20),labels=lbs_lon,color='gray');
m3.drawparallels(range(-90,90,10),labels=lbs_lat,color='gray');
ax3.set_title(title, pad=20)

plt.tight_layout()

# save figure

plt.show()
pl.savefig(file_path,dpi=300)

exit()

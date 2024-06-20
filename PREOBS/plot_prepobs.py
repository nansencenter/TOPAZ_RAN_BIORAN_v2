from mpl_toolkits.basemap import Basemap, cm
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('TkAgg')  # Use an interactive backend
import pylab as pl
import netCDF4 as nc
import numpy as np
import os
import sys

if len(sys.argv) != 4:
    print("Usage: python script_name.py <date> <cnfg> <dvar>")
    sys.exit(1)

# Access the command line arguments
date = sys.argv[1]
cnfg = sys.argv[2]
dvar = sys.argv[3]

# Print the arguments (for verification)
print(f'date: {date}')
print(f'cnfg: {cnfg}')
print(f'dvar: {dvar}')

#------------------------------
# read obs file dumped by prepobs
#------------------------------

data_dir = '../DATA/'+cnfg
file_name = 'obs_'+dvar+'_'+date+'.nc'
base_name, extension = os.path.splitext(file_name)

file_path = data_dir+'/'+dvar+'/'+file_name

dataset = nc.Dataset(file_path, mode='r') # Open the NetCDF file  

lon = dataset.variables['lon'][:]
lat = dataset.variables['lat'][:]
dat = dataset.variables['d'][:]      # data
var = dataset.variables['var'][:]    # variance
std = 100.0*np.sqrt(var)/abs(dat)    # standard deviation [%]
dep = dataset.variables['depth'][:]

#------------------------------
# plot on a map projection
#------------------------------

directory_path = 'figs'
os.makedirs(directory_path, exist_ok=True)

#--------------------------------
# plot data
#--------------------------------

if dvar == 'SST':
   vmin = -2.0
   vmax = 20.0
   cmap = 'coolwarm'
   unit = '[$^{\circ}$C]'
elif dvar == 'ICEC':
   vmin = 0.0
   vmax = 1.0
   cmap = 'Blues'
   unit = '[0-1]'
elif dvar == 'SCHL':
   vmin =  0.0
   vmax = 10.0
   cmap = 'winter'
   unit = '[mg m$^{-3}$]'
else:
   print('Parameter name not supported, STOP')
   exit()

if cnfg == 'TP5':
   if dvar == 'ICEC':
     s1 = 3
     s2 = 12
     s3 = 8
   else:
     s1 = 0.5
     s2 = 2
     s3 = 1
elif cnfg == 'TP2':
   if dvar == 'ICEC':
     s1 = 3
     s2 = 12
     s3 = 8
   else:
     s1 = 1
     s2 = 4
     s3 = 2
else:
   print('Configuration name not supported, STOP')
   exit()

file_path = directory_path+'/'+'prep'+base_name+'_dat_'+cnfg+'.png'

title = cnfg+'/'+base_name+' '+unit
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(22, 6))

m1 = Basemap(projection='npaeqd',resolution='c',boundinglat=50,lon_0=0, ax=ax1)
x_plot, y_plot = m1(lon,lat)
cs1 = m1.scatter(x_plot,y_plot,s=s1,c=dat,edgecolors='none',marker='o',alpha=1.0,cmap=cmap,vmin=vmin,vmax=vmax)
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
cs2 = m2.scatter(x_plot,y_plot,s=s2,c=dat,edgecolors='none',marker='o',alpha=1.0,cmap=cmap,vmin=vmin,vmax=vmax)
cb2 = m2.colorbar(cs2,location='right',pad='13%')
m2.drawcoastlines(linewidth=0.5,color='dimgray')
m2.fillcontinents(color='whitesmoke',lake_color='whitesmoke')
lbs_lon=[1, 0, 0, 1]
lbs_lat=[0, 1, 1, 0]
m2.drawmeridians(range(-180,180,20),labels=lbs_lon,color='gray');
m2.drawparallels(range(-90,90,10),labels=lbs_lat,color='gray');
ax2.set_title(title, pad=20)

m3 = Basemap(projection='cass',resolution='i',llcrnrlon=170,llcrnrlat=50,urcrnrlon=240,urcrnrlat=67.5,lon_0=180,lat_0=60,ax=ax3)
x_plot, y_plot = m3(lon,lat)
cs3 = m3.scatter(x_plot,y_plot,s=s3,c=dat,edgecolors='none',marker='o',alpha=1.0,cmap=cmap,vmin=vmin,vmax=vmax)
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
plt.close()

#--------------------------------
# plot standard deviation
#--------------------------------

if dvar == 'SST':
   vmin =   0.0
   vmax = 200.0
   cmap = 'rainbow'
   unit = '[%]'
elif dvar == 'ICEC':
   vmin =   0.0
   vmax = 200.0
   cmap = 'rainbow'
   unit = '[%]'
elif dvar == 'SCHL':
   vmin =   0.0
   vmax = 200.0
   cmap = 'rainbow'
   unit = '[%]'
else:
   print('Parameter name not supported, STOP')
   exit()

if cnfg == 'TP5':
   if dvar == 'ICEC':
     s1 = 4
     s2 = 12
     s3 = 10
   else:
     s1 = 2
     s2 = 4
     s3 = 4
elif cnfg == 'TP2':
   if dvar == 'ICEC':
     s1 = 4
     s2 = 12
     s3 = 10
   elif dvar == 'SCHL':
     s1 = 4
     s2 = 8
     s3 = 8
   else:
     s1 = 4
     s2 = 12
     s3 = 8
else:
   print('Configuration name not supported, STOP')
   exit()

file_path = directory_path+'/'+'prep'+base_name+'_std_'+cnfg+'.png'

title = cnfg+'/'+base_name+' STD '+unit
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(22, 6))

m1 = Basemap(projection='npaeqd',resolution='c',boundinglat=50,lon_0=0, ax=ax1)
x_plot, y_plot = m1(lon,lat)
cs1 = m1.scatter(x_plot,y_plot,s=s1,c=std,edgecolors='none',marker='o',alpha=1.0,cmap=cmap,vmin=vmin,vmax=vmax)
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
cs2 = m2.scatter(x_plot,y_plot,s=s2,c=std,edgecolors='none',marker='o',alpha=1.0,cmap=cmap,vmin=vmin,vmax=vmax)
cb2 = m2.colorbar(cs2,location='right',pad='13%')
m2.drawcoastlines(linewidth=0.5,color='dimgray')
m2.fillcontinents(color='whitesmoke',lake_color='whitesmoke')
lbs_lon=[1, 0, 0, 1]
lbs_lat=[0, 1, 1, 0]
m2.drawmeridians(range(-180,180,20),labels=lbs_lon,color='gray');
m2.drawparallels(range(-90,90,10),labels=lbs_lat,color='gray');
ax2.set_title(title, pad=20)

m3 = Basemap(projection='cass',resolution='i',llcrnrlon=170,llcrnrlat=50,urcrnrlon=240,urcrnrlat=67.5,lon_0=180,lat_0=60,ax=ax3)
x_plot, y_plot = m3(lon,lat)
cs3 = m3.scatter(x_plot,y_plot,s=s3,c=std,edgecolors='none',marker='o',alpha=1.0,cmap=cmap,vmin=vmin,vmax=vmax)
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
plt.close()

exit()

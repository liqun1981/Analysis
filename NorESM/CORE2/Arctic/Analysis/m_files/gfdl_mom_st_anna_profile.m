clear all

filename_s='/work/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/annual_tracers/ocean.1708-2007.salt.nc';
filename_t='/work/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/annual_tracers/ocean.1708-2007.temp.nc';
gridfile='/work/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/grids_bathymetry/ocean.static.nc';
area=ncgetvar(gridfile,'area_t');
salt=ncgetvar(filename_s,'salt');
temp=ncgetvar(filename_t,'temp');
lon=ncgetvar(filename_t,'geolon_c');
lat=ncgetvar(filename_t,'geolat_c');
zt=ncgetvar(filename_t,'st_ocean');

x=[64.4897
   68.2101
   70.5941
   73.3574
   76.4362
   77.3953
   77.3654
   75.7384
   73.3536
   66.1355
   62.8216
   61.7141
   61.8900
   63.1248
   64.4897];
y=[   80.3753
   80.4973
   80.4742
   80.4529
   80.2670
   79.4066
   78.7283
   77.7325
   76.9500
   76.7388
   77.6636
   78.4921
   79.0841
   79.8339
   80.3753];

in=insphpoly(lon,lat,x,y,0,90);
in=double(in);
in(in==0)=NaN;
in=repmat(in,[1 1 50]);
% temperature
tmp=squeeze(temp(:,:,:,241:end)); %last cycle 
tmp=squeeze(nanmean(tmp,4));

area=repmat(area,[1 1 50]);
area(isnan(tmp))=NaN;
total_area=in.*area;
total_area=squeeze(nansum(total_area,2)); 
total_area=squeeze(nansum(total_area,1));

tmp2=tmp.*in.*area;
tmp2=squeeze(nansum(tmp2,2));
tmp2=squeeze(nansum(tmp2,1));
temp_st_anna=tmp2./total_area;

% salinity
tmp=squeeze(salt(:,:,:,241:end)); %last cycle 
tmp=squeeze(nanmean(tmp,4));
tmp2=tmp.*in.*area;
tmp2=squeeze(nansum(tmp2,2));
tmp2=squeeze(nansum(tmp2,1));
salt_st_anna=tmp2./total_area;

save('matfiles/gfdl_mom_st_anna_profiles.mat','temp_st_anna','salt_st_anna','zt')




clear all

grid_file='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/noc/19a_model_domain/ORCA1-N403_area.nc';
area=ncgetvar(grid_file,'area');

filename_s='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/noc/18_temp_sal_velocity_tracer_means_first_and_last_cycles/ORCA1-N403_1948to2007y60_ptemp_salin_pass5.nc'
filename_t='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/noc/18_temp_sal_velocity_tracer_means_first_and_last_cycles/ORCA1-N403_1948to2007y60_ptemp_salin_pass5.nc'
salt=ncgetvar(filename_s,'vosaline');
temp=ncgetvar(filename_t,'votemper');
lon=ncgetvar(filename_t,'nav_lon');
lat=ncgetvar(filename_t,'nav_lat');
zt=ncgetvar(filename_t,'deptht');

% St Anna basin
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
in=repmat(in,[1 1 75]);
% temperature
tmp=temp;

area(isnan(tmp))=NaN;
total_area=in.*area;
total_area=squeeze(nansum(total_area,2)); 
total_area=squeeze(nansum(total_area,1));

tmp2=tmp.*in.*area;
tmp2=squeeze(nansum(tmp2,2));
tmp2=squeeze(nansum(tmp2,1));
temp_st_anna=tmp2./total_area;

% salinity
tmp=salt;
tmp2=tmp.*in.*area;
tmp2=squeeze(nansum(tmp2,2));
tmp2=squeeze(nansum(tmp2,1));
salt_st_anna=tmp2./total_area;

save('matfiles/noc_orca_st_anna_basin_profiles.mat','temp_st_anna','salt_st_anna','zt')




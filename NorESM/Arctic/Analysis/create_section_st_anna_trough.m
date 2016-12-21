clear all

warning off

%[X_st_anna Y_st_anna]=ginput;
%[lon_st_anna lat_st_anna]=m_xy2ll(X_st_anna,Y_st_anna)

lon=nc_varget('/home/uni/milicak/Analysis/NorESM/Arctic/Analysis/grid.nc','plon');
lat=nc_varget('/home/uni/milicak/Analysis/NorESM/Arctic/Analysis/grid.nc','plat');
load ~/Analysis/NorESM/Arctic/Analysis/st_anna_section_lonlat.mat

project_name='NOIIA_T62_tn11_sr10m60d_01';
folder_name=['/work/matsbn/archive/' project_name '/ocn/hist/']
%project_name='NOIIA_T62_tn11_001';
%folder_name=['/work/milicak/archive/' project_name '/ocn/hist/']
prefix=[folder_name project_name '.micom.hm.'];

datesep='-';
year_ini=1;
year_end=45;
nx=size(lon,2);
ny=size(lon,1);
sdate=sprintf('%4.4d%c%2.2d',year_ini,datesep,1);
depth=nc_varget([prefix sdate '.nc'],'depth');
nz=size(depth,1);
timeind=0;

Nz=70;

years=1
months=1

no = num2str(years,'%.4d');
no2 = num2str(months,'%.2d');

%filename=['N1850AERCN_f19_tn11_011.micom.hm.' no '-' no2 '.nc'];
%filename=['NOIIA_T62_tn11_001.micom.hm.' no '-' no2 '.nc'];
filename=[folder_name 'NOIIA_T62_tn11_sr10m60d_01.micom.hm.' no '-' no2 '.nc'];

%h=nc_varget(filename,'dz');
templvl=nc_varget(filename,'templvl');
fice=nc_varget(filename,'fice'); 
zlvl=nc_varget(filename,'depth');
for k=1:Nz
dnm(:,k)=griddata(lon,lat,squeeze(templvl(k,:,:)),lon_st_anna,lat_st_anna,'linear');
end
temp_st_anna(:,:)=dnm;

pcolor(lat_st_anna,-zlvl,temp_st_anna');shading flat;ylim([-4000 0]);colorbar
needJet2
caxis([-2 1])


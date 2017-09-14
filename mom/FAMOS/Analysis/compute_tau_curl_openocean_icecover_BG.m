clear all

fice_cr = 0.15;
%project_name = 'om3_core3_2'
%project_name = 'om3_core3_2_BG_neg'
project_name = 'om3_core3_2_BG_pos'
%project_name = 'om3_core3_2_GS_neg'
%project_name = 'om3_core3_2_GS_pos'
%project_name = 'om3_core3_ctrl'
%root_folder = '/hexagon/work/milicak/RUNS/mom/' ;
root_folder = '/export/grunchfs/unibjerknes/milicak/bckup/mom/FAMOS/';

fname = [root_folder project_name '/om3_core3/history/tau_curl_19480101.ocean_month.nc'];
fname2 = [root_folder project_name '/om3_core3/history/19480101.ice_month.nc'];
aname = '/export/grunchfs/unibjerknes/milicak/bckup/noresm/CORE2/Arctic/DATA/gfdl-mom/grids_bathymetry/ocean.static.nc';

taucurl = ncread(fname,'tau_curl');
fice = ncread(fname2,'CN');
fice = squeeze(nansum(fice,3));
%fice(fice<fice_cr) = 0.0;
area = ncread(aname,'area_t');

out = load('/fimm/home/bjerknes/milicak/Analysis/NorESM/Arctic_seaice/Analysis/region_masks.mat');
gridname = '/export/grunchfs/unibjerknes/milicak/bckup/noresm/CORE2/Arctic/DATA/gfdl-mom/grids_bathymetry/ocean.static.nc';
lon = ncread(gridname,'geolon_t');
lat = ncread(gridname,'geolat_t');
% Beaufort Gyre mask                                                            
lon1 = [-130 -130 -170 -170];                                                   
lat1 = [70.5 80.5 80.5 70.5];                                                   
lon1(end+1) = lon1(1);                                                          
lat1(end+1) = lat1(1);                                                          
in = insphpoly(lon,lat,lon1,lat1,0.,90.);                                       
in = double(in);

area = repmat(area,[1 1 size(taucurl,3)]);
mask = repmat(in,[1 1 size(taucurl,3)]);

taucurl_openocean = taucurl.*area.*mask.*(1.0-fice);
taucurl_openocean = squeeze(nansum(taucurl_openocean,1));
taucurl_openocean = squeeze(nansum(taucurl_openocean,1));
taucurl_icecover = taucurl.*area.*mask.*(fice);
taucurl_icecover = squeeze(nansum(taucurl_icecover,1));
taucurl_icecover = squeeze(nansum(taucurl_icecover,1));

savename = ['matfiles/' project_name '_taucurl_openocean_icecover_BG.mat']
save(savename,'taucurl_openocean','taucurl_icecover')

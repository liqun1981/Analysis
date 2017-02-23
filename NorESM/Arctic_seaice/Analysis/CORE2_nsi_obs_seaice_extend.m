% this routine computes time series of sea ice extend in different areas in
% noresm CORE2 simulations
clear all

root_folder = '/export/grunchfs/unibjerknes/milicak/bckup/noresm/CORE2/Arctic/DATA/';
modelname = 'seaice_obs';
gridname = '/export/grunchfs/unibjerknes/milicak/bckup/noresm/CORE2/Arctic/DATA/seaice_obs/nsidc_sic_north_1979_2015_landundef_latlon.nc';

lon = ncread(gridname,'lon');
lat = ncread(gridname,'lat');

resolution = 1; %1; %0.5;
nx = size(lon,1);
ny = size(lat,1);
[x y] = meshgrid(lon,lat);
lon = x';
lat = y';
deg2rad = pi/180;
grid_corner_lat = zeros(4,nx,ny);
grid_corner_lon = zeros(4,nx,ny);
grid_corner_lat(1,:,:) = lat-0.5*resolution;
grid_corner_lat(2,:,:) = lat-0.5*resolution;
grid_corner_lat(3,:,:) = lat+0.5*resolution;
grid_corner_lat(4,:,:) = lat+0.5*resolution;
grid_corner_lon(1,:,:) = lon-0.5*resolution;
grid_corner_lon(2,:,:) = lon+0.5*resolution;
grid_corner_lon(3,:,:) = lon+0.5*resolution;
grid_corner_lon(4,:,:) = lon-0.5*resolution;
grid_area = 2*(sin(grid_corner_lat(4,1,:)*deg2rad) ...
                -sin(grid_corner_lat(1,1,:)*deg2rad))*pi/nx;
grid_area=ones(nx,1)*reshape(grid_area,1,[]);
rad2m=distdim(1,'rad','m');
area = grid_area*rad2m*rad2m;
area = repmat(area,[1 1 348]);
ice_cr = 0.15;

out = load('region_masks.mat');
% lon1,lat1 is for Kara and Barents Sea
% lon2,lat2 is for Greenland Sea
% lon3,lat3 is for Hudson Bay
% lon4,lat4 is for CAA
% lon5,lat5 is for Arctic Ocean Canadian side
% lon6,lat6 is for Labrador Sea/ Baffin Bay
% lon7,lat7 is for Arctic Ocean Eurasian side
% lon8,lat8 is for Bering Sea

tmp1 = [{'out.lon1'} {'out.lon2'} {'out.lon3'} {'out.lon4'} {'out.lon5'} {'out.lon6'} {'out.lon7'} {'out.lon8'}];
tmp2 = [{'out.lat1'} {'out.lat2'} {'out.lat3'} {'out.lat4'} {'out.lat5'} {'out.lat6'} {'out.lat7'} {'out.lat8'}];

regionnames = [{'KaraBarents'} {'Greenland'} {'Hudson'} {'CAA'} {'Canadian'} {'Labrador'} {'Eurasian'} {'Bering'}];

masks = containers.Map;
ice_ext_regions = containers.Map;

fname = '/nsidc_sic_north_1979_2015_landundef_latlon.nc';
icevariable = 'sic';
filename = [root_folder modelname '/' fname];

ice = ncread(filename,icevariable);
% year from 1979 to 2007 ==> 348 months
ice = ice(:,:,1:348);

% specific to observation
ice = ice;
ice(ice < ice_cr) = NaN;

for i = 1:8
    in = insphpoly(lon,lat,eval(tmp1{i}),eval(tmp2{i}),0,90);
    in = double(in);
    in(in==0) = NaN;
    masks(num2str(i)) = in;
    mask = in;
    mask = repmat(mask,[1 1 348]);
    tmp = ice.*mask.*area;
    tmp = squeeze(nansum(tmp,1));
    tmp = squeeze(nansum(tmp,1));
    ice_ext_regions(regionnames{i}) = tmp;
end
savename = ['matfiles/' modelname '_ice_extentions.mat'];
save(savename,'ice_ext_regions')

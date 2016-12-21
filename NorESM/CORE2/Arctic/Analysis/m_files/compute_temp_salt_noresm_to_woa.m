clear all

map_file='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/maps/map_noresm_tnx1v1_to_woa09_1deg_aave_.nc';
%map_file='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/maps/map_noresm_tnx1v1_to_woa09_1deg_patch_.nc';
% Read regrid indexes and weights
n_a=ncgetdim(map_file,'n_a');
n_b=ncgetdim(map_file,'n_b');
S=sparse(ncgetvar(map_file,'row'),ncgetvar(map_file,'col'), ...
         ncgetvar(map_file,'S'),n_b,n_a);

% Get dimensions, longitude and latitude of WOA09 grid
dst_grid_dims=ncgetvar(map_file,'dst_grid_dims');
nx_b=dst_grid_dims(1);
ny_b=dst_grid_dims(2);
lon_b=reshape(ncgetvar(map_file,'xc_b'),nx_b,ny_b);
lat_b=reshape(ncgetvar(map_file,'yc_b'),nx_b,ny_b);
lon_b=lon_b(:,1);
lat_b=lat_b(1,:)';

filename_s='/work/milicak/RUNS/noresm/CORE2/Arctic/DATA/NorESM/NOIIA_T62_tn11_sr10m60d_01_salinity_pendatal_1-300.nc';
filename_t='/work/milicak/RUNS/noresm/CORE2/Arctic/DATA/NorESM/NOIIA_T62_tn11_sr10m60d_01_temperature_pendatal_1-300.nc';
salt=ncgetvar(filename_s,'saln');
temp=ncgetvar(filename_t,'temp');
lon=ncgetvar(filename_t,'TLON');
lat=ncgetvar(filename_t,'TLAT');
zt=ncgetvar(filename_t,'depth'); %convert cm to meter

tmp=squeeze(temp(:,:,:,49:end)); %last cycle 
temp=squeeze(nanmean(tmp,4));
tmp=squeeze(salt(:,:,:,49:end)); %last cycle 
salt=squeeze(nanmean(tmp,4));
clear tmp

% Interpolate model data to WOA09 grid
for k=1:size(salt,3)
  s_a=reshape(salt(:,:,k),[],1);
  s_b(:,:,k)=reshape(S*s_a,nx_b,ny_b);
  t_a=reshape(temp(:,:,k),[],1);
  t_b(:,:,k)=reshape(S*t_a,nx_b,ny_b);
end

savename='matfiles/noresm_micom_woa_tempsalt.mat'
save(savename,'lon_b','lat_b','s_b','t_b','zt')

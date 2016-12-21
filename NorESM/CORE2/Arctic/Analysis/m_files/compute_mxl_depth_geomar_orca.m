clear all
rho_cr=0.1;

filename_s='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/geomar/ORCA05_5yr_19480101_20071231_vosaline.nc';
filename_t='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/geomar/ORCA05_5yr_19480101_20071231_votemper.nc';
salt=ncgetvar(filename_s,'vosaline');
temp=ncgetvar(filename_t,'votemper');
temp(temp==0)=NaN;
salt(salt==0)=NaN;
lon=ncgetvar(filename_t,'nav_lon');
lat=ncgetvar(filename_t,'nav_lat');
zt=ncgetvar(filename_t,'deptht');

temp=squeeze(temp(:,:,:,end)); %last cycle
salt=squeeze(salt(:,:,:,end)); %last cycle

rho=sw_dens0(salt,temp);

Nx=size(rho,1);
Ny=size(rho,2);
Nz=size(rho,3);

ztref=0:1:max(zt);

for i=1:Nx
for j=1:Ny
  if(isnan(rho(i,j,1))==0)
    kind=1;
    rhoref=interp1(zt,squeeze(rho(i,j,:)),ztref);
    if(isnan(rhoref(1))==1)
      ind1=min(find(isnan(rhoref)==0));
      rhoref(1:ind1-1)=rhoref(ind1);
    end
%    for k=2:Nz
%      drho=rho(i,j,k)-rho(i,j,1);
    for k=2:length(rhoref)
      drho=rhoref(k)-rhoref(1);
      if(drho<=rho_cr)
        kind=k;
      end
    end
    %mxl(i,j)=zt(kind);
    mxl(i,j)=ztref(kind);
  else
    mxl(i,j)=NaN;
  end
end
end

save('matfiles/geomar_orca_mxl_depth.mat','lon','lat','mxl')




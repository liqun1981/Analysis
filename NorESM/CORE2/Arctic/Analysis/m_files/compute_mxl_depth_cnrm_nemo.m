clear all
rho_cr=0.1;


filename_s='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/nemo-cnrm/CNRM_TSUV_decade.nc';
filename_t='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/nemo-cnrm/CNRM_TSUV_decade.nc';
lon=ncgetvar(filename_t,'lon');
lat=ncgetvar(filename_t,'lat');
zt=ncgetvar(filename_t,'gdept');

salt=ncgetvar(filename_s,'S_decade_Cy1');
temp=ncgetvar(filename_t,'T_decade_Cy1');
salt(:,:,:,7:12)=ncgetvar(filename_s,'S_decade_Cy2');
temp(:,:,:,7:12)=ncgetvar(filename_t,'T_decade_Cy2');
salt(:,:,:,13:18)=ncgetvar(filename_s,'S_decade_Cy3');
temp(:,:,:,13:18)=ncgetvar(filename_t,'T_decade_Cy3');
salt(:,:,:,19:24)=ncgetvar(filename_s,'S_decade_Cy4');
temp(:,:,:,19:24)=ncgetvar(filename_t,'T_decade_Cy4');
salt(:,:,:,25:30)=ncgetvar(filename_s,'S_decade_Cy5');
temp(:,:,:,25:30)=ncgetvar(filename_t,'T_decade_Cy5');

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

save('matfiles/cnrm_nemo_mxl_depth.mat','lon','lat','mxl')




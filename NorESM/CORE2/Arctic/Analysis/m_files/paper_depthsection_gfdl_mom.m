clear all
sec_depth=400; %section depth
sec_depth=5

filename_s='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/annual_tracers/ocean.1708-2007.salt.nc';
filename_t='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/annual_tracers/ocean.1708-2007.temp.nc';
filename_u='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/annual_velocity/u_1948_2007.mat';
filename_u='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/annual_velocity/ocean.1948-2007.u.nc';
filename_v='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/gfdl-mom/annual_velocity/ocean.1948-2007.v.nc';

uvel=ncgetvar(filename_u,'u');
vvel=ncgetvar(filename_v,'v');

salt=ncgetvar(filename_s,'salt');
temp=ncgetvar(filename_t,'temp'); 
lon=ncgetvar(filename_t,'geolon_t');
lat=ncgetvar(filename_t,'geolat_t');
lonu=ncgetvar(filename_t,'geolon_c');
latv=ncgetvar(filename_t,'geolat_c');
zt=ncgetvar(filename_t,'st_ocean');

timeind=1
kind=max(find(zt<=sec_depth));
if(zt(kind)<=sec_depth)
dx1=sec_depth-zt(kind);
dx2=zt(kind+1)-sec_depth;
end

%tmp=squeeze(uvel(:,:,kind:kind+1,1:end)); %last cycle 
tmp=squeeze(uvel(:,:,kind:kind+1,31:end));
tmp2=squeeze(nanmean(tmp,4));
uvel=(squeeze(tmp2(:,:,2)).*dx1+squeeze(tmp2(:,:,1)).*dx2)./(dx1+dx2);

%tmp=squeeze(vvel(:,:,kind:kind+1,1:end)); %last cycle 
tmp=squeeze(vvel(:,:,kind:kind+1,31:end));
tmp2=squeeze(nanmean(tmp,4));
vvel=(squeeze(tmp2(:,:,2)).*dx1+squeeze(tmp2(:,:,1)).*dx2)./(dx1+dx2);

%rotate the velocities
[ur,vr]=vecrotc(lon,lat,uvel,vvel,'B');
%ind=find(isnan(uvel)~=1 & isnan(vvel)~=1);
%ind1=find(isnan(ur)~=1 & isnan(vr)~=1);

%tmp=squeeze(temp(:,:,kind:kind+1,241:end)); %last cycle 
tmp=squeeze(temp(:,:,kind:kind+1,271:end)); 
tmp2=squeeze(nanmean(tmp,4));
temp=(squeeze(tmp2(:,:,2)).*dx1+squeeze(tmp2(:,:,1)).*dx2)./(dx1+dx2);

%tmp=squeeze(salt(:,:,kind:kind+1,241:end)); %last cycle 
tmp=squeeze(salt(:,:,kind:kind+1,271:end));
tmp2=squeeze(nanmean(tmp,4));
salt=(squeeze(tmp2(:,:,2)).*dx1+squeeze(tmp2(:,:,1)).*dx2)./(dx1+dx2);

if 0
figure(1)
m_proj('stereographic','lat',90,'long',0,'radius',25,'rect','on');
m_ncquiverref(lonu,latv,ur,vr,'m/s',0.0001,'b');
title('GFDL-MOM')
m_coast('patch',[.7 .7 .7],'edgecolor','k');
m_grid
m_grid('xtick',[-120 -60 0 60 120])
fontsize=18;
%set(findall(gcf,'type','text'),'FontSize',fontsize)
set(gca,'fontsize',fontsize)
set(gcf,'color','w');
printname=['paperfigs2/gfdl_mom_uv_horizontal_section_' num2str(sec_depth)];
print(1,'-depsc2','-r150',printname)
close all
end

figure(1)
m_proj('stereographic','lat',90,'long',0,'radius',25);
m_pcolor(lon,lat,salt);shading interp;needJet2;caxis([34.2 35.2])
if(sec_depth==5)
caxis([25 35])
elseif(sec_depth==400)
caxis([34.2 35.2])
end
m_coast('patch',[.7 .7 .7],'edgecolor','k');
%xlabel('Lon'); ylabel('Lat');
colorbar off
title('GFDL-MOM')
m_grid('xtick',[-120 -60 0 60 120])
     fontsize=18;
     set(findall(gcf,'type','text'),'FontSize',fontsize)
     set(gca,'fontsize',fontsize)
     set(gcf,'color','w');
%printname=['paperfigs/gfdl_mom_salt_horizontal_section_' num2str(sec_depth)];
printname=['paperfigs2/gfdl_mom_salt_horizontal_section_' num2str(sec_depth)];
print(1,'-depsc2','-r150',printname)
export_fig(1,printname,'-eps','-r150');
close all
%break

figure(1)
m_proj('stereographic','lat',90,'long',0,'radius',25);
m_pcolor(lon,lat,temp);shading interp;needJet2;caxis([-2 5])
if(sec_depth==5)
caxis([-1 8])
%x = [-2:0.15:2.75 3:0.5:8];
x = [-2:0.05:0 5 -1.43 -1.53 -1.33 4.4 5.4 1:0.6:8 8];
x = [-2:0.05:0 1:0.6:8 8]; %with jet4
x = [-2:0.05:0 -1.63 -1.53 -1.43 -1.33 -1.23 -1.73  1:0.6:8 8];
x=sort(x);
Nx = length(x);
clim = [min(x) max(x)];
dx = min(diff(x));
y = clim(1):dx:clim(2);
for k=1:Nx-1, y(y>x(k) & y<=x(k+1)) = x(k+1); end % NEW
cmap = colormap(jet(Nx));
f1=load('/fimm/home/bjerknes/milicak/matlab/tools/jet5');
cmap=f1;
cmap2 = [...
interp1(x(:),cmap(:,1),y(:)) ...
interp1(x(:),cmap(:,2),y(:)) ...
interp1(x(:),cmap(:,3),y(:)) ...
];
caxis([-1 8])
colormap(cmap2)
caxis(clim)
elseif(sec_depth==400)
caxis([-2 5])
end
m_coast('patch',[.7 .7 .7],'edgecolor','k');
%xlabel('Lon'); ylabel('Lat');
colorbar off
title('GFDL-MOM')
m_grid('xtick',[-120 -60 0 60 120])
     fontsize=18;
     set(findall(gcf,'type','text'),'FontSize',fontsize)
     set(gca,'fontsize',fontsize)
     set(gcf,'color','w');
printname=['paperfigs2/gfdl_mom_temp_horizontal_section_' num2str(sec_depth)];
%printname=['paperfigs/gfdl_mom_temp_horizontal_section_' num2str(sec_depth)];
print(1,'-depsc2','-r150',printname)
export_fig(1,printname,'-eps','-r150');
break
close all

figure(1)
m_proj('stereographic','lat',90,'long',0,'radius',25);
m_proj('stereographic','lat',90,'long',0,'radius',25,'rect','on');
h=m_quiver(lonu(ind1),latu(ind1),ur(ind1),vr(ind1),0,'k');
hU = get(h,'UData') ;
hV = get(h,'VData') ;
qscale=25;
set(h,'UData',qscale*hU,'VData',qscale*hV,'linewidth',.5)
adjust_quiver_arrowhead_size(h,2);
m_coast('patch',[.7 .7 .7],'edgecolor','k');
m_grid
printname=['paperfigs/gfdl_mom_uv_horizontal_section_' num2str(sec_depth)];
print(1,'-depsc2','-r150',printname)
close all




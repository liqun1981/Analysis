clear all
sec_depth=400; %section depth
sec_depth=5

filename_u='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/mir-data/u_pentadal.nc';
filename_v='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/mir-data/v_pentadal.nc';
filename_s='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/mir-data/salinity_pentadal.nc';
filename_t='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/mir-data/temperature_pentadal.nc';
gridfile='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/mir-data/lonlat_t.nc';
uvel=ncgetvar(filename_u,'u');
vvel=ncgetvar(filename_v,'v');
salt=ncgetvar(filename_s,'s');
temp=ncgetvar(filename_t,'temp'); 
lon=ncgetvar(gridfile,'glon_t');
lat=ncgetvar(gridfile,'glat_t');
zt=ncgetvar(filename_t,'level');

uvel(uvel<-100)=NaN;    
vvel(vvel<-100)=NaN;
timeind=1
kind=max(find(zt<=sec_depth));

%tmp=squeeze(uvel(:,:,kind,1:end)); %last cycle 
tmp=squeeze(uvel(:,:,kind,7:end));
uvel=squeeze(nanmean(tmp,3));
%tmp=squeeze(vvel(:,:,kind,1:end)); %last cycle 
tmp=squeeze(vvel(:,:,kind,7:end));
vvel=squeeze(nanmean(tmp,3));

%tmp=squeeze(temp(:,:,kind,1:end)); %last cycle 
tmp=squeeze(temp(:,:,kind,7:end)); 
temp=squeeze(nanmean(tmp,3));

%tmp=squeeze(salt(:,:,kind,1:end)); %last cycle 
tmp=squeeze(salt(:,:,kind,7:end));
salt=squeeze(nanmean(tmp,3));

temp(temp<-100)=NaN;
salt(salt<-100)=NaN;

if 0
[ur,vr]=vecrotc(lon,lat,uvel,vvel,'C');
ur(ur<-100)=NaN;    
vr(vr<-100)=NaN;
ur=ur.*1e-2;    
vr=vr.*1e-2;

figure(1)
m_proj('stereographic','lat',90,'long',0,'radius',25,'rect','on');
m_ncquiverref(lon,lat,ur,vr,'m/s',0.0002,'b');
title('MRI-A')
m_coast('patch',[.7 .7 .7],'edgecolor','k');
m_grid
m_grid('xtick',[-120 -60 0 60 120])
fontsize=18;
%set(findall(gcf,'type','text'),'FontSize',fontsize)
set(gca,'fontsize',fontsize)
set(gcf,'color','w');
printname=['paperfigs2/mri_data_uv_horizontal_section1_' num2str(sec_depth)];
print(1,'-depsc2','-r150',printname)
close all
break

%rotate the velocities
ind=find(isnan(uvel)~=1 & isnan(vvel)~=1);
ind1=find(isnan(ur)~=1 & isnan(vr)~=1 & ur~=0 & vr~=0);
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
colorbar off
title('MRI-A')
m_grid('xtick',[-120 -60 0 60 120])
     fontsize=18;
     set(findall(gcf,'type','text'),'FontSize',fontsize)
     set(gca,'fontsize',fontsize)
     set(gcf,'color','w');
%xlabel('Lon'); ylabel('Lat');
%printname=['paperfigs/mir_data_salt_horizontal_section_' num2str(sec_depth)];
printname=['paperfigs2/mir_data_salt_horizontal_section_' num2str(sec_depth)];
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
title('MRI-A')
m_grid('xtick',[-120 -60 0 60 120])
     fontsize=18;
     set(findall(gcf,'type','text'),'FontSize',fontsize)
     set(gca,'fontsize',fontsize)
     set(gcf,'color','w');
printname=['paperfigs2/mri_data_temp_horizontal_section_' num2str(sec_depth)];
%printname=['paperfigs/mir_data_temp_horizontal_section_' num2str(sec_depth)];
print(1,'-depsc2','-r150',printname)
export_fig(1,printname,'-eps','-r150');
break
close all

figure(1)
m_proj('stereographic','lat',90,'long',0,'radius',25,'rect','on');
h=m_quiver(lon(ind1),lat(ind1),ur(ind1),vr(ind1),0,'k');
hU = get(h,'UData') ;
hV = get(h,'VData') ;
qscale=25;
set(h,'UData',qscale*hU,'VData',qscale*hV,'linewidth',.5)
%adjust_quiver_arrowhead_size(h,2);
m_coast('patch',[.7 .7 .7],'edgecolor','k');
m_grid
printname=['paperfigs/mir_data_uv_horizontal_section_' num2str(sec_depth)];
print(1,'-depsc2','-r150',printname)
close all


close all


clear all
rearth=6370;
int_method='conserve';

% MOM Fram Strait
map_file='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/maps/map_mom_0_25_to_section.nc';
filename_s='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/mom0.25/ocean.salt.pent_avg.last_cycle_COREyr1948_2007.nc';
filename_t='/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/DATA/mom0.25/ocean.temp.pent_avg.last_cycle_COREyr1948_2007.nc';

%salt=ncgetvar(filename_s,'salt');
temp=ncgetvar(filename_t,'temp');
zt=ncgetvar(filename_t,'st_ocean');
%temp(temp<-100)=NaN;
%salt(salt<-100)=NaN;

size(temp)
%tmp=squeeze(temp(:,:,:,1:end)); %last cycle 
tmp=squeeze(temp(:,:,:,7:end)); %last cycle 
temp=squeeze(nanmean(tmp,4));
%tmp=squeeze(salt(:,:,:,241:end)); %last cycle 
%salt=squeeze(nanmean(tmp,4));
clear tmp

section=map_scalar2section(temp,map_file,int_method);
section(2).name='Arctic 70E';

for i_sec=1:5 %length(section)
  figure(i_sec);clf
  pcolor([0 section(i_sec).edge_dist]*rearth,-zt, ...
         [section(i_sec).data;section(i_sec).data(end,:)]');
  shading flat;colorbar
  title([ 'MOM-0.25 ' section(i_sec).name])
  xlabel('Distance (km)')
  ylabel('Depth (m)')
  if(i_sec==1)
     ylim([-4000 0]);
     caxis([-1.5 3.5])
     printname=['paperfigs/mom_0_25_fram_strait_section'];
  elseif(i_sec==2)
     ylim([-4500 0]);
     caxis([-1.5 1.5])
     title('MOM0.25')
     colorbar off
     fontsize=18;
     set(findall(gcf,'type','text'),'FontSize',fontsize)
     set(gca,'fontsize',fontsize)
     set(gcf,'color','w');
     %printname=['paperfigs/mom_0_25_Arctic70E_section'];
     printname=['paperfigs2/mom_0_25_Arctic70E_section'];
  elseif(i_sec==3)
     ylim([-3000 0]);
     caxis([-1.5 3.5])
     printname=['paperfigs/mom_0_25_fram_strait_79_5_section'];
  elseif(i_sec==4)
     ylim([-4500 0]);
     caxis([-1.5 7])
     interpcolormap([[0 0 .1];[0 0 1];[0 1 1];[0 1 0];[1 1 0];[1 0 1];[1 0 0];[1 .9 .8]],[1 1 1 1 1.3 .7 1.3],'l');
     title('MOM0.25')
     colorbar off
     fontsize=18;
     set(findall(gcf,'type','text'),'FontSize',fontsize)
     set(gca,'fontsize',fontsize)
     set(gcf,'color','w');
     %printname=['paperfigs/mom_0_25_Atlantic_inflow_section'];
     printname=['paperfigs2/mom_0_25_Atlantic_inflow_section'];
  elseif(i_sec==5)
     ylim([-650 0]);
     caxis([2 7])
     printname=['paperfigs/mom_0_25_Barents_Sea_section'];
  end
  print(i_sec,'-depsc2','-r150',printname)
  if(i_sec==2 | i_sec==4)
   export_fig(i_sec,printname,'-eps','-r150');  
  end
end
  close all


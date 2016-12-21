clear all

pathname='/hexagon/work/milicak/archive/';
project_name='N1850_f19_tn11_01_default'
%project_name='NOIIA_T62_tn11_ctrl'
%project_name='NOIIA_T62_tn11_sr10m60d_01'

Nz=53; %number of layers
TAW_cri=4;  %critical temperature for the Atlantic water
SEG_cri=34.5; %critical salinity for the East Greenland current
ow_layer=36; %overflow layer and below
area=nc_varget('../../climatology/Analysis/grid.nc','parea');

pathnameurho=[pathname project_name '/ocn/hist/'];
pathnamevrho=[pathname project_name '/ocn/hist/'];
pathnametrho=[pathname project_name '/ocn/hist/'];
pathnamesrho=[pathname project_name '/ocn/hist/'];
pathnamedzrho=[pathname project_name '/ocn/hist/'];

yearsini=1;
yearsend=265;

[BSO CAA DS EC IFS FS BS]=sections_noresm_tripolar;
NSS=[DS;IFS]; % total Nordic Sea Section
for i=1:size(NSS,1)
  areasect(1:Nz,i)=area(NSS(i,2),NSS(i,1));
end
clear area

timeind=1;
for time=yearsini:yearsend
   for month=1:12
     sdate=sprintf('%4.4d%c%2.2d',time,'-',month);
     %netcdf files
     filenameurho=[pathnameurho project_name '.micom.hm.' sdate '.nc'];
     filenamevrho=[pathnameurho project_name '.micom.hm.' sdate '.nc'];
     filenametrho=[pathnameurho project_name '.micom.hm.' sdate '.nc'];
     filenamesrho=[pathnameurho project_name '.micom.hm.' sdate '.nc'];
     filenamedzrho=[pathnameurho project_name '.micom.hm.' sdate '.nc'];
     utr=nc_varget(filenameurho,'uflx',[0 0 0 0],[1 -1 -1 -1]);
     vtr=nc_varget(filenamevrho,'vflx',[0 0 0 0],[1 -1 -1 -1]);
     utr(isnan(utr))=0;
     vtr(isnan(vtr))=0;
     temp=nc_varget(filenametrho,'temp',[0 0 0 0],[1 -1 -1 -1]);
     salt=nc_varget(filenamesrho,'saln',[0 0 0 0],[1 -1 -1 -1]);
     dzrho=nc_varget(filenamedzrho,'dz',[0 0 0 0],[1 -1 -1 -1]);
     % salt has dimensions of Nz, Ny Nx
% compute Atlantic Water, EGC, IFS, DS overflow temperature, salinity and transport    
     i1=1;clear tempsect saltsect transsect transsectu transsectv dzsect
     for i=1:size(NSS,1)
       tempsect(:,i1)=temp(:,NSS(i,2),NSS(i,1));
       saltsect(:,i1)=salt(:,NSS(i,2),NSS(i,1));
       dzsect(:,i1)=dzrho(:,NSS(i,2),NSS(i,1));
       transsect(:,i1)=(utr(:,NSS(i,2),NSS(i,1)).*NSS(i,3)+vtr(:,NSS(i,2),NSS(i,1)).*NSS(i,4))*1e-9;
       i1=i1+1;
     end

     for i=1:size(tempsect,2)
       clear kind kstr ktop
       ktop=[];
% Assumption that EGC will be fresher than 34.5 psu
       ind1=min(min(find(saltsect(:,i)<=SEG_cri)),ow_layer-1); %34th layer
       ind2=min(max(find(saltsect(:,i)<=SEG_cri)),ow_layer-1); %34th layer
       if(isempty(ind1)==0)
         kstr=ind1;
         kend=ind2;
         kind=kstr:kend;
         if(kstr>1)
           ktop=1:kstr-1;
         end
         if(isempty(find(tempsect(ktop,i)<0.5)) ==0)
           dnm=find(tempsect(ktop,i)<0.5);
           kind=[dnm' kind];
           ktop=dnm(end)+1:kstr-1;
         end
         aa=1-isnan(tempsect(kind,i));
         dnm=tempsect(kind,i).*(aa.*dzsect(kind,i).*areasect(kind,i));
         tempEG(i)=nansum(dnm);
         volumeEG(i)=nansum(aa.*dzsect(kind,i).*areasect(kind,i));
         dnm=saltsect(kind,i).*(aa.*dzsect(kind,i).*areasect(kind,i));
         saltEG(i)=nansum(dnm);
         dnm=transsect(kind,i);
         trEG(i)=nansum(dnm);
       else
         tempEG(i)=NaN;
         saltEG(i)=NaN;
         trEG(i)=0;
         volumeEG(i)=0;
         kind=0;
         kstr=0;
         kend=0;
       end

% Atlantic Water ==> defined as layers above 35 and saltier than SEG_cri
       if(i<=size(DS,1))
         ind1=max(min(find(saltsect(:,i)>SEG_cri)),kind(end)+1);
         ind2=min(max(find(saltsect(:,i)>SEG_cri)),ow_layer-1);
       else
         ind1=max(min(find(tempsect(:,i)>=TAW_cri)),kind(end)+1);
         ind2=max(find(tempsect(:,i)>=TAW_cri));
       end
       if(isempty(ind1)==0 & ind1<ind2)
         kstr=ind1;
         kend=ind2;
         if(isempty(kstr)==0)
           kind=[ktop kstr:kend];
         else
           kind=kstr:kend;
         end
         aa=1-isnan(tempsect(kind,i));
         dnm=tempsect(kind,i).*(aa.*dzsect(kind,i).*areasect(kind,i));
         tempAW(i)=nansum(dnm);
         volumeAW(i)=nansum(aa.*dzsect(kind,i).*areasect(kind,i));
         dnm=saltsect(kind,i).*(aa.*dzsect(kind,i).*areasect(kind,i));
         saltAW(i)=nansum(dnm);
         dnm=transsect(kind,i);
         trAW(i)=nansum(dnm);
       else
         tempAW(i)=NaN;
         saltAW(i)=NaN;
         trAW(i)=0; 
         volumeAW(i)=0;
       end

% Overflow water ==> the rest 
       if(i<=size(DS,1))
         kstr=min(ow_layer,kind(end)+1);
       else
         kstr=min(Nz,kind(end)+1);
       end
       kind=kstr:Nz;
       aa=1-isnan(tempsect(kind,i));
       dnm=tempsect(kind,i).*(aa.*dzsect(kind,i).*areasect(kind,i));
       tempOW(i)=nansum(dnm);
       volumeOW(i)=nansum(aa.*dzsect(kind,i).*areasect(kind,i));
       dnm=saltsect(kind,i).*(aa.*dzsect(kind,i).*areasect(kind,i));
       saltOW(i)=nansum(dnm);
       dnm=transsect(kind,i);
       trOW(i)=nansum(dnm);
     end

     TEGC(timeind)=nansum(tempEG)/nansum(volumeEG);
     SEGC(timeind)=nansum(saltEG)/nansum(volumeEG);
     TrEGC(timeind)=nansum(trEG(:));
     TAW(timeind)=nansum(tempAW)/nansum(volumeAW);
     SAW(timeind)=nansum(saltAW)/nansum(volumeAW);
     TrAW(timeind)=nansum(trAW(:));
     TOW(timeind)=nansum(tempOW)/nansum(volumeOW);
     SOW(timeind)=nansum(saltOW)/nansum(volumeOW);
     TrOW(timeind)=nansum(trOW(:));

     savename=['matfiles/' project_name '_' num2str(yearsini) '_' num2str(yearsend) '_tempsalttransports'];
     save(savename,'TAW','SAW','TrAW','TEGC','SEGC','TrEGC','TOW','SOW','TrOW')

     timeind=timeind+1
   end %month
end %time



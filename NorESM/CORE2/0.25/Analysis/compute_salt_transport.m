% this subroutine computes monthly mean net mass flux which is
% sum of precip (lip+sop) + eva (eva) + melt (fmltfz) + river (rnf+rfi)

% 1 for atlantic_arctic_ocean region
% 2 for indian_pacific_ocean region
% 3 for global_ocean

clear all

m2y=1; % if it is monthly then m2y=1; if it is yearly data then m2y=0;
% Jan Feb Mar Apr May June July Aug Sep Oct Nov Dec
months2days=[31  28  31  30  31   30   31  31   30 31   30 31];
yeardays=sum(months2days);

if m2y==1
  expid='NOIIA_T62_tn11_sr10m60d_02';
else
  expid='NOIIA_T62_tn025_001';
end
datesep='-';
%grid_file='/work/shared/noresm/inputdata/ocn/micom/tnx1v1/20120120/grid.nc';
%grid_file='/home/fimm/bjerknes/milicak/Analysis/NorESM/climatology/Analysis/grid.nc';
fyear=1;

if m2y==1
  prefix=['/export/grunchfs/green/matsbn/archive/' expid '/ocn/hist/' expid '.micom.hm.'];
  lyear=60;
else
  prefix=['/hexagon/work/milicak/archive/' expid '/ocn/hist/' expid '.micom.hy.'];
  lyear=120;
end

% Get dimensions and time attributes
if m2y==1
  sdate=sprintf('%4.4d%c%2.2d',fyear,datesep,1);
else
  sdate=sprintf('%4.4d%c%2.2d',fyear);
end
nx=ncgetdim([prefix sdate '.nc'],'x');
ny=ncgetdim([prefix sdate '.nc'],'y');
ny=ny-1;
time_long_name=ncgetatt([prefix sdate '.nc'],'long_name','time');
time_units=ncgetatt([prefix sdate '.nc'],'units','time');
time_calendar=ncgetatt([prefix sdate '.nc'],'calendar','time');
lat=ncgetvar([prefix sdate '.nc'],'lat');

% Retrieve mixed layer depths and write to netcdf variables
n=0;
for year=fyear:lyear
  if m2y==1
    tmp1=zeros(size(lat,1),3);
    tmp2=zeros(size(lat,1),3);
    tmp3=zeros(size(lat,1),3);
    for month=1:12
      sdate=sprintf('%4.4d%c%2.2d',year,datesep,month);
      disp(sdate)
      tmp=ncgetvar([prefix sdate '.nc'],'msflx');
      tmp1=tmp1+tmp.*months2days(month);
      tmp=ncgetvar([prefix sdate '.nc'],'msfld');
      tmp2=tmp2+tmp.*months2days(month);
      tmp=ncgetvar([prefix sdate '.nc'],'msftd');
      tmp3=tmp3+tmp.*months2days(month);
    end
    n=n+1;
    msflx(n,:,:)=tmp1./(yeardays);
    msfld(n,:,:)=tmp2./(yeardays);
    msftd(n,:,:)=tmp3./(yeardays);
  else
     n=n+1;
     sdate=sprintf('%4.4d%c%2.2d',year);
     disp(sdate)
     tmp=ncgetvar([prefix sdate '.nc'],'msflx');
     msflx(n,:,:)=tmp;
     tmp=ncgetvar([prefix sdate '.nc'],'msfld');
     msfld(n,:,:)=tmp;
     tmp=ncgetvar([prefix sdate '.nc'],'msftd');
     msftd(n,:,:)=tmp;
  end %m2y
end %year

save(['matfiles/' expid '_annual_salt_flux_' num2str(fyear) '_' num2str(lyear) ],'msfld','msflx','msftd','lat');

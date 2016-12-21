
clear all

expid='NOIIA_T62_tn11_sr10m60d_01';
datesep='-';
grid_file='/home/fimm/bjerknes/milicak/Analysis/NorESM/climatology/Analysis/grid.nc';
fyear=1;
lyear=300;
fill_value=-1e33;
prefix=['/hexagon/work/matsbn/archive/' expid '/ocn/hist/' expid '.micom.hm.'];

g=9.806;

% Get dimensions
sdate=sprintf('%4.4d%c%2.2d',fyear,datesep,1);
nx=ncgetdim([prefix sdate '.nc'],'x');
ny=ncgetdim([prefix sdate '.nc'],'y');
nz=ncgetdim([prefix sdate '.nc'],'sigma');
ny=ny-1;

time_long_name=ncgetatt([prefix sdate '.nc'],'long_name','time');
time_units=ncgetatt([prefix sdate '.nc'],'units','time');
time_calendar=ncgetatt([prefix sdate '.nc'],'calendar','time');

% Read grid information
plon=ncgetvar(grid_file,'plon');
plat=ncgetvar(grid_file,'plat');
parea=ncgetvar(grid_file,'parea');
pclon=ncgetvar(grid_file,'pclon');
pclat=ncgetvar(grid_file,'pclat');
plon=plon(:,1:end-1);
plat=plat(:,1:end-1);
parea=parea(:,1:end-1);
pclon=permute(pclon(:,1:end-1,:),[3 1 2]);
pclat=permute(pclat(:,1:end-1,:),[3 1 2]);
tmp=ncgetvar(grid_file,'pdepth');
pdepth=tmp(:,1:end-1,:);

% Create netcdf file.
%ncid=netcdf.create([expid '_bottom_pressure_annual_' num2str(fyear) '-' num2str(lyear) '.nc'],'NC_CLOBBER');
%ncid=netcdf.create(['/work/milicak/RUNS/noresm/CORE2/CORE2_files/SSH/' expid '_bottom_pressure_annual_' num2str(fyear) '-' num2str(lyear) '.nc'],'NC_CLOBBER');
ncid=netcdf.create(['/bcmhsm/milicak/RUNS/noresm/CORE2/SSH/' expid '_bottom_pressure_annual_' num2str(fyear) '-' num2str(lyear) '.nc'],'NC_CLOBBER');

% Define dimensions.
ni_dimid=netcdf.defDim(ncid,'ni',nx);
nj_dimid=netcdf.defDim(ncid,'nj',ny);
time_dimid=netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
nvertices_dimid=netcdf.defDim(ncid,'nvertices',4);

% Define variables and assign attributes
time_varid=netcdf.defVar(ncid,'time','float',time_dimid);
netcdf.putAtt(ncid,time_varid,'long_name',time_long_name);
netcdf.putAtt(ncid,time_varid,'units',time_units);
netcdf.putAtt(ncid,time_varid,'calendar',time_calendar);

tlon_varid=netcdf.defVar(ncid,'TLON','float',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,tlon_varid,'long_name','T grid center longitude');
netcdf.putAtt(ncid,tlon_varid,'units','degrees_east');
netcdf.putAtt(ncid,tlon_varid,'bounds','lont_bounds');

tlat_varid=netcdf.defVar(ncid,'TLAT','float',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,tlat_varid,'long_name','T grid center latitude');
netcdf.putAtt(ncid,tlat_varid,'units','degrees_north');
netcdf.putAtt(ncid,tlat_varid,'bounds','latt_bounds');

tarea_varid=netcdf.defVar(ncid,'tarea','float',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,tarea_varid,'long_name','area of T grid cells');
netcdf.putAtt(ncid,tarea_varid,'units','m^2');
netcdf.putAtt(ncid,tarea_varid,'coordinates','TLON TLAT');

lont_bounds_varid=netcdf.defVar(ncid,'lont_bounds','float',[nvertices_dimid ni_dimid nj_dimid]);
netcdf.putAtt(ncid,lont_bounds_varid,'long_name','longitude boundaries of T cells');
netcdf.putAtt(ncid,lont_bounds_varid,'units','degrees_east');

latt_bounds_varid=netcdf.defVar(ncid,'latt_bounds','float',[nvertices_dimid ni_dimid nj_dimid]);
netcdf.putAtt(ncid,latt_bounds_varid,'long_name','latitude boundaries of T cells');
netcdf.putAtt(ncid,latt_bounds_varid,'units','degrees_north');

bottom_pressure_varid=netcdf.defVar(ncid,'bottom_pressure','float',[ni_dimid nj_dimid time_dimid]);
netcdf.putAtt(ncid,bottom_pressure_varid,'long_name','Bottom Pressure');
netcdf.putAtt(ncid,bottom_pressure_varid,'units','Pa');
netcdf.putAtt(ncid,bottom_pressure_varid,'_FillValue',single(fill_value));
netcdf.putAtt(ncid,bottom_pressure_varid,'coordinates','TLON TLAT');
netcdf.putAtt(ncid,bottom_pressure_varid,'cell_measures','area: tarea');

% Global attributes

% End definitions and leave define mode.
netcdf.endDef(ncid)

% Provide values for time invariant variables.
netcdf.putVar(ncid,tlon_varid,single(plon));
netcdf.putVar(ncid,tlat_varid,single(plat));
netcdf.putVar(ncid,tarea_varid,single(parea));
netcdf.putVar(ncid,lont_bounds_varid,single(pclon));
netcdf.putVar(ncid,latt_bounds_varid,single(pclat));

% Compute bottom pressure and write to netcdf variables
n=0;

for year=fyear:lyear
  time=0;    
  pbcorr=zeros(nx,ny);
  n=n+1;

  for month=1:12
    sdate=sprintf('%4.4d%c%2.2d',year,datesep,month);
    disp(sdate)
    tmp=ncgetvar([prefix sdate '.nc'],'temp');
    temp=tmp(:,1:end-1,:);
    tmp=ncgetvar([prefix sdate '.nc'],'saln');
    saln=tmp(:,1:end-1,:);
    tmp=ncgetvar([prefix sdate '.nc'],'dp');
    dp=tmp(:,1:end-1,:);
    tmp=ncgetvar([prefix sdate '.nc'],'sealv');
    sealv=tmp(:,1:end-1,:);
    temp(find(isnan(temp)))=3;
    saln(find(isnan(saln)))=35;
    tmp=ncgetvar([prefix sdate '.nc'],'time');
    time=time+tmp;

    for iter=1:5
      p=zeros(nx,ny,nz+1);
      for k=2:nz+1
        p(:,:,k)=p(:,:,k-1)+dp(:,:,k-1);
      end
      p=p*1e-4;
      dz=p_alpha(p(:,:,2:end),p(:,:,1:end-1),temp,saln)/g*1e4;
      dsealv=sum(dz,3)-pdepth-sealv;
      ind=find(~isnan(dsealv));
      disp(sprintf('rmse = %8.4f', ...
             sqrt(sum((dsealv(ind).^2).*parea(ind))/sum(parea(ind)))))
      q=(pdepth+sealv)./sum(dz,3);
      dp=dp.*reshape(reshape(q,[],1)*ones(1,nz),nx,ny,nz);
    end      
    pbcorr=pbcorr+sum(dp,3);
  end %month

  pbcorr=pbcorr/12;
  time=time/12;
  pbcorr(isnan(pbcorr))=fill_value;

  netcdf.putVar(ncid,time_varid,n-1,1,single(time));
  netcdf.putVar(ncid,bottom_pressure_varid,[0 0 n-1],[nx ny 1],single(pbcorr));
end

% Close netcdf file
netcdf.close(ncid)


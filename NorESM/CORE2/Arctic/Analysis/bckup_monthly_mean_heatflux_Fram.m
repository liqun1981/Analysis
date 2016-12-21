% this subroutine computes monthly mean heat flux at Fram strait
clear all

%expid='NOIIA_T62_tn11_bblsr10m30d_01';
expid='NOIIA_T62_tn11_sr10m60d_01';
datesep='-';
%grid_file='/work/shared/noresm/inputdata/ocn/micom/tnx1v1/20120120/grid.nc';
grid_file='/home/fimm/bjerknes/milicak/Analysis/NorESM/climatology/Analysis/grid.nc';
fyear=1;
lyear=3;
fill_value=-1e33;

prefix=['/hexagon/work/matsbn/archive/' expid '/ocn/hist/' expid '.micom.hm.'];

% Get dimensions and time attributes
sdate=sprintf('%4.4d%c%2.2d',fyear,datesep,1);
nx=ncgetdim([prefix sdate '.nc'],'x');
ny=ncgetdim([prefix sdate '.nc'],'y');
depth=ncgetdim([prefix sdate '.nc'],'depth');
zdepth=ncgetvar([prefix sdate '.nc'],'depth');
zdepth_bnds=ncgetvar([prefix sdate '.nc'],'depth_bnds');
ny=ny-1;
time_long_name=ncgetatt([prefix sdate '.nc'],'long_name','time');
time_units=ncgetatt([prefix sdate '.nc'],'units','time');
time_calendar=ncgetatt([prefix sdate '.nc'],'calendar','time');

% Read grid information
vlon=ncgetvar(grid_file,'vlon');
vlat=ncgetvar(grid_file,'vlat');
parea=ncgetvar(grid_file,'parea');
vclon=ncgetvar(grid_file,'vclon');
vclat=ncgetvar(grid_file,'vclat');

%Fram Strait Location
fram=[94 360
 95 360
 96 360
 97 360
 98 360
 99 360
100 360
101 359
102 359
103 359
104 359
105 359];
dz=zdepth_bnds(2,:)-zdepth_bnds(1,:);

nx=1;
ny=1;

vlon=vlon(fram(:,1),fram(:,2));
vlat=vlat(fram(:,1),fram(:,2));
parea=parea(fram(:,1),fram(:,2));
vclon=permute(vclon(fram(:,1),fram(:,2),:),[3 1 2]);
vclat=permute(vclat(fram(:,1),fram(:,2),:),[3 1 2]);

% Create netcdf file.
%ncid=netcdf.create([expid '_temperature_annual_' num2str(fyear) '-' num2str(lyear) '.nc'],'NC_CLOBBER');
%ncid=netcdf.create(['/work/milicak/RUNS/noresm/CORE2/CORE2_files/SSH/' expid '_temperature_annual_' num2str(fyear) '-' num2str(lyear) '.nc'],'NC_CLOBBER');
ncid=netcdf.create(['/bcmhsm/milicak/RUNS/noresm/CORE2/Arctic/' expid '_heat_freshwater_Fram_monthly_' num2str(fyear) '-' num2str(lyear) '.nc'],'NC_CLOBBER');

% Define dimensions.
ni_dimid=netcdf.defDim(ncid,'ni',nx);
nj_dimid=netcdf.defDim(ncid,'nj',ny);
nz_dimid=netcdf.defDim(ncid,'depth',depth);
time_dimid=netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
nvertices_dimid=netcdf.defDim(ncid,'nvertices',4);
nzvertices_dimid=netcdf.defDim(ncid,'nzvertices',2);

% Define variables and assign attributes
time_varid=netcdf.defVar(ncid,'time','float',time_dimid);
netcdf.putAtt(ncid,time_varid,'long_name',time_long_name);
netcdf.putAtt(ncid,time_varid,'units',time_units);
netcdf.putAtt(ncid,time_varid,'calendar',time_calendar);

vlon_varid=netcdf.defVar(ncid,'VLON','float',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,vlon_varid,'long_name','V grid center longitude');
netcdf.putAtt(ncid,vlon_varid,'units','degrees_east');
netcdf.putAtt(ncid,vlon_varid,'bounds','lonv_bounds');

vlat_varid=netcdf.defVar(ncid,'VLAT','float',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,vlat_varid,'long_name','V grid center latitude');
netcdf.putAtt(ncid,vlat_varid,'units','degrees_north');
netcdf.putAtt(ncid,vlat_varid,'bounds','latv_bounds');

depth_varid=netcdf.defVar(ncid,'depth','float',[nz_dimid]);
netcdf.putAtt(ncid,depth_varid,'long_name','z level');
netcdf.putAtt(ncid,depth_varid,'units','m');
netcdf.putAtt(ncid,depth_varid,'bounds','depth_bounds');

tarea_varid=netcdf.defVar(ncid,'tarea','float',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,tarea_varid,'long_name','area of V grid cells');
netcdf.putAtt(ncid,tarea_varid,'units','m^2');
netcdf.putAtt(ncid,tarea_varid,'coordinates','VLON VLAT');

lonv_bounds_varid=netcdf.defVar(ncid,'lonv_bounds','float',[nvertices_dimid ni_dimid nj_dimid]);
netcdf.putAtt(ncid,lonv_bounds_varid,'long_name','longitude boundaries of V cells');
netcdf.putAtt(ncid,lonv_bounds_varid,'units','degrees_east');

latv_bounds_varid=netcdf.defVar(ncid,'latv_bounds','float',[nvertices_dimid ni_dimid nj_dimid]);
netcdf.putAtt(ncid,latv_bounds_varid,'long_name','latitude boundaries of V cells');
netcdf.putAtt(ncid,latv_bounds_varid,'units','degrees_north');

depth_bounds_varid=netcdf.defVar(ncid,'depth_bounds','float',[nzvertices_dimid nz_dimid]);
netcdf.putAtt(ncid,depth_bounds_varid,'long_name','vertical boundaries of V cells');
netcdf.putAtt(ncid,depth_bounds_varid,'units','m');

vhflxin_varid=netcdf.defVar(ncid,'vhflx_in','float',[ni_dimid nj_dimid nz_dimid time_dimid]);
netcdf.putAtt(ncid,vhflxin_varid,'long_name','Inflow Heat flux');
netcdf.putAtt(ncid,vhflxin_varid,'units','W');
netcdf.putAtt(ncid,vhflxin_varid,'_FillValue',single(fill_value));
netcdf.putAtt(ncid,vhflxin_varid,'coordinates','VLON VLAT');
netcdf.putAtt(ncid,vhflxin_varid,'cell_measures','area: varea');

vhflxout_varid=netcdf.defVar(ncid,'vhflx_out','float',[ni_dimid nj_dimid nz_dimid time_dimid]);
netcdf.putAtt(ncid,vhflxout_varid,'long_name','Outflow Heat flux');
netcdf.putAtt(ncid,vhflxout_varid,'units','W');
netcdf.putAtt(ncid,vhflxout_varid,'_FillValue',single(fill_value));
netcdf.putAtt(ncid,vhflxout_varid,'coordinates','VLON VLAT');
netcdf.putAtt(ncid,vhflxout_varid,'cell_measures','area: varea');


% Global attributes

% End definitions and leave define mode.
netcdf.endDef(ncid)


% Provide values for time invariant variables.
netcdf.putVar(ncid,vlon_varid,single(vlon));
netcdf.putVar(ncid,vlat_varid,single(vlat));
netcdf.putVar(ncid,tarea_varid,single(parea));
netcdf.putVar(ncid,lonv_bounds_varid,single(vclon));
netcdf.putVar(ncid,latv_bounds_varid,single(vclat));
netcdf.putVar(ncid,depth_bounds_varid,single(zdepth_bnds));
netcdf.putVar(ncid,depth_varid,single(zdepth));

% Retrieve mixed layer depths and write to netcdf variables
n=0;
for year=fyear:lyear
  for month=1:12
    n=n+1;
    sdate=sprintf('%4.4d%c%2.2d',year,datesep,month);
    disp(sdate)
    tmp=ncgetvar([prefix sdate '.nc'],'vhflxlvl');    
    tmp2=tmp(fram(:,1),fram(:,2),:);
    vhflxin=nansum(tmp2(tmp2>0.0));
    vhflxout=nansum(tmp2(tmp2<0.0));
    tmp=ncgetvar([prefix sdate '.nc'],'time');
    time=tmp;
    vhflxin(isnan(vhflxin))=fill_value;
    vhflxout(isnan(vhflxout))=fill_value;
    netcdf.putVar(ncid,time_varid,n-1,1,single(time));
    netcdf.putVar(ncid,vhflxin_varid,[0 0 0 n-1],[nx ny depth 1],single(vhflxin));
    netcdf.putVar(ncid,vhflxout_varid,[0 0 0 n-1],[nx ny depth 1],single(vhflxout));
  end
end


% Close netcdf file
netcdf.close(ncid)


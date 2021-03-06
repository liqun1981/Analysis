% roms_master_climatology_coawst_mw
%
% This routine :
%  - creates climatology, boundary, and initial condition files for ROMS: coawst_clm.nc ; coawst_bdy.nc ; coawst_ini.nc 
% on a user-defined grid for a user-defined date.
%
% This is currently set up to use opendap calls to acquire data
% from HYCOM + NCODA Global 1/12 Degree Analysis and interp to US_East grid.
%
% Before running this routine, user needs to setup "nctoolbox" within Matlab.
%  
% based on efforts by:
% written by Mingkui Li, May 2008
% Modified by Brandy Armstrong March 2009
% jcwarner April 20, 2009
% Ilgar Safak modified on June 27, 2012 such that now:
% - HYCOM url is a user-definition
% - "hc" is called from the stucture "gn".(still needs to be tested with wet/dry).
% - updatinit_coawst_mw.m modified to get desired time (T1) as a variable;
%    ocean_time=T1-datenum(1858,11,17,0,0,0)

%%%%%%%%%%%%%%%%%%%%%   START OF USER INPUT  %%%%%%%%%%%%%%%%%%%%%%%%%%
cd ~/matlab/nctoolbox/
setup_nctoolbox
addpath('/home/mil021/models/COAWST/Tools/mfiles/roms_clm')

clim_name='blacksea_clm.nc';
ini_name='blacksea_ini.nc';
bndry_name='blacksea_bndry.nc';


% (1) Enter start date (T1) to get climatology data 
T1=datenum(2011,1,1,0,0,0); %start date

% (2) Enter URL of the HYCOM catalog for the requested time, T1; see http://tds.hycom.org/thredds/catalog.html
url='http://tds.hycom.org/thredds/dodsC/GLBa0.08/expt_90.9';      % Jan 2011 - Present


% (3) Enter working directory (wdr)
wdr='/home/mil021/Analysis/roms/blacksea/Analysis';
eval(['cd ',wdr])

% (4) Enter path and name of the ROMS grid (modelgrid)
modelgrid='/home/mil021/Analysis/roms/blacksea/Analysis/BlackSea_grd.nc'
eval(['gridname=''',modelgrid,''';']);

% (5) Enter grid vertical coordinate parameters --These need to be consistent with the ROMS setup. 
theta_s=5;
theta_b=0.4;
Tcline=10;
N=30;

%%%%%%%%%%%%%%%%%%%%%   END OF USER INPUT  %%%%%%%%%%%%%%%%%%%%%%%%%%

disp('getting roms grid dimensions ...');
gn=roms_get_grid_mw(gridname,[theta_s theta_b Tcline N]);

tic

% Call to get HYCOM indices for the defined ROMS grid
disp('getting hycom indices')
get_ijrg(gn,url)

% Call to create the climatology (clm) file
disp('going to create clm file')
fn=updatclim_coawst_mw(T1,gn,clim_name,wdr,url)

% Call to create the boundary (bdy) file
disp('going to create bndry file')
updatbdry_coawst_mw(fn,gn,bndry_name,wdr)

% Call to create the initial (ini) file
disp('going to create init file')
updatinit_coawst_mw(fn,gn,ini_name,wdr,T1)
    
toc



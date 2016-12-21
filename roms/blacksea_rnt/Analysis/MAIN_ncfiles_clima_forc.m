% E. Di Lorenzo ---------------------------Creating forcing files.
% Mon Mar 14 15:04:53 EST 2005


% The logic is:
% 1) Create the empty recipient forcing files for your grid
%    You can create also a forcing file for each variable separately.
% 2) Set the times in the forcing file for each time variable
% 3) Extract forcing fields
% 4) Interpolate to grid and save in ncfiles

forc_timevars= ...
    {'shf_time' 'srf_time' 'swf_time'  'sms_time'  'sst_time' 'sss_time'};

forc_vars= ...
    {'shflux'   'swrad'    'swflux' 'sustr' 'svstr' 'SST'  'SSS' 'dQdSST'};

DO_CLIMATOLOGY=1;

%==========================================================
%	CLIMATOLOGY - example
%==========================================================
if DO_CLIMATOLOGY == 1
% STEP 1-2: define times and create forcing file
   forcfile=[nameit,'-forc.nc'];
   opt.sms_time=12;   opt.sms_time_cycle=360; opt.sms_timeVal=[15:30:360];
   opt.shf_time=12;   opt.shf_time_cycle=360; opt.shf_timeVal=[15:30:360];
   opt.swf_time=12;   opt.swf_time_cycle=360; opt.swf_timeVal=[15:30:360];
   opt.srf_time=12;   opt.srf_time_cycle=360; opt.srf_timeVal=[15:30:360];
   opt.sst_time=12;   opt.sst_time_cycle=360; opt.sst_timeVal=[15:30:360];
   opt.sss_time=12;   opt.sss_time_cycle=360; opt.sss_timeVal=[15:30:360];
   rnc_CreateForcFile(grd, forcfile, opt);
   
% STEP 3: Extract forcing from product of choice (NCEP in this case)
   ctlf=rnt_ctl(forcfile,'sms_time');
   vars=    {'shflux'   'swrad'    'swflux' 'sustr' 'svstr'};
   forcd = rnc_Extract_SurfFluxes_NCEP(grd.lonr,grd.latr, ctlf.datenum, 'clima',vars);
   % now get SST/SSS from Levitus
   forcd2 = rnc_Extract_LevitusTS_Clima(grd.lonr,grd.latr, ctlf.datenum,'surface');
   % get flux correction    (rnc_Extract_dQdSST_Clima.m)
   forcd3 = rnc_Extract_dQdSST_Clima(grd.lonr,grd.latr, ctlf.datenum);

   
   
   
% STEP 4:    Interpolate to grid and save in ncfiles
   rnc_Interp2grid_NCEP(ctlf,forcd,grd);
   rnc_Interp2grid_NCEP(ctlf,forcd2,grd);
   rnc_Interp2grid_NCEP(ctlf,forcd3,grd);
end



%Thermobaric Convection
%Roland W. Garwood, Jr., Shirley M. Isakari Naval Postgraduate School, Monterey,
%California, USA and
%Patrick C. Gallacher
%NRL, Stennis Space Center, Mississippi, USA

clear all

salt = ncread('n-ice2015_ship-ctd.nc','PSAL');
temp = ncread('n-ice2015_ship-ctd.nc','TEMP');
pr = ncread('n-ice2015_ship-ctd.nc','PRES');
lon = ncread('n-ice2015_ship-ctd.nc','LONGITUDE');
lat = ncread('n-ice2015_ship-ctd.nc','LATITUDE');
zr = sw_dpth(pr,mean(lat));

lon_s4=[17.6 16.5 16.05 15.6 15.1 14.1 13.0   12.0  10.0  8.0    4.0    4.0   10.0   20.0   30.0   40.0   50.0   60.0   70.0   80.0   90.0  100.0  110.0  120.0  130.0  140.0];
lat_s4=[69   70.6 71.3  72.02 72.8 73.8 75.0   76.0 77.0  78.0   79.0   80.0   81.0   81.8   81.8   82.6   83.0   83.2   83.1   82.8   82.5   81.8   79.7   78.2   78.2   79.7];

lon_region1 = [28.4183 50.1650 61.7595 59.7147 41.6135 24.3184 28.4183];
lat_region1 = [83.6591 84.0485 83.8828 82.8630 82.7320 82.2573 83.6591];

href = 1000;
indref = max(find(zr<=href));

%mask = squeeze(temp(:,:,1));
%mask(isnan(mask)==0)=0;
%for i=1:360; for j=1:180
%T1 = squeeze(temp(:,2));
%S1 = squeeze(salt(:,2));
%T1 = squeeze(temp(:,6));
%S1 = squeeze(salt(:,6));
%T1 = squeeze(temp(:,12));
%S1 = squeeze(salt(:,12));
T1 = squeeze(temp(:,9));
S1 = squeeze(salt(:,9));

S1(isnan(T1))=[];
zr(isnan(T1))=[];
pr(isnan(T1))=[];
T1(isnan(T1))=[];


dTdz(2:length(T1))=(T1(2:end)-T1(1:end-1))./(zr(2:end)-zr(1:end-1));
dSdz(2:length(T1))=(S1(2:end)-S1(1:end-1))./(zr(2:end)-zr(1:end-1));

if 1
%additional warming
% first working config
    ind1 = 300;
    ind2 = 1100;
    T1old = T1;
    S1old = S1;
    T1(ind1:ind2) = T1(ind1:ind2)+.5*exp(-(zr(ind1:ind2)-ind1)/ind2);
    S1(ind1:ind2) = S1(ind1:ind2)+.1*exp(-(zr(ind1:ind2)-ind1)/ind2);
    %S1(300:1100) = S1(300:1100)+.1*exp(-(zr(300:1100)-300)/300);
end

%T1(12:20) = T1(12:20)+1.0;
%T1(12:end) = T1(12:end)+1.0;
%S1(12:19) = S1(12:19)+0.2;
%S1(12) = S1(19);
%T1(12:19) = T1(12:19)+.6*exp((zr(12:19)-1000)/300);

rho = gsw_rho(S1,T1,pr);
Tref = T1(indref);
Sref = S1(indref);

%find max temp depth
indTmax = find(T1==max(T1(:)));
Tmax = max(T1(:));

Smax = S1(indTmax);
Tmxl = mean(T1(1:4));
hmax = zr(indTmax);
H2 = href-hmax;
DeltaT1 = Tmxl-Tref;
DeltaT2 = Tref-Tmax;
DeltaS2 = Sref-Smax;
beta = gsw_beta(S1(1),T1(1),0);
alpha0 = gsw_alpha(S1(1),T1(1),0);
alpha_tmp = gsw_alpha(S1,T1,pr);
zrtmp = zr;
zrtmp(isnan(alpha_tmp))=[];
alpha_tmp(isnan(alpha_tmp))=[];
P = polyfit(zrtmp,alpha_tmp,1);
%% IMPORTANT %%
%% alpha0 and alpha1 should be negative but beta should be positive
alpha1 = -P(1);
% another version of alpha0
alpha0_fit = P(2);
%alpha0 = -alpha0_fit;
alpha0 = -0.5*(alpha0+alpha0_fit);

% from control alpha values
if 1
    alpha0 = -3.6307e-05;
    alpha1 = -2.8655e-08;
end

Halpha = alpha0/alpha1;

%condition of thermobaricity
% alpha1*DeltaT1 > (alpha0*DeltaT2+beta*DeltaS2)/H2
DR1 = alpha1*DeltaT1; 
DR2 = ((alpha0*DeltaT2+beta*DeltaS2)/H2);
criteria = alpha1*DeltaT1 - ((alpha0*DeltaT2+beta*DeltaS2)/H2);
Sdeep = (beta*DeltaS2)/(alpha0*DeltaT2);
therm = gsw_thermobaric(S1,T1,pr);
DR2/DR1
%if criteria > 0
%    mask(i,j) = 1;
%end
%end;end




clear all
%close all
addpath('/fimm/home/bjerknes/milicak/matlab/tools/nansuite/');
format long
digits(64);

%root_name=['/hexagon/work/milicak/RUNS/mitgcm/dam_breaking/'];
root_name=['/export/grunchfs/unibjerknes/milicak/bckup/mitgcm/dam_breaking/'];
%root_name=['/net/m1i/models/MITgcm/Projects/overflow_slope/'];

project_name=['Exp01.1']
%project_name=['Exp01.2']
%project_name=['Exp01.3']
%project_name=['Exp01.4']

%foldername=['/net/m1i/models/MITgcm/Projects/dambreaking/run/'];
%foldername=['/net/m1i/models/MITgcm/Projects/overflow_slope/run/'];
foldername=[root_name project_name '/']

g=9.81;
skip=1;
dumpfreq=100; %1800; %from data in the run folder
deltat=1; %from data in the run folder
timeend=86400*5;

variable_name=['T']; %T for temp; S for salt

depth=rdmds([foldername 'Depth']);
xc=rdmds([foldername 'XC']);
rc=rdmds([foldername 'RC']);
drc=rdmds([foldername 'DRC']);
drf=rdmds([foldername 'DRF']);
dxc=rdmds([foldername 'DXC']);
dyc=rdmds([foldername 'DYC']);
H_depth=-depth(:,2);
x=squeeze(xc(:,1));

Z=cumsum(sq(drc));
hfacc=rdmds([foldername 'hFacC']);         % Level thicknesses
dz=(sq(drf));
[Nx Ny Nz]=size(hfacc);
delta_z=repmat(dz,[1 Nx Ny]);
delta_z=permute(delta_z,[2 3 1]);
delta_z=delta_z.*hfacc;
delta_z_ref=delta_z;
delta_x=repmat(dxc,[1 1 Nz]);
delta_y=repmat(dyc,[1 1 Nz]);

volume=delta_x.*delta_y.*delta_z;

%L=64e3;
Ldomain=nansum(delta_x(2:end-1,1,1));
Wdomain=4e3;
%H=sum(volume(:))./(L*W);
Hdomain=20;

real_ind=1;

irr_mix(Nx,Ny,Nz,1)=0;

%break

for time=0:skip*dumpfreq/deltat:timeend       %time indices
%timevec=[0 dumpfreq]
%timevec=[0 200 400 600]
%for time=timevec

itr=time;
temp=double(rdmds([foldername 'T'],itr));
temp(delta_z_ref==0)=NaN;
uvel=double(rdmds([foldername 'U'],itr));
%uvel(delta_z_ref==0)=NaN;
vvel=double(rdmds([foldername 'V'],itr));
%vvel(delta_z_ref==0)=NaN;
wvel=double(rdmds([foldername 'W'],itr));
%wvel(delta_z_ref==0)=NaN;
eta=rdmds([foldername 'Eta'],itr);

% closed boundary in x-direction
uvel(end+1,:,:)=0;
% periodic boundary in y-direction
vvel(:,end+1,:)=vvel(:,1,:);
% rigid-lid boundary in z-direction
wvel(:,:,end+1)=0;


% This is due to zstar used in MITGCM; look at table 7.1 in mom4p1 manual
for k=1:Nz
for j=1:Ny
for i=1:Nx
delta_z(i,j,k)=delta_z_ref(i,j,k)*(1.0+0.0*eta(i,j)/depth(i,j)); %rigid lid
end
end
end

if(time>0 & project_name(end)~='1')
  %diff=double(rdmds([foldername 'diffavg'],itr));
  diff=double(rdmds([foldername 'diff'],itr));
  diff(delta_z_ref==0)=NaN;
  diff(:,:,end+1)=diff(:,:,end); 
   %dnm1=(diff(:,:,2:end)-diff(:,:,1:end-1))./delta_z;
  dnm1=(diff(:,:,2:end)-diff(:,:,1:end-1));
  diff=0.2*dnm1./(delta_x.*delta_y);
  clear dnm1
end

rho=1000-0.2*temp+35.*0.8;

%%%% test %%%%
if 0
if time==0
  rhoini=rho;
  rhoini(2:end-1,:,:)=1022;
  rhoini(2:end-1,:,1:10)=1027;
  %rhoini(2,:,1:18)=1027;
  %rhoini(end-1,:,3:end)=1022;
  rho=rhoini;
  dx=delta_x(2,2,2);
elseif time==dumpfreq
  rho=rhoini;
  uvel(:,:,:)=0;
  vvel(:,:,:)=0;
  wvel(:,:,:)=0;

if 0
  rho(2:64,:,11)=1027;
  rho(65:end-1,:,10)=1022;
  %rho(2,:,19)=1027;
  %rho(end-1,:,2)=1022;
 % rho(65,:,Nz)=1027;
 % rho(64,:,1)=1022;
 % uvel(65,:,Nz)=0.279965;
 % uvel(66,:,Nz)=0.279965;
 % uvel(64,:,1)=-0.279965;
 % uvel(65,:,1)=-0.279965;
  dt=100;
  %wvel(2,:,19)=-dz(1)/dt;
  %wvel(end-1,:,2)=dz(1)/dt;
  wvel(2:64,:,12)=-dz(1)/dt;
  wvel(2:64,:,11)=-dz(1)/dt;
  wvel(65:end-1,:,10)=dz(1)/dt;
  wvel(65:end-1,:,11)=dz(1)/dt;
end
 
  dt=100;
  rho(36,:,17)=1027;
  rho(90,:,8)=1022;
  wvel(36,:,18)=-dz(1)/dt;
  wvel(90,:,8)=dz(1)/dt;
  
end
end



%%%% COMPUTE POTENTIAL ENERGY = g*rho*z_rho*dz  %%%%%%%%%%%%%%%%%%%%%%%
z_w(1:Nx,1:Ny,1:Nz+1)=0; 
z_w(:,:,Nz:-1:1)=-Hdomain+cumsum(delta_z(:,:,Nz:-1:1),3);
%z_w(:,:,2:Nz+1)=-H+cumsum(delta_z,3);
z_w(:,:,Nz+1)=-Hdomain;
z_rho=0.5*(z_w(:,:,2:end)+z_w(:,:,1:end-1));
dnm=g.*z_rho.*delta_z.*rho;
dnm_pe(:,:,:,real_ind)=dnm;
pe(real_ind)=nansum(dnm(:))/((Nx-2)*Ny);

kk=1;
for k=1:Nz
for j=1:Ny
for i=1:Nx
  %if(isnan(rho(i,j,k))~=1)
  rho_not_sort_dz(kk)=delta_z(i,j,k)*delta_x(i,j,k)*delta_y(i,j,k)/(Ldomain*Wdomain);
  rho_not_sort(kk)=rho(i,j,k);
  if(time>0 & project_name(end)~='1')
    diff_not_sort(kk)=diff(i,j,k);
    %diff_not_sort(kk)=diff(i,j,k)/(delta_x(i,j,k)*delta_y(i,j,k));
  end
  rho_not_sort_zrho(kk)=z_rho(i,j,k);
  kk=kk+1;
  %end
end
end
end


[rho_sort I]=sort(rho_not_sort,'descend');
rho_sort_dz=rho_not_sort_dz(I);
rho_sort_zrho=rho_not_sort_zrho(I);

clear dnm layer rho_sort_z_rho rho_sort_z_w
rho_sort_z_w(2:length(rho_sort_dz)+1)=-Hdomain+nancumsum(rho_sort_dz); 
rho_sort_z_w(1)=-Hdomain;
rho_sort_z_rho=0.5*(rho_sort_z_w(1:end-1)+rho_sort_z_w(2:end));

%%%% COMPUTE BACKGROUND POTENTIAL ENERGY = g*rho*z_rhostar*dzstar  %%%%%%%%%%%%%%%%%%%%%%%
dnm=g.*rho_sort.*rho_sort_dz.*rho_sort_z_rho;
rpe(real_ind)=nansum(dnm(:));
%rho_sort_time(real_ind,:)=rho_sort;
%rho_sort_z_rho_time(real_ind,:)=rho_sort_z_rho;
%rho_sort_dz_time(real_ind,:)=rho_sort_dz;

%%%% COMPUTE AVAILABLE POTENTIAL ENERGY DENSITY %%%%%%%%%%%%%%%%%%%%%%%
%tau1=(z-zstar)*rho
for k=1:length(rho_not_sort)
   aa=find(I==k);
   tau1(k)=((rho_not_sort_zrho(k))-(rho_sort_z_rho(aa))).*rho_not_sort(k);
   if(time>0 & project_name(end)~='1')
     irre_mix(k)=g*rho_sort_z_rho(aa).*diff_not_sort(k);
   end
   tau3(k)=(rho_sort_z_rho(aa)).*rho_not_sort(k);
end
if(time>0 & project_name(end)~='1')
  irr_mix(:,:,:,real_ind)=reshape(irre_mix,[Nx Ny Nz]);
end
for k=1:length(rho_not_sort)
   aa=find(I==k);
   if(isnan(rho_sort_z_rho(aa))==0 & isnan(rho_not_sort_zrho(k))==0)
     if(rho_sort_z_rho(aa)<=rho_not_sort_zrho(k))
       ind=find(rho_sort_z_rho<=rho_not_sort_zrho(k) & rho_sort_z_rho>=rho_sort_z_rho(aa));
       dnm=rho_sort(ind).*rho_sort_dz(ind);
       %tau2(k)=nansum(dnm).*(rho_not_sort_zrho(k)-rho_sort_z_rho(aa));
       tau2(k)=nansum(dnm);
     else   
       ind=find(rho_sort_z_rho>rho_not_sort_zrho(k) & rho_sort_z_rho<=rho_sort_z_rho(aa));
       dnm=rho_sort(ind).*rho_sort_dz(ind);
       tau2(k)=-nansum(dnm);
     end
   else
     tau2(k)=NaN;
   end
end

%APE=g*(nansum(tau1-tau2))/((Nx-2)*Ny) \sim pe-rpe
dnm_rpe(:,:,:,real_ind)=dnm_pe(:,:,:,real_ind)-g*(reshape(tau1,[Nx Ny Nz])-reshape(tau2,[Nx Ny Nz]));
dnm=squeeze(dnm_rpe(:,:,:,real_ind));
rpe_new(real_ind)=nansum(dnm(:))/((Nx-2)*Ny);
dnm_rpe2(:,:,:,real_ind)=g*(reshape(tau3,[Nx Ny Nz])+reshape(tau2,[Nx Ny Nz]));
dnm=squeeze(dnm_rpe2(:,:,:,real_ind));
rpe_new2(real_ind)=nansum(dnm(:))/((Nx-2)*Ny);

time_days(real_ind)=time*deltat/86400;
%TAU1(real_ind,:)=tau1;
%TAU2(real_ind,:)=tau2;
%TAU3(real_ind,:)=tau3;
dnm=tau1-tau2;
dnm=g.*reshape(dnm,[Nx Ny Nz]);
dnm_ape(:,:,:,real_ind)=dnm;
ape_new(real_ind)=nansum(dnm(:))/((Nx-2)*Ny);

ape(real_ind)=pe(real_ind)-rpe(real_ind);

%APE=g*(nansum(TAU1-TAU2,2))/((Nx-2)*Ny);
%RPE=g*(nansum(TAU3+TAU2,2))/((Nx-2)*Ny);


if time>0
  dnm_rpe=dnm_rpe2;
  tmp(2:Nx+1,2:Ny+1,2:Nz+1)=dnm_rpe(:,:,:,real_ind-1);
  tmp(1,2:Ny+1,2:Nz+1)=dnm_rpe(1,:,:,real_ind-1);
  tmp(2:Nx+1,1,2:Nz+1)=dnm_rpe(:,1,:,real_ind-1);
  tmp(2:Nx+1,2:Ny+1,1)=dnm_rpe(:,:,1,real_ind-1);
  tmp(Nx+2,2:Ny+1,2:Nz+1)=dnm_rpe(Nx,:,:,real_ind-1);
  tmp(2:Nx+1,Ny+2,2:Nz+1)=dnm_rpe(:,Ny,:,real_ind-1);
  tmp(2:Nx+1,2:Ny+1,Nz+2)=dnm_rpe(:,:,Nz,real_ind-1);

  tmp2(2:Nx+1,2:Ny+1,2:Nz+1)=dnm_rpe(:,:,:,real_ind);
  tmp2(1,2:Ny+1,2:Nz+1)=dnm_rpe(1,:,:,real_ind);
  tmp2(2:Nx+1,1,2:Nz+1)=dnm_rpe(:,1,:,real_ind);
  tmp2(2:Nx+1,2:Ny+1,1)=dnm_rpe(:,:,1,real_ind);
  tmp2(Nx+2,2:Ny+1,2:Nz+1)=dnm_rpe(Nx,:,:,real_ind);
  tmp2(2:Nx+1,Ny+2,2:Nz+1)=dnm_rpe(:,Ny,:,real_ind);
  tmp2(2:Nx+1,2:Ny+1,Nz+2)=dnm_rpe(:,:,Nz,real_ind);

  tmp3(2:Nx+1,2:Ny+1,2:Nz+1)=dnm_ape(:,:,:,real_ind-1);
  tmp3(1,2:Ny+1,2:Nz+1)=dnm_ape(1,:,:,real_ind-1);
  tmp3(2:Nx+1,1,2:Nz+1)=dnm_ape(:,1,:,real_ind-1);
  tmp3(2:Nx+1,2:Ny+1,1)=dnm_ape(:,:,1,real_ind-1);
  tmp3(Nx+2,2:Ny+1,2:Nz+1)=dnm_ape(Nx,:,:,real_ind-1);
  tmp3(2:Nx+1,Ny+2,2:Nz+1)=dnm_ape(:,Ny,:,real_ind-1);
  tmp3(2:Nx+1,2:Ny+1,Nz+2)=dnm_ape(:,:,Nz,real_ind-1);

  tmp4(2:Nx+1,2:Ny+1,2:Nz+1)=dnm_pe(:,:,:,real_ind-1);
  tmp4(1,2:Ny+1,2:Nz+1)=dnm_pe(1,:,:,real_ind-1);
  tmp4(2:Nx+1,1,2:Nz+1)=dnm_pe(:,1,:,real_ind-1);
  tmp4(2:Nx+1,2:Ny+1,1)=dnm_pe(:,:,1,real_ind-1);
  tmp4(Nx+2,2:Ny+1,2:Nz+1)=dnm_pe(Nx,:,:,real_ind-1);
  tmp4(2:Nx+1,Ny+2,2:Nz+1)=dnm_pe(:,Ny,:,real_ind-1);
  tmp4(2:Nx+1,2:Ny+1,Nz+2)=dnm_pe(:,:,Nz,real_ind-1);

  rhoini=rho;
  rhon(2:Nx+1,2:Ny+1,2:Nz+1)=rhoini(:,:,:);
  rhon(1,2:Ny+1,2:Nz+1)=rhoini(1,:,:);
  rhon(2:Nx+1,1,2:Nz+1)=rhoini(:,1,:);
  rhon(2:Nx+1,2:Ny+1,1)=rhoini(:,:,1);
  rhon(Nx+2,2:Ny+1,2:Nz+1)=rhoini(Nx,:,:);
  rhon(2:Nx+1,Ny+2,2:Nz+1)=rhoini(:,Ny,:);
  rhon(2:Nx+1,2:Ny+1,Nz+2)=rhoini(:,:,Nz);

%  flxBPEx=zeros(Nx,Ny,Nz);
%  flxBPEy=zeros(Nx,Ny,Nz);
%  flxBPEz=zieros(Nx,Ny,Nz);
  for i=1:Nx;for j=1:Ny;for k=1:Nz

%%   if u is nonconstant, so flux way \partial(u*tmp)/\partial x
    dnm1=0.5*(uvel(i+1,j,k)+abs(uvel(i+1,j,k)))*tmp(i+1,j+1,k+1)+0.5*(uvel(i+1,j,k)-abs(uvel(i+1,j,k)))*tmp(i+2,j+1,k+1);
    dnm2=0.5*(uvel(i,j,k)+abs(uvel(i,j,k)))*tmp(i,j+1,k+1)+0.5*(uvel(i,j,k)-abs(uvel(i,j,k)))*tmp(i+1,j+1,k+1);
    flxBPEx(i,j,k,real_ind)=(dnm1-dnm2)/delta_x(i,j,k);
    dnm1=0.5*(vvel(i,j+1,k)+abs(vvel(i,j+1,k)))*tmp(i+1,j+1,k+1)+0.5*(vvel(i,j+1,k)-abs(vvel(i,j+1,k)))*tmp(i+1,j+2,k+1);
    dnm2=0.5*(vvel(i,j,k)+abs(vvel(i,j,k)))*tmp(i+1,j,k+1)+0.5*(vvel(i,j,k)-abs(vvel(i,j,k)))*tmp(i+1,j+1,k+1);
    flxBPEy(i,j,k,real_ind)=(dnm1-dnm2)/delta_y(i,j,k);
  
    %rhow(i,j,k,real_ind)=0.5*(wvel(i,j,k)+wvel(i,j,k+1))*(rhon(i+1,j+1,k+1));
    if(abs(tmp2(i+1,j+1,k+1)-tmp(i+1,j+1,k+1))>1e-7)
      %%%%% rhow should contain dz I guess
      rhow(i,j,k,real_ind)=(0.5*(wvel(i,j,k)+abs(wvel(i,j,k)))*(rhon(i+1,j+1,k)) ...
                    +0.5*(wvel(i,j,k+1)-abs(wvel(i,j,k+1)))*(rhon(i+1,j+1,k+1)))*delta_z(i,j,k);
      if(wvel(i,j,k) > 0)
         rhow(i,j,k,real_ind)=0.995*rhow(i,j,k,real_ind);
      end

      wrhoz_zdz(i,j,k,real_ind)=wvel(i,j,k)*(rhon(i+1,j+1,k+1)-rhon(i+1,j+1,k))*z_w(i,j,k);

    % flux_z in flux form
      dnm1=0.5*(wvel(i,j,k+1)+abs(wvel(i,j,k+1)))*tmp(i+1,j+1,k+1)+0.5*(wvel(i,j,k+1)-abs(wvel(i,j,k+1)))*tmp(i+1,j+1,k+2);
      dnm2=0.5*(wvel(i,j,k)+abs(wvel(i,j,k)))*tmp(i+1,j+1,k)+0.5*(wvel(i,j,k)-abs(wvel(i,j,k)))*tmp(i+1,j+1,k+1);
      flxBPEz(i,j,k,real_ind)=(dnm1-dnm2)/delta_z(i,j,k);
    % flux_z in flux form
      dnm1=0.5*(wvel(i,j,k+1)+abs(wvel(i,j,k+1)))*tmp3(i+1,j+1,k+1)+0.5*(wvel(i,j,k+1)-abs(wvel(i,j,k+1)))*tmp3(i+1,j+1,k+2);
      dnm2=0.5*(wvel(i,j,k)+abs(wvel(i,j,k)))*tmp3(i+1,j+1,k)+0.5*(wvel(i,j,k)-abs(wvel(i,j,k)))*tmp3(i+1,j+1,k+1);
      flxAPEz(i,j,k,real_ind)=(dnm1-dnm2)/delta_z(i,j,k);
    % flux_z in flux form
      dnm1=0.5*(wvel(i,j,k+1)+abs(wvel(i,j,k+1)))*tmp4(i+1,j+1,k+1)+0.5*(wvel(i,j,k+1)-abs(wvel(i,j,k+1)))*tmp4(i+1,j+1,k+2);
      dnm2=0.5*(wvel(i,j,k)+abs(wvel(i,j,k)))*tmp4(i+1,j+1,k)+0.5*(wvel(i,j,k)-abs(wvel(i,j,k)))*tmp4(i+1,j+1,k+1);
      flxPEz(i,j,k,real_ind)=(dnm1-dnm2)/delta_z(i,j,k);

    else
      flxBPEz(i,j,k,real_ind)=0.0;
      flxAPEz(i,j,k,real_ind)=0.0;
      flxPEz(i,j,k,real_ind)=0.0;
      rhow(i,j,k,real_ind)=0.0;
      wrhoz_zdz(i,j,k,real_ind)=0.0;
    end
  end;end;end

end %time>0

real_ind
real_ind=real_ind+1;
rhoini=rho;

if 1
if time>0
  filename=[project_name '_ape_rpe_spatial_newflux.mat'];
  if(project_name=='Exp01.1')
    save(['/fimm/work/milicak/RUNS/Analysis/mitgcm/dam_breaking/Analysis/matfiles/' filename],'pe','rpe','ape','ape_new','dnm_ape','dnm_pe','dnm_rpe','flxBPEx','flxBPEy','flxBPEz','rhow','time_days','flxAPEz','flxPEz','wrhoz_zdz')
  else  
    save(['/fimm/work/milicak/RUNS/Analysis/mitgcm/dam_breaking/Analysis/matfiles/' filename],'pe','rpe','ape','ape_new','dnm_ape','dnm_pe','dnm_rpe','flxBPEx','flxBPEy','flxBPEz','rhow','irr_mix','time_days','flxAPEz','flxPEz')
  end
end
end

end %time slice




break

flxtotal=flxBPEx+flxBPEy-(flxBPEz+g.*rhow);
for i=2:1000
totalmixing3(:,:,:,i)=((dnm_rpe(:,:,:,i)-dnm_rpe(:,:,:,i-1))./100)+flxtotal(:,:,:,i);   
end
aa=squeeze(nansum(squeeze(totalmixing3(:,:,:,1:400)),4));

%change in BPE as a function of spatial distribution
dt=1800; %in seconds
k=12;marpcolor(((squeeze(dnm_rpe(:,2,:,k)-dnm_rpe(:,2,:,k-1)))/dt+squeeze(flxBPEx(:,2,:,k)))');shading flat;colorbar
pcolorjw(squeeze(dnm_rpe(:,2,:,2)-dnm_rpe(:,2,:,1))'/100-(squeeze(flxBPEx(:,2,:,2))'-(squeeze(flxBPEz(:,2,:,2))'+g*squeeze(rhow(:,2,:,2))')));shfn

dnm1=reshape(tau1,[Nx Ny Nz]);
dnm2=reshape(tau2,[Nx Ny Nz]);
dnm3=reshape(tau3,[Nx Ny Nz]);





close all
clear all; clear global;
more off
% Masking parameters                                                            
hFacMin = 0.1;                                                                  
hFacMinDz = 0.5;                                                                  
land = 0;        
ieee='b';                                                                       
accuracy='real*8';

tmp_out = ['woa13_Temp.data'] ;                                              
slt_out = ['woa13_Salt.data'] ; 

tmp_rbcs_out = ['temp_rbcs.bin'];
slt_rbcs_out = ['salt_rbcs.bin'];
msk_t_rbcs_out = ['mask_T_rbcs.bin'];
msk_s_rbcs_out = ['mask_S_rbcs.bin'];

batfile = 'Blacksea_2km_bathy.data' ;
ibcaofile = '/export/grunchfs/unibjerknes/milicak/bckup/world_grid/GEBCO_2014_1D.nc';
run set_blacksea_2km_grid 

fid = fopen(batfile,'r',ieee); 
h = fread(fid,[NX NY],accuracy);                                                
fclose(fid);                                                                    
[hFacC,dz3D] = hfac(delZ,h,hFacMin,hFacMinDz);                                  
mask  = (hFacC ~= 0) ;                                                          
mask2d  = mask (:,:,1);                                                         
clear hFacC    

%Twoafname = '/export/grunchfs/unibjerknes/milicak/bckup/OISST/woa13_decav_t00_04v2.nc';
%Swoafname = '/export/grunchfs/unibjerknes/milicak/bckup/OISST/woa13_decav_s00_04v2.nc';
Twoafname = '/okyanus/users/milicak/obs/woa13_decav_t13_04v2.nc';
Swoafname = '/okyanus/users/milicak/obs/woa13_decav_s13_04v2.nc';

tempwoa = ncread(Twoafname,'t_an');
lonwoa = ncread(Twoafname,'lon');
latwoa = ncread(Twoafname,'lat');
depthwoa = ncread(Twoafname,'depth');
saltwoa = ncread(Swoafname,'s_an');

% Map WOA13 fields to MITgcm grid.    
Mtmp = map_woa2MITgcm(tempwoa,LONC,LATC,lonwoa,latwoa,depths,depthwoa,8.89) ;
Mslt = map_woa2MITgcm(saltwoa,LONC,LATC,lonwoa,latwoa,depths,depthwoa,22.4) ;
% Remove land points.
%fprintf(1,'\n Removing land points...(uses hFactors...') ;
%for ii = 1:NX
%    for jj = 1:NY
%        inds2 = find(~squeeze(mask(ii,jj,:))) ;   % Remove land            points.
%        Mtmp(ii,jj,inds2) = land.*ones(size(inds2)) ;
%        Mslt(ii,jj,inds2) = land.*ones(size(inds2)); 
%    end % jj
%end % ii

% Write out fields.                                                             
fprintf(1,'\n Writing field to [%s].\n\n',tmp_out) ;                            
fid=fopen(tmp_out,'w',ieee);                                                    
fwrite(fid,Mtmp,accuracy);                                                      
fclose(fid);                                                                    
                                                                                
fprintf(1,'\n Writing field to [%s].\n\n',slt_out) ;                            
fid=fopen(slt_out,'w',ieee);                                                    
fwrite(fid,Mslt,accuracy);                                                      
fclose(fid);    

% set rbcs mask and values
run create_rbcs_tempsalt

for i =1:size(S,1) % for every month
    tmpS = interp1(dz,S(i,:),depths);
    tmpT = interp1(dz,T(i,:),depths);
    tmpS(isnan(tmpS)) = 39.0;
    tmpT(isnan(tmpT)) = 14.4;
    saltmar = repmat(tmpS,[size(LONC,1) 1 size(LONC,2)]);
    tempmar = repmat(tmpT,[size(LONC,1) 1 size(LONC,2)]);
    saltmarmara(:,:,:,i) = permute(saltmar,[1 3 2]);
    tempmarmara(:,:,:,i) = permute(tempmar,[1 3 2]);
end

% Write out fields.                                                             
fprintf(1,'\n Writing field to [%s].\n\n',tmp_rbcs_out) ;                            
fid=fopen(tmp_rbcs_out,'w',ieee);                                                    
fwrite(fid,tempmarmara,accuracy);                                                      
fclose(fid);                                                                    
                                                                                
fprintf(1,'\n Writing field to [%s].\n\n',slt_rbcs_out) ;                            
fid=fopen(slt_rbcs_out,'w',ieee);                                                    
fwrite(fid,saltmarmara,accuracy);                                                      
fclose(fid);    

% create rbcs_mask
maskrbcs = zeros(size(Mslt,1),size(Mslt,2),size(Mslt,3));
for i=1:size(Mslt,1); for j=1:size(Mslt,2)
    if(LATC(i,j) <= 40.7 & LONC(i,j) < 30.0) 
        maskrbcs(i,j,:) = 1.0;
    elseif(LATC(i,j) <= 40.9 & LATC(i,j) > 40.7 & LONC(i,j) < 30.0) 
        dnm = (40.9-LATC(i,j))/0.2;
        maskrbcs(i,j,:) = dnm;
    end
end;end
% Write out fields.                                                             
fprintf(1,'\n Writing field to [%s].\n\n',msk_t_rbcs_out) ;                            
fid=fopen(msk_t_rbcs_out,'w',ieee);                                                    
fwrite(fid,maskrbcs,accuracy);                                                      
fclose(fid);                                                                    

fprintf(1,'\n Writing field to [%s].\n\n',msk_s_rbcs_out) ;                            
fid=fopen(msk_s_rbcs_out,'w',ieee);                                                    
fwrite(fid,maskrbcs,accuracy);                                                      
fclose(fid);                                                                    

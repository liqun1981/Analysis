function section=map_scalar2section(data,map_file,method)
%MAP_SCALAR2SECTION maps data to a section.
%   SECTION=MAP_SCALAR2SECTION(DATA,MAP_FILE,METHOD) maps the numeric array
%   DATA to a section using interpolation weights provided in the file
%   MAP_FILE. The data array must by arrays of size [M,P] or [M1,M2,P] where M
%   or M1*M2 must match the number of grid cells used for generating the map
%   file. The argument METHOD indicate the interpolation method that can be one
%   of the following:
%     conserve - for first-order conservative interpolation (default).
%     bilinear - for bilinear interpolation.
%   Mapping is done for DATA(:,i) or DATA(:,:,i) for each i from 1 to P to
%   produce interpolated section data array of size [N,P] where N is the number
%   of section grid cells. Missing data must be set to NaN. SECTION is returned
%   as a structure containing the fields:
%     name:        section name.
%     data:        the interpolated data.
%     center_lon:  longitude of the center of section grid cells (unit
%                  degrees).
%     center_lat:  latitude of the center of section grid cells (unit degrees).
%     edge_lon:    longitude of the edges of section grid cells (unit degrees).
%     edge_lat:    latitude of the edges of section grid cells (unit degrees).
%     center_dist: distance from center of section grid cells to section start
%                  (unit radians).
%     edge_dist:   distance from edge of section grid cells to section start
%                  (unit radians; the first edge distance of 0 radians is
%                  omitted).
%
%   If more than one section is defined in the map file, SECTION will be
%   returned as a structure array with a length corresponding to the number of
%   sections.

% Mats Bentsen (mats.bentsen@uni.no) 2013/08/05

% Check number of input/output arguments.
error(nargchk(3,3,nargin))
error(nargchk(0,1,nargout))

% Check arguments
if ~isnumeric(data)
  error('The argument ''data'' must be an numeric array.')
end
if ~isstr(map_file)||~exist(map_file,'file')
  error('Argument ''map_file'' is not the name of an existing file.')
end
if ~strcmp(method,'conserve')&&~strcmp(method,'bilinear')
  error('Argument ''method'' must be either ''conserve'' or ''bilinear''.')
end

% Get information from map file
ncid=netcdf.open(map_file,'NC_NOWRITE');
[dimname_tmp,n_a]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'n_a'));
[dimname_tmp,n_b]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'n_b'));
[dimname_tmp,n_sec]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'n_sec'));
netcdf.close(ncid)
xc_b=ncread(map_file,'xc_b');
yc_b=ncread(map_file,'yc_b');
xe_b=ncread(map_file,'xe_b');
ye_b=ncread(map_file,'ye_b');
distc_b=ncread(map_file,'distc_b');
diste_b=ncread(map_file,'diste_b');
is_first=ncread(map_file,'is_first');
is_last=ncread(map_file,'is_last');
sec_name=char(ncread(map_file,'sec_name')');
S_conserve=sparse(double(ncread(map_file,'row_conserve')), ...
                  double(ncread(map_file,'col_conserve')), ...
                  ncread(map_file,'S_conserve'),n_b,n_a);
if strcmp(method,'bilinear')
  S_bilinear=sparse(double(ncread(map_file,'row_bilinear')), ...
                    double(ncread(map_file,'col_bilinear')), ...
                    ncread(map_file,'S_bilinear'),n_b,n_a);
end

% Make sure the data is a 2 dimensional matrix with the last dimension
% kept intact.
if length(data(:))==n_a
  data=data(:);
else
  data=reshape(data,[],size(data,ndims(data)));
  if size(data,1)~=n_a
    error('The dimension of the input data does not match the source dimension in the map file.')
  end
end

% Map data to section.
sec_data=[];
for k=1:size(data,2)
  data_a=data(:,k);
  mask_a=ones(size(data_a));
  mask_a(find(isnan(data_a)))=0;
  data_a(find(mask_a==0))=0;
  destarea_conserve=S_conserve*mask_a;
  data_conserve_b=S_conserve*data_a;
  data_conserve_b=data_conserve_b./destarea_conserve;
  if strcmp(method,'conserve')
    sec_data(:,k)=data_conserve_b;
  else
    destarea_bilinear=S_bilinear*mask_a;
    data_bilinear_b=S_bilinear*data_a;
    data_bilinear_b=data_bilinear_b./destarea_bilinear;
    data_bilinear_b(find(destarea_conserve==0))=nan;
    ind=find(isnan(data_bilinear_b)&~isnan(data_conserve_b));
    data_bilinear_b(ind)=data_conserve_b(ind);
    sec_data(:,k)=data_bilinear_b;
  end
end

% Fill section structure
for i_sec=1:n_sec
  is=is_first(i_sec):is_last(i_sec);
  section(i_sec).name=sec_name(i_sec,:);
  section(i_sec).data=sec_data(is,:);
  section(i_sec).center_lon=xc_b(is)';
  section(i_sec).center_lat=yc_b(is)';
  section(i_sec).edge_lon=xe_b(:,is);
  section(i_sec).edge_lat=ye_b(:,is);
  section(i_sec).center_dist=distc_b(is)';
  section(i_sec).edge_dist=diste_b(is)';
end

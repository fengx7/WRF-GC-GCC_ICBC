%% Information of filename
filename_input           = 'GEOSChem.SpeciesConc.20150601_0000z.nc4'; % input filename
filename_out             = 'wrfgc_icbc_data_test1.nc'; % output filename
simulation_4_5           = false; 
simulation_2_25          = true; 
filename_met_prefix      = 'GEOSChem.StateMet.';
filename_spc_prefix      = 'GEOSChem.SpeciesConc.';
filename_input_suffix    = 'z.nc4';
spc_suffix               = '_VMR_inst';
%% selected domain
lon_left                 = 1;                          % 2x2.5: 0:2.5:357.5 (144)  % 19£º45deg
lon_right                = 73;                                                     % 65£º160deg
lat_bottom               = 46;                         % 2x2.5: -89.5(-90):2:89.5(90) (91)
lat_upper                = 91;                                                     % 81: 70.5deg
%% time information (mozart data always start at 06:00 and end at 00:00)
startyr        = 2015;
endyr          = 2015;
startmon       = 6;
endmon         = 6;
startdate      = 1; 
enddate        = 21;
num_days       = datenum(endyr,endmon,enddate) - datenum(startyr,startmon,startdate) + 1;
datestd        = zeros(4 * num_days,6);
i = 0;
for mm = datenum(startyr,startmon,startdate):datenum(endyr,endmon,enddate)
    for hh = 0:6:18
        i = i + 1;
        datestd(i,:) = datevec(mm);
        datestd(i,4) = hh;
    end
end
formatOut1     = 'yyyymmdd_HHMM'; % For GEOS-Chem output filenames
formatOut2     = 'yyyymmdd';      % For create 'date' variable
date_str1      = datestr(datestd(2:end-3,:),formatOut1);
date_str2      = datestr(datestd(2:end-3,:),formatOut2);
date           = int32(str2num(date_str2));
datesec        = int32(datestd(2:end-3,4) * 3600);
time           = datenum(datestd(2:end-3,:))-1; % matlab datenum functon  
%% hybrid coordinates information (mozart data always start at 0 - 180 E - 360 W)
lat            = ncread(filename_input,'lat');
lev            = ncread(filename_input,'lev');
ilev           = ncread(filename_input,'ilev');
hyam           = ncread(filename_input,'hyam');
hybm           = ncread(filename_input,'hybm');

lat            = single(lat);
if simulation_2_25
   lon         = single(0:2.5:357.5)';
   else simulation_4_5
   lon         = single(0:5:355)';
end
% selected area
lat_s                    = lat(lat_bottom:lat_upper);
lon_s                    = lon(lon_left:lon_right);
  
lev            = single(flipud(lev*1000));
ilev           = single(flipud(ilev*1000));
hyam           = single(flipud(hyam/1000));
hybm           = single(flipud(hybm));

%% create the NetCDF schema definitions to NetCDF file
mozartSchema.Filename                   = filename_out;
mozartSchema.Name                       = '/';

mozartSchema.Dimensions(1).Name         = 'time';
mozartSchema.Dimensions(1).Length       = length(time); % the time dimension based on the geoschem output
mozartSchema.Dimensions(1).Unlimited    = true;
mozartSchema.Dimensions(2).Name         = 'lev';
mozartSchema.Dimensions(2).Length       = length(lev); % the lev dimension based on the geoschem output
mozartSchema.Dimensions(2).Unlimited    = false;
mozartSchema.Dimensions(3).Name         = 'lat';
mozartSchema.Dimensions(3).Length       = length(lat_s); % the lat dimension based on the geoschem output
mozartSchema.Dimensions(3).Unlimited    = false;
mozartSchema.Dimensions(4).Name         = 'lon';
mozartSchema.Dimensions(4).Length       = length(lon_s); % the lon dimension based on the geoschem output
mozartSchema.Dimensions(4).Unlimited    = false;
mozartSchema.Dimensions(5).Name         = 'nchar';
mozartSchema.Dimensions(5).Length       = 80;
mozartSchema.Dimensions(5).Unlimited    = false;
mozartSchema.Dimensions(6).Name         = 'ilev';
mozartSchema.Dimensions(6).Length       = length(ilev);
mozartSchema.Dimensions(6).Unlimited    = false;

mozartSchema.Attributes(1).Name         = 'Conventions';
mozartSchema.Attributes(1).Value        = 'NCAR-CSM';
mozartSchema.Attributes(2).Name         = 'case';
mozartSchema.Attributes(2).Value        = 'GEOS-Chem Classic-2deg-2.5deg';
mozartSchema.Attributes(3).Name         = 'title';
mozartSchema.Attributes(3).Value        = 'GEOS-Chem Classic-2deg-2.5deg';
mozartSchema.Attributes(4).Name         = 'history';
mozartSchema.Attributes(4).Value        = 'GEOS-Chem Classic 2015-06-10 00:00:00';
mozartSchema.Attributes(5).Name         = 'NCO';
mozartSchema.Attributes(5).Value        = 'netCDF Operators version 4.7.5';
mozartSchema.Attributes(6).Name         = 'nco_openmp_thread_number';
mozartSchema.Attributes(6).Value        = 1;

mozartSchema.Group                      = [];
mozartSchema.Format                     = 'classic';

ncwriteschema(filename_out,mozartSchema);
%% create the variables schema definitions to NetCDF file
% 'date'
dateschema.Name                          = 'date';
dateschema.Dimensions.Name               = 'time';
dateschema.Dimensions.Length             = length(time);
dateschema.Dimensions.Unlimited          = true;
dateschema.Datatype                      = 'int32';
dateschema.Format                        = 'classic';
dateschema.Attributes(1).Name            = 'long_name';
dateschema.Attributes(1).Value           = 'current date as 6 digit integer (YYMMDD)';
ncwriteschema(filename_out,dateschema);
ncwrite(filename_out,'date',date);
% 'datesec'
datesecschema.Name                       = 'datesec';
datesecschema.Dimensions.Name            = 'time';
datesecschema.Dimensions.Length          = length(time);
datesecschema.Dimensions.Unlimited       = true;
datesecschema.Datatype                   = 'int32';
datesecschema.Format                     = 'classic';
datesecschema.Attributes(1).Name         = 'long_name';
datesecschema.Attributes(1).Value        = 'seconds to complete current date';
datesecschema.Attributes(2).Name         = 'units';
datesecschema.Attributes(2).Value        = 's';
ncwriteschema(filename_out,datesecschema);
ncwrite(filename_out,'datesec',datesec);
% 'hyam'
hyamschema.Name                           = 'hyam';
hyamschema.Dimensions.Name                = 'lev';
hyamschema.Dimensions.Length              = length(hyam);
hyamschema.Dimensions.Unlimited           = false;
hyamschema.Datatype                       = 'single';
hyamschema.Format                         = 'classic';
hyamschema.Attributes(1).Name             = 'long_name';
hyamschema.Attributes(1).Value            = 'hybrid A coefficient at layer midpoints';
ncwriteschema(filename_out,hyamschema);
ncwrite(filename_out,'hyam',hyam);
% 'hybm'
hybmschema.Name                           = 'hybm';
hybmschema.Dimensions.Name                = 'lev';
hybmschema.Dimensions.Length              = length(hybm);
hybmschema.Dimensions.Unlimited           = false;
hybmschema.Datatype                       = 'single';
hybmschema.Format                         = 'classic';
hybmschema.Attributes(1).Name             = 'long_name';
hybmschema.Attributes(1).Value            = 'hybrid B coefficient at layer midpoints';
ncwriteschema(filename_out,hybmschema);
ncwrite(filename_out,'hybm',hybm);
% 'lat'
latschema.Name                            = 'lat';
latschema.Dimensions.Name                 = 'lat';
latschema.Dimensions.Length               = length(lat_s); % the lev dimension based on the geoschem output
latschema.Dimensions.Unlimited            = false;
latschema.Datatype                        = 'single';
latschema.Format                          = 'classic';
latschema.Attributes(1).Name              = 'long_name';
latschema.Attributes(1).Value             = 'latitude';
latschema.Attributes(2).Name              = 'units';
latschema.Attributes(2).Value             = 'degrees_north';
ncwriteschema(filename_out,latschema);
ncwrite(filename_out,'lat',lat_s);
% 'lev'
levschema.Name                            = 'lev';
levschema.Dimensions.Name                 = 'lev';
levschema.Dimensions.Length               = length(lev); % the lev dimension based on the geoschem output
levschema.Dimensions.Unlimited            = false;
levschema.Datatype                        = 'single';
levschema.Format                          = 'classic';
levschema.Attributes(1).Name              = 'long_name';
levschema.Attributes(1).Value             = 'hybrid level at layer midpoints (1000*(A+B))';
levschema.Attributes(2).Name              = 'units';
levschema.Attributes(2).Value             = 'hybrid_sigma_pressure';
levschema.Attributes(3).Name              = 'positve';
levschema.Attributes(3).Value             = 'down';
levschema.Attributes(4).Name              = 'A_var';
levschema.Attributes(4).Value             = 'hyam';
levschema.Attributes(5).Name              = 'B_var';
levschema.Attributes(5).Value             = 'hybm';
levschema.Attributes(6).Name              = 'P0_var';
levschema.Attributes(6).Value             = 'P0';
levschema.Attributes(7).Name              = 'PS_var';
levschema.Attributes(7).Value             = 'PS';
levschema.Attributes(8).Name              = 'bounds';
levschema.Attributes(8).Value             = 'ilev';
ncwriteschema(filename_out,levschema);
ncwrite(filename_out,'lev',lev);
% 'lon'
lonschema.Name                            = 'lon';
lonschema.Dimensions.Name                 = 'lon';
lonschema.Dimensions.Length               = length(lon_s); % the lev dimension based on the geoschem output
lonschema.Dimensions.Unlimited            = false;
lonschema.Datatype                        = 'single';
lonschema.Format                          = 'classic';
lonschema.Attributes(1).Name              = 'long_name';
lonschema.Attributes(1).Value             = 'longitude';
lonschema.Attributes(2).Name              = 'units';
lonschema.Attributes(2).Value             = 'degrees_east';
ncwriteschema(filename_out,lonschema);
ncwrite(filename_out,'lon',lon_s);
% 'time'
timeschema.Name                         = 'time';
timeschema.Dimensions.Name              = 'time';
timeschema.Dimensions.Length            = length(time);
timeschema.Dimensions.Unlimited         = true;
timeschema.Datatype                     = 'double';
timeschema.Attributes(1).Name           = 'long_name';
timeschema.Attributes(1).Value          = 'simulation time';
timeschema.Attributes(2).Name           = 'units';
timeschema.Attributes(2).Value          = 'days since 0000-01-01 00:00:00';
timeschema.Attributes(3).Name           = 'calendar';
timeschema.Attributes(3).Value          = 'gregorian';
ncwriteschema(filename_out,timeschema);
ncwrite(filename_out,'time',time);
%%
% 'PS'
psschema.Name                           = 'PS';
psschema.Dimensions(1).Name             = 'lon';
psschema.Dimensions(1).Length           = length(lon_s);
psschema.Dimensions(1).Unlimited        = false;
psschema.Dimensions(2).Name             = 'lat';
psschema.Dimensions(2).Length           = length(lat_s);
psschema.Dimensions(2).Unlimited        = false;
psschema.Dimensions(3).Name             = 'time';
psschema.Dimensions(3).Length           = length(time);
psschema.Dimensions(3).Unlimited        = true;
psschema.Datatype                       = 'single';
psschema.Attributes.Name                = 'units';
psschema.Attributes.Value               = 'PA';
% read 'PS' from GEOSChem output
PS = zeros(length(lon),length(lat),length(time));
tmp1 = zeros(length(lon),length(lat),length(time));
for tt = 1:length(time)
    file1 = [filename_met_prefix,date_str1(tt,:),filename_input_suffix];
    disp(file1)
    tmp1(:,:,tt) = ncread(file1,'Met_PS1DRY');
end
PS(1:length(lon)/2,:,:) = tmp1(length(lon)/2+1:end,:,:)*100;
PS(length(lon)/2+1:end,:,:) = tmp1(1:length(lon)/2,:,:)*100;
PS_s = PS(lon_left:lon_right,lat_bottom:lat_upper,:);
ncwriteschema(filename_out,psschema);
ncwrite(filename_out,'PS',PS_s);
%% create the species variables schema definitions to NetCDF file
gc_info                                    = ncinfo(filename_input);
varnum                                     = length(gc_info.Variables);
for ispec                                  = 1:varnum
    var_name                               = gc_info.Variables(ispec).Name;
    var_name_leng                          = length(var_name);
    if (var_name_leng > 12)
        disp(var_name);
        spc_name                           = var_name(13:end);
        spc_name_out                       = [spc_name,spc_suffix];
        varschema.Name                     = spc_name_out;
        varschema.Dimensions(1).Name       = 'lon';
        varschema.Dimensions(1).Length     = length(lon_s);
        varschema.Dimensions(1).Unlimited  = false;
        varschema.Dimensions(2).Name       = 'lat';
        varschema.Dimensions(2).Length     = length(lat_s);
        varschema.Dimensions(2).Unlimited  = false;
        varschema.Dimensions(3).Name       = 'lev';
        varschema.Dimensions(3).Length     = length(lev);
        varschema.Dimensions(3).Unlimited  = false;
        varschema.Dimensions(4).Name       = 'time';
        varschema.Dimensions(4).Length     = length(time);
        varschema.Dimensions(4).Unlimited  = true;
        varschema.Datatype                 = 'single';
        varschema.Attributes.Name          = 'units';
        varschema.Attributes.Value         = 'VMR';
        % read species concentrations from GEOSChem output
        tmp2                               = zeros(length(lon),length(lat),length(lev),length(time));
        tmp3                               = zeros(length(lon),length(lat),length(lev),length(time));
        spc_conc                           = zeros(length(lon),length(lat),length(lev),length(time));
        for tt = 1:length(time)
            filename = [filename_spc_prefix,date_str1(tt,:),filename_input_suffix];
            disp(filename)
            tmp2(:,:,:,tt) = ncread(filename,var_name);
        end
        for kk = 1:length(lev)
            tmp3(:,:,kk,:) = tmp2(:,:,length(lev)+1-kk,:);
        end
        spc_conc(1:length(lon)/2,:,:,:)    = tmp3(length(lon)/2+1:end,:,:,:);
        spc_conc(length(lon)/2+1:end,:,:,:)= tmp3(1:length(lon)/2,:,:,:);
		spc_conc_s                         = spc_conc(lon_left:lon_right,lat_bottom:lat_upper,:,:);
        
        ncwriteschema(filename_out,varschema);
        ncwrite(filename_out,spc_name_out,spc_conc_s);
    end
end
%%
aa = ncinfo(filename_out);
ncdisp(filename_out);

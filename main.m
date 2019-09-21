% *************************************************************
% GMCM2019D Code
%   Driving cycle
% 
% Date: 2019/09/19
% Copyright: 
% *************************************************************

clear

%%
%% read files and extract date
header = {'time','velocity','accelx','accely','accelz','longitude', ...
    'latitude','engine_revolution','torque_percentage','consumption', ...
    'pedal_opening','air_fuel_ratio','load','air_flow'};
filename = '';
while isempty(filename)
    [file, path] = uigetfile('*.xlsx');
    if file ~= 0
        filename = [path, file];
        break
    end
    disp('Please select a data file!')
end
rawdata = readtable(filename);
rawdata.Properties.VariableNames = header;
rawdata.time = datetime(rawdata.time, "InputFormat", "yyyy/MM/dd HH:mm:ss.SSS.");
%%
%% data cleaning and statistics
% split raw data into pieces
idx = extract_slice(rawdata.velocity);

% preprocess and statistics
min_revolution = 600;
for i = 1:length(idx)-1
    d.raw = rawdata(idx(i):idx(i+1)-1, :);
    d.raw_stats = statistics(d.raw);
    [d.processed, flag_stall] = preprocess(d.raw, min_revolution);
    d.stall = flag_stall;
    d.processed_stats = statistics(d.processed);
end
%%
%% construction of driving cycle
Trep = 1300;

%%
%% GPS signal lost (tunnel?)
latitude_lost = rawdata.latitude == 0;
longitude_lost = rawdata.longitude == 0;
% make sure they match
if ~all(latitude_lost == longitude_lost)
    disp("GPS signal lost data doesn't match!!!")
end

%%
%% Geo Map
webmap('Open Street Map')
s = geoshape(rawdata.latitude(~latitude_lost), rawdata.longitude(~longitude_lost));
wmline(s,'Color', 'b', 'Width', 1);
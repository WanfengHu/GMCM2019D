% preprocess cleans a micro trip based on some assumptions and rules.
%   
% Usage:
%   [processed, flag] = preprocess(raw, min_revolution, thresh)  
%
% Inputs:
%   raw: raw data for a micro trip.
%   min_revolution: a threshold for engine revolution below which it will
%   stall, used in function stall.
%   thresh: a time threshold to be used in function stall.
%   
% Outputs:  
%   processed: processed data.
%   flag: a flag indicates if the trip is processed by function stall.

function [processed, flag] = preprocess(raw, min_revolution, thresh)
    % Check stall
    [pro, flag] = stall(raw, min_revolution, thresh);
    
    % Only process trip with enough data
    if (nnz(pro.velocity>0) <=5 && max(pro.velocity) > 10) || ...
            length(pro.velocity) < 20
        processed = [];
        return
    end
    
    % Extract time and header
    header = pro.Properties.VariableNames;
    start_time = pro.time(1);
    end_time = pro.time(end);
    new_timeseries =  start_time:seconds(1):end_time;
    
    % Abnormal data in acceleration and deceleration
    acceleration = [0; diff(pro.velocity)./seconds(diff(pro.time))./3.6];
    max_acc = 100/7/3.6;
    max_dec = -8;
    location_abnormal = (acceleration > max_acc | acceleration < max_dec);
    pro(location_abnormal, :) = [];
    
    % GPS signal lost --> incontinuous in time
    processed = array2table(interp1(pro.time, pro{:, 2:end}, new_timeseries, 'linear', 'extrap'));
    processed = addvars(processed, new_timeseries', 'Before',1);
    processed.Properties.VariableNames = header;
    
    % Max idle time is 180s
    idx = find(processed.velocity>0, 1);
    if (processed.time(idx) - processed.time(1)) > seconds(180)
        processed(1:idx-180, :) = [];
    end
    
    % Validation
    rule1 = length(processed.velocity) >= length(raw.velocity) * 5 && ...
            (length(processed.velocity) - length(raw.velocity)) >= 15*60;
    rule2 = max(processed.velocity) > 140;
    if rule1 || rule2
        processed = [];
    end
end
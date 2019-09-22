function [processed, flag] = preprocess(raw, min_revolution, thresh)
    % Long period pause
    [pro, flag] = stall(raw, min_revolution, thresh);
    
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
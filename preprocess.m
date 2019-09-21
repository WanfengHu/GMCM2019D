function processed = preprocess(raw, min_revolution)

% Long period pause
pro = stall(raw, [], min_revolution);

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
processed = array2table(interp1(pro.time, pro{:, 2:end}, new_timeseries));
processed = addvars(processed, new_timeseries', 'Before',1);
processed.Properties.VariableNames = header;

% idle delete
st_idle=1;
for j=2:length(processed.velocity)
    if (processed.engine_revolution(j-1)<min_revolution)&&(min_revolution<=processed.engine_revolution(j))
        st_idle=j;
        break;
    end
end
[~,ind]=min(processed.engine_revolution(1:st_idle));
list_idle=st_idle:length(processed.velocity);
list_idle(processed.velocity(st_idle:end)==0)=[];
end_idle=list_idle(1);

if processed.time(st_idle)-processed.time(ind)>seconds(180)
    processed(ind:ind+180,:)=[];
end
if processed.time(end_idle)-processed.time(st_idle)>seconds(180)
    processed(end_idle-180:end_idle,:)=[];
end

ps_time=seconds(1:length(processed.time));
processed.time=ps_time';


% 4. congestion (max_velocity < 10 km/h) --> idle
% 5. max idle time == 180s

end
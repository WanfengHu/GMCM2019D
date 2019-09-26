% Extract is used as a class type for extracting different metrics from a
% group of micro trips and return a vector of extracted data.
%
% Usage:
% extract = ExtractStats
% extract.distance(group)
% extract.max_vel(group)
% extract.total_drive_time(group)
% extract.total_time(group)
% extract.velocity(group)
% extract.acceleration(group)
% extract.acc_time(group);
% extract.dec_time(group);
%
% It is recommended that extract be a global variable.

function Extract = ExtractStats
    Extract.max_vel = @extract_max_vel;
    Extract.distance = @extract_distance;
    Extract.total_drive_time = @extract_total_drive_time;
    Extract.total_time = @extract_total_time;
    Extract.velocity = @extract_velocity;
    Extract.acceleration = @extract_acceleration;
    Extract.acc_time = @extract_acc_time;
    Extract.dec_time = @extract_dec_time;
end

% Distance
function distance = extract_distance(group)
    distance = extract_stats_form_group(group, 'Distance');
end

% Max velocity
function max_vel = extract_max_vel(group)
    max_vel = extract_stats_form_group(group, 'MaxVel');
end

% Total driving time (without idle)
function total_drive_time = extract_total_drive_time(group)
    total_drive_time = extract_stats_form_group(group, 'TotalNonIdleTime');
end

% Total time (with idle)
function total_time = extract_total_time(group)
    total_time = extract_stats_form_group(group, 'TotalTime');
end

% Acceleration time
function total_time = extract_acc_time(group)
    total_time = extract_stats_form_group(group, 'AccelTime');
end

% Deceleration time
function total_time = extract_dec_time(group)
    total_time = extract_stats_form_group(group, 'DecelTime');
end

% Velocity
function vel = extract_velocity(group)
    vel = extract_stats_form_group(group, 'Velocity');
end

% Acceleration
function vel = extract_acceleration(group)
    vel = extract_stats_form_group(group, 'Acceleration');
end

% Distribution of function
function result = extract_stats_form_group(group, stats)
    n = length(group);
    result = zeros(n, 1);
    switch stats
        case "MaxVel"
            for i = 1:n
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.max_vel;
                end
            end
        case "Distance"
            for i = 1:n
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.distance;
                end
            end
        case "TotalTime"
            for i = 1:n
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.total_time;
                end
            end
        case "TotalNonIdleTime"
            for i = 1:n
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.total_time * ...
                        (1-group(i).processed_stats.idle_percent);
                end
            end
        case "AccelTime"
            for i = 1:n
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.total_time * ...
                        group(i).processed_stats.acc_percent;
                end
            end
        case "DecelTime"
            for i = 1:n
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.total_time * ...
                        group(i).processed_stats.dec_percent;
                end
            end
        case "Velocity"
            result = [];
            for i=1:n
                if ~isempty(group(i).processed)
                    result = cat(2, result, group(i).processed.velocity');
                end
            end
        case "Acceleration"
            result = [];
            for i=1:n
                if ~isempty(group(i).processed)
                    vel = group(i).processed.velocity';
                    accel = diff(vel)/3.6;
                    result = cat(2, result, accel);
                end
            end
        otherwise
            disp("Please choose a valid statistics")
    end
end
% Extract is used as a class type for extracting different metrics from a
% group of micro trips and return a vector of extracted data.
%
% Usage:
% extract = ExtractStats
% extract.distance(group)
% extract.max_vel(group)
% extract.total_drive_time(group)
% extract.total_time(group)
%
% It is recommended that extract be a global variable.

function Extract = ExtractStats
    Extract.max_vel = @extract_max_vel;
    Extract.distance = @extract_distance;
    Extract.total_drive_time = @extract_total_drive_time;
    Extract.total_time = @extract_total_time; 
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

% Distribution of function
function result = extract_stats_form_group(group, stats)
    result = zeros(length(group), 1);
    switch stats
        case "MaxVel"
            for i = 1:length(group)
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.max_vel;
                end
            end
        case "Distance"
            for i = 1:length(group)
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.distance;
                end
            end
        case "TotalTime"
            for i = 1:length(group)
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.total_time;
                end
            end
        case "TotalNonIdleTime"
            for i = 1:length(group)
                if ~isempty(group(i).processed_stats)
                    result(i) = group(i).processed_stats.total_time*(1-group(i).processed_stats.idle_percent);
                end
            end
        otherwise
            disp("Please choose a valid statistics")
    end
end
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
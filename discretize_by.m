function res = discretize_by(igroup, interval, stats)
    switch stats
        case "Velocity"
            res = discretize(igroup.processed_stats.max_vel, interval);
        case "Distance"
            res = discretize(igroup.processed_stats.distance, interval);
        otherwise
            error("discretize by 'Velocity' or 'Distance'")
    end
end
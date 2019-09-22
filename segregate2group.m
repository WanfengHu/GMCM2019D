function id = segregate2group(stats, interval)
    id = 0;
    if ~isempty(stats)
        id = find(stats.max_vel < interval, 1) - 1; 
    end
end
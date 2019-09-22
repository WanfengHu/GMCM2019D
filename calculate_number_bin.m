function [Nbin_group_rep, bin_edges] = calculate_number_bin(group, Ngroup_rep, bincounts, metric)
    switch metric
        case 'Velocity'
            target = extract_max_vel(group);
        case 'Distance'
            target = extract_distance(group);
        otherwise
            error("Metric must be 'Velocity' or 'Distance'")
    end
    figure()
    h = histogram(target, bincounts, 'Normalization', 'probability');
    Nbin_group_rep = round(h.Values * Ngroup_rep);
    num_got = sum(Nbin_group_rep);
    stillneed = Ngroup_rep - num_got;
    if stillneed > 0
        [~, id] = max(h.Values);
        Nbin_group_rep(id) = Nbin_group_rep(id) + stillneed;
    end
    while(stillneed < 0)
        [~, id] = min(h.Values(Nbin_group_rep>0));
        Nbin_group_rep(id) = Nbin_group_rep(id) - 1;
        stillneed = stillneed + 1;
    end
    bin_edges = h.BinEdges;
end
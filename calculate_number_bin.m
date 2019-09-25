% calculate_number_bin calculates the desired number of trips in the bins 
% of a histogram and the bin edges.
%
% Usage:
% [Nbin_group_rep, bin_edges] = calculate_number_bin(group, Ngroup_rep, bincounts, metric)
%
% Inputs:
%   group: a set of trips belonging to the same group diveded by max
%   velocity from a full length cycle. 
%   Ngroup_rep: number of trips needed from a group.
%   bincounts: number of bins for the histogram.
%   metric: 'Velocity' or 'Distance'. Metric to be used for the histogram.
%   
% Outputs:
%   Nbin_group_rep: desired number of trips in each bin for the
%   representative cycle.
%   bin_edges: bin edges of the created histogram.

function [Nbin_group_rep, bin_edges] = calculate_number_bin(group, Ngroup_rep, bincounts, metric)
    global extract
    switch metric
        case 'Velocity'
            target = extract.max_vel(group);
        case 'Distance'
            target = extract.distance(group);
        otherwise
            error("Metric must be 'Velocity' or 'Distance'")
    end
%     figure()
    figure Visible off
    h = histogram(target, bincounts, 'Normalization', 'probability');
    
    Nbin_group_rep = round(h.Values * Ngroup_rep);
    num_got = sum(Nbin_group_rep);
    stillneed = Ngroup_rep - num_got;
    
    % Validation of the calculated number, error maybe induced due to the
    % round function
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
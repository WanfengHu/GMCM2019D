% discretize_by groups data into bins by the metric specified.
% It is a wrapper function for built-in funtion discretize.
%
% Usage:
% res = discretize_by(igroup, interval, metric)
%
% Inputs:
%   igroup: a micro trip.
%   interval: bin edges.
%   metric: 'Velocity' or 'Distance'.
%   
% Outputs:
%   res: indices of the bins that the trip belongs to. 

function res = discretize_by(igroup, interval, metric)
    switch metric
        case "Velocity"
            res = discretize(igroup.processed_stats.max_vel, interval);
        case "Distance"
            res = discretize(igroup.processed_stats.distance, interval);
        otherwise
            error("discretize by 'Velocity' or 'Distance'")
    end
end
% segregate2group mark micro trips with a group id based on its max
% velocity.
%   
% Usage:
%   id = segregate2group(stats, interval)  
%
% Inputs:
%   stats: statistics for a micro trip.
%   interval: bin edges of max velocities.

function id = segregate2group(stats, interval)
    id = 0;
    if ~isempty(stats)
        id = find(stats.max_vel < interval, 1) - 1; 
    end
end
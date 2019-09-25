% stall checks if there is a unusual piece in a micro trip (such as engine stall)
% and process the piece if necessary. It also marks if the micro trip is
% processed in this function.
% 
% Usage:
%   [pro, flag] = stall(raw, min_revolution, thresh) 
%
% Inputs:
%   raw: raw data for a micro trip.
%   min_revolution: a threshold for engine revolution below which it will
%   stall.
%   thresh: a time threshold to be used for finding gaps in time.
%
% Outputs:  
%   pro: processed data.
%   flag: a flag indicates if the trip is processed by this function.

function [pro, flag] = stall(raw, min_revolution, thresh)
    flag = 0;
    pro = raw;
    time_diff = diff(raw.time);
    row = find(time_diff > thresh)+1;
    if ~isempty(row)
        for i = 1:length(row)
            before_cond = (raw.velocity(row(i)-1) < 3 && raw.engine_revolution(row(i)-1) <= min_revolution) || ...
                            (raw.velocity(row(i)-1) < 0.5) ;
            if before_cond
                move = raw.time(row(i))-raw.time(row(i)-1) - seconds(10);
                pro.time(1:row(i)-1) = raw.time(1:row(i)-1) + move;
                flag = 1;
                break
            end
        end
    end
end
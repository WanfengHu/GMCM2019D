% total_more makes the total idel time equal to the desired value in the
% case of exceeding it.
%
% Usage:
% Final_num_idle = total_more(desr_rep_idletime, rep_num_idle)
%
% Inputs:
%   desr_rep_ideltime: required idle time in seconds.
%   rep_num_idel: a n-by-2 matrix. Mean values of time range are its first.
%   column and the second column is the corresponding occurrences.
%
% Outputs:
%   final_num_idle: a n-by-2 matrix. Adjusted idle times and their occurrences.

function final_num_idle = total_more(desr_rep_idletime, rep_num_idle)
    interval = rep_num_idle(2, 1) - rep_num_idle(1, 1);
    n = size(rep_num_idle, 1);
    final_num_idle = rep_num_idle;
    adjusted = 0;
    for i = 1:n
        adjusted_time = ((1:i)-0.99)*interval*rep_num_idle(1:i,2) + ...
            final_num_idle(i+1:end,1)'*final_num_idle(i+1:end,2);
        if adjusted_time <= desr_rep_idletime
            adjusted = 1;
            break
        end
        final_num_idle(i,1) = (i-0.99)*interval;
    end
    final_gap=final_num_idle(:,1)'*final_num_idle(:,2) - desr_rep_idletime;
    if adjusted
        % Removing additional time is enough
        disp('Requirement met')
        final_num_idle(i,1) = final_num_idle(i,1) - final_gap/final_num_idle(i,2);
    else
        % Still exceeds
        disp('Still exceeds')
        idx=ceil(final_gap/interval);
        final_num_idle(idx,2)=final_num_idle(idx,2)-1;
        final_num_idle(1,1)=final_num_idle(1,1)-(final_gap-final_num_idle(idx,1))/final_num_idle(1,2);
    end
end
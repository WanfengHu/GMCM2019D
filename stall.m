function [pro, flag] = stall(raw, min_revolution, thresh)
    flag = 0;
    pro = raw;
    time_diff = diff(raw.time);
    row = find(time_diff > thresh)+1;
    if ~isempty(row)
        for i = 1:length(row)
            before_cond = (raw.velocity(row(i)-1) == 0 && raw.engine_revolution(row(i)-1) <= min_revolution);
            after_cond = (raw.velocity(row(i)) > 0 || ...
                (raw.velocity(row(i)) == 0 && raw.engine_revolution(row(i)) > min_revolution));
            if before_cond && after_cond
                move = raw.time(row(i))-raw.time(row(i)-1) - seconds(10);
                pro.time(1:row(i)-1) = raw.time(1:row(i)-1) + move;
                flag = 1;
                break
            end
        end
    end
end
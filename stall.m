function pro = stall(raw, slicei, max_revolution)
    global count
    global sta
    global ratio
    c = 0;
    pro = raw;
    time_cutoff = seconds(180);
    time_diff = diff(raw.time);
    row = find(time_diff > time_cutoff)+1;
    if ~isempty(row)
        sta = sta + 1;
        for i = 1:length(row)
            before_cond = (raw.velocity(row(i)-1) == 0 && raw.engine_revolution(row(i)-1) <= max_revolution);
            after_cond = (raw.velocity(row(i)) > 0 || ...
                (raw.velocity(row(i)) == 0 && raw.engine_revolution(row(i)) > max_revolution));
            if before_cond && after_cond
                fprintf("Slice N.%d, time: %d\n", slicei, seconds(raw.time(row(i))-raw.time(row(i)-1)))
                move = raw.time(row(i))-raw.time(row(i)-1) - seconds(10);
                pro.time(1:row(i)-1) = raw.time(1:row(i)-1) + move;
                count = count + 1;
                fprintf("Slice N.%d, time: %d\n", slicei, seconds(pro.time(row(i))-pro.time(row(i)-1)))
                c = c+1;
%                 break
            end
        end
        if c > 1
            ratio = ratio + 1;
        end
    end
end
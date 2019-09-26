% *************************************************************
% PostProcess plots graphs and calculates error for the obtained results.
% It does the following things:
%   1. Plot the representative driving cycle
%   2. Plot the histogram of peek speeds for both full and representative
%   cycle and calculate the error
%   3. Plot the histogram of covered distance for both full and representative
%   cycle and calculate the error
%   4. Calculate metrics for the evaluation of the constructed cycle and
%   compare to the full cycle with bar graph 
% 
% Coded with MATLAB 2018a 
% *************************************************************

plot_rep(rep_cycle, Trep)
weighted_err_vel = plot_by(d, selected_group, interval, 'MaxVel');
weighted_err_dis = plot_by(d, selected_group, [0:5:10 20 40 70], 'Distance');
metrics_full = metrics(d);
metrics_rep = metrics(selected_group, Trep);
plot_metrics(metrics_full, metrics_rep)

% plot_rep plots the representative driving cycle.
function plot_rep(rep_cycle, Trep)
    figure('name','Representative Driving Cycle')
    plot(rep_cycle.time, rep_cycle.velo, 'b-');
    str_title = ['Total ', num2str(Trep), 's'];
    title(str_title)
    xlabel('Time (s)', 'FontName', 'Times New Roman')
    ylabel('Vehicle Speed (km/h)', 'FontName', 'Times New Roman');
end

% weighted_error plots the histogram of peak speeds or distance covered for
% full length cycle and for representative cycle. It also calculates the
% weighted error between the two cycles.
function weighted_error = plot_by(d, selected_group, interval, stats)
    global extract
    switch stats
        case "MaxVel"
            rep = extract.max_vel(selected_group);
            full = extract.max_vel(d);
            xlab = "Peak Speed (km/h)";
            t = "Normalized Histogram of Peak speed";
        case "Distance"
            rep = extract.distance(selected_group);
            full = extract.distance(d);
            xlab = "Distance Covered (km)";
            t = "Normalized Histogram of Distance Covered";
        otherwise
            warn("stats doesn't match any case")
    end
    full(full==0) = [];
    figure()
    h1 = histogram(full, interval, 'Normalization', 'probability');
    hold on
    h2 = histogram(rep, interval, 'Normalization', 'probability');
    hold off
    weight = h1.Values;
    error = abs(h1.Values-h2.Values);
    weighted_error = sum(weight.*error);
    grid on
    xlabel(xlab)
    ylabel('Percentage')
    title(t)
    legend({'Full Length Cycle', 'Representative Cycle'})
end

% metrics calculates metrics for evaluation of the constructed driving
% cycle.
% Metrics are:
%   Mean speed (km/h)
%   Mean driving speed (km/h)
%   Mean acceleration (m/s^2)
%   Mean deceleration (m/s^2)
%   Idel percentage (%)
%   Acceleration percentage (%)
%   Deceleration percentage (%)
%   Standard deviation of speed (km/h) (including idle)
%   Standard deviation of acceleration (m/s^2)
function metric = metrics(d, varargin)
    global extract
    Tdrive = sum(extract.total_drive_time(d));
    Tfull = sum(extract.total_time(d));
    vel = extract.velocity(d);
    acc = extract.acceleration(d);
    Tacc = sum(extract.acc_time(d));
    Tdec = sum(extract.dec_time(d));
    if nargin == 2
        Trep = varargin{1};
        vel = [vel zeros(1, Trep-Tfull)];
        Tfull = Trep;
    end
    
    metric.avg_v = mean(vel);
    metric.avg_v_drive = mean(vel(vel~=0));
    metric.avg_acc = mean(acc(acc>0.1));
    metric.avg_dec = mean(acc(acc<-0.1));
    metric.ratio_idle = 1 - Tdrive/Tfull;
    metric.ratio_acc = Tacc/Tfull;
    metric.ratio_dec = Tdec/Tfull;
    metric.std_V = std(vel);
    metric.std_a = std(acc(acc>0.1));
end

% plot_metrics creates a 3-by-3 bar graph for comparing metrics between
% full length cycle and representative cycle.
function plot_metrics(metrics_d, metrics_rep)
    type = categorical({'原始数据', '行驶工况'});
    titles={'平均速度', '平均行驶速度', '平均加速度', ...
        '平均减速度(绝对值)', '怠速时间比', '加速时间比', ...
        '减速时间比', '速度标准差', '加速度标准差'};
    ylabs={'v (m/s)', 'v (m/s)', 'a (m/s^2)', ...
        'a (m/s^2)', '%', '%', ...
        '%', 'v (m/s)', 'a (m/s^2)'};
    K = [1 1 1 -1 100 100 100 1 1];
    table_d = struct2table(metrics_d);
    table_rep = struct2table(metrics_rep);
    
    figure
    set(gcf,'units','centimeter','position',[1 1 20 16]);
    for i = 1:length(titles)
        subplot(3, 3, i)
        bar(type(1), K(i)*table_d{1,i});
        hold on;
        bar(type(2), K(i)*table_rep{1,i});
        hold off
        title(titles(i))
        ylabel(ylabs(i));
        max_y = max(K(i)*table_d{1,i}, K(i)*table_rep{1,i});
        ylim([0 1.2*max_y]);
    end
end
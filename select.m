% select selects a number of micro trips from a group to include in the
% construction of a representative cycle.
%
% Usage:
% selected_trips = select(group, Tfull, Trep, bincounts)
%
% Inputs:
%   group: a set of trips belonging to the same group.
%   Tfull: time duration of full length cycle.
%   Trep: time duration of representative cycle.
%   bincounts: number of bins for the histogram.
%   
% Outputs:
%   selected_trips: trips that give good match for peek speeds and distance
%   covered.

function selected_trips = select(group, Tfull, Trep, bincounts)
    global extract
    len_group = length(group);
    
    % Calculate number and time
    [Tgroup_rep, Ngroup_rep] = number_time(Tfull, Trep, group);
    
    % Calculate desired number for each bin of max_speed
    [Nbin_vel_group_rep, vel_bin] = calculate_number_bin(group, Ngroup_rep, bincounts, 'Velocity');
    
    % Calculate desired number for each bin of distance
    [Nbin_dis_group_rep, dis_bin] = calculate_number_bin(group, Ngroup_rep, bincounts, 'Distance');
    
    % Discretize the subgroup by velocity and distance
    group_vel = zeros(len_group, 1);
    group_dis = zeros(len_group, 1);
    for i = 1:len_group
        group_vel(i) = discretize_by(group(i), vel_bin, 'Velocity');
        group_dis(i) = discretize_by(group(i), dis_bin, 'Distance');
    end
    
    % Select the first slices that normalized peek speeds histogram agrees and
    % covered distance also within certain range.
    selected = [];
    for i = 1:bincounts
        combination = combnk(find(group_vel==i), Nbin_vel_group_rep(i));
        mean_all = mean(extract.max_vel(group(group_vel==i)));
        avg_dist = mean(extract.distance(group(group_vel==i)));
        num_comb = size(combination, 1);
%         difference = zeros(num_comb, 1);
        for j = 1:num_comb
            mean_piece = mean(extract.max_vel(group(combination(j,:))));
            avg_piece_dist = mean(extract.distance(group(combination(j,:))));
            if abs(mean_piece - mean_all)/mean_all < 0.01 && ...
                    abs(avg_piece_dist - avg_dist)/avg_dist < 0.1
                break
            end
%             difference(j) = abs(mean_piece - mean_all);
%             if sum(extract.total_drive_time(group(combination(j,:)))) > Tgroup_rep 
%                 difference(j) = NaN;
%             end
        end
        idx = j;
%         [~, idx] = min(difference);
        selected = cat(2, selected, combination(idx, :));
    end
    
    % Find the number of trips selected in a distance bin
    Nbin_dis_actual = zeros(1, bincounts);
    for i = 1:Ngroup_rep
        dis_id = group_dis(selected(i));
        Nbin_dis_actual(dis_id) = Nbin_dis_actual(dis_id) + 1;
    end
    
    % Search for bins having less than desired number of trips
    Nbin_dis_diff = Nbin_dis_group_rep - Nbin_dis_actual;
    for i = 1:bincounts
        mean_dist_piece = mean(extract.distance(group(selected)));
        % Having less than desired
        if Nbin_dis_diff(i) > 0
            disp('Having less than desired in a distance bin')
            % Try correction by matching for distance 
            [selected, non_replacement_flag, Nbin_dis_actual] = add_delete(group, group_vel, group_dis, i, Nbin_dis_group_rep, Nbin_dis_actual, mean_dist_piece, selected);
            if non_replacement_flag
                disp("No replacement")
                break
            end
        end
    end

    selected_trips = group(selected);
%     figure()
%     bar([mean(extract.max_vel(group)), mean(extract.max_vel(selected_trips))])
%     figure()
%     bar([mean(extract.distance(group)), mean(extract.distance(selected_trips))])
end

% add_delete adjusts the trips selections by trying to better match the
% covered distance
function [adjusted, non_replacement_flag, Nbin_dis_actual] = add_delete(group, group_vel, group_dis, idx, Nbin_dis_group_rep, Nbin_dis_actual, mean_dist_piece, selected)
    global extract
    mean_dist_all = mean(extract.distance(group(group_dis==idx)));
    % Available choice from the group
    distance_location = find(group_dis == idx);
    choose_from = setdiff(distance_location ,selected);
    Ndesire = Nbin_dis_group_rep(idx);
    Nactual = Nbin_dis_actual(idx);
    difference = Ndesire - Nactual;
    % Adjust the choice
    while difference > 0
        disp("Optimizing for the covered distance")
        % Find the best choice for matching covered distance
        new_mean_dist = zeros(length(choose_from), 1);
        for i = 1: length(choose_from)
            new_mean_dist(i) = (Nactual*mean_dist_piece + group(choose_from(i)).processed_stats.distance)/(Nactual+1);
        end
        [mean_dist_piece, bestid] = min(abs(new_mean_dist-mean_dist_all));
        to_add = choose_from(bestid);
        % Find the trips in the selectted peak speed bin and also in the
        % distance bin where actual number exceed the desired.
        to_add_in_group_vel = group_vel(to_add);
        already_in_group_vel = find(group_vel(selected) == to_add_in_group_vel);
        excess_group = find(Nbin_dis_actual > Nbin_dis_group_rep);
        for i = 1:length(excess_group)
            in_excess_group = find(group_dis(selected) == excess_group(i));
            to_delete = intersect(already_in_group_vel, in_excess_group);
            % If no such trip found, do nothing
            if isempty(to_delete)
                non_replacement_flag = 1;
                break
            end
            if ~isempty(to_delete)
                Nbin_dis_actual(group_dis(to_delete)) =  Nbin_dis_actual(group_dis(to_delete)) - 1;
                break
            end
        end
        if non_replacement_flag
            break
        end
        % If found, update the choice
        difference = difference - 1;
        Nactual = Nactual + 1;
        choose_from = setdiff(choose_from, to_add);
        selected = [setdiff(selected, to_delete), to_add];
    end
    adjusted = selected;
end
function selected_trips = select(group, Tfull, Trep, bincounts)
    % select the most representative slices in the group
    len_group = length(group);
    
    % Calculate number and time
    [Tgroup_rep, Ngroup_rep] = number_time(Tfull, Trep, group);
    
    % Calculate desired number for each bin of max_speed
    [Nbin_vel_group_rep, vel_bin] = calculate_number_bin(group, Ngroup_rep, bincounts, 'Velocity');
    
    % Calculate desired number for each bin of distance
    [Nbin_dis_group_rep, dis_bin] = calculate_number_bin(group, Ngroup_rep, bincounts, 'Distance');
    
    % Mark the subgroup with velocity and distance
    group_vel = zeros(len_group, 1);
    group_dis = zeros(len_group, 1);
    for i = 1:len_group
        group_vel(i) = discretize_by(group(i), vel_bin, 'Velocity');
        group_dis(i) = discretize_by(group(i), dis_bin, 'Distance');
    end
    
    % Select slices such that normalized peek speeds histogram agrees
    selected = [];
    for i = 1:bincounts
        combination = combnk(find(group_vel==i), Nbin_vel_group_rep(i));
        mean_all = mean(extract_max_vel(group(group_vel==i)));
        %         histogram(normalize(extract_max_vel(group(group_vel==i))))
        %         mean_all = mean_all / len;
        num_comb = size(combination, 1);
        difference = zeros(num_comb, 1);
        for j = 1:num_comb
            mean_piece = mean(extract_max_vel(group(combination(j,:))));
            %             mean_piece = mean_piece / Ngroup_rep;
            difference(j) = abs(mean_piece - mean_all);
        end
        [~, idx] = min(difference);
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
        mean_dist_piece = mean(extract_distance(group(selected)));
        % having less than desired
        if Nbin_dis_diff(i) > 0
            disp('Having less than desired')
            selected = add_delete(group, group_vel, group_dis, i, Nbin_dis_group_rep, Nbin_dis_actual, mean_dist_piece, selected);
        end
    end
    
    %     mean_res = mean(extract_max_vel(group(selected)));
    %     mean_dis = mean(extract_distance(group(selected)));
    
    selected_trips = group(selected);
    figure()
    bar([mean(extract_max_vel(group)), mean(extract_max_vel(selected_trips))])
%     histogram(extract_max_vel(group), vel_bin, 'Normalization', 'probability')
    figure()
    bar([mean(extract_distance(group)), mean(extract_distance(selected_trips))])
%     histogram(extract_distance(group), dis_bin, 'Normalization', 'probability')
end

function adjusted = add_delete(group, group_vel, group_dis, idx, Nbin_dis_group_rep, Nbin_dis_actual, mean_dist_piece, selected)
    mean_dist_all = mean(extract_distance(group(group_dis==idx)));
    distance_location = find(group_dis == idx);
    choose_from = setdiff(distance_location ,selected);
    Ndesire = Nbin_dis_group_rep(idx);
    Nactual = Nbin_dis_actual(idx);
    difference = Ndesire - Nactual;
    while difference > 0
        disp("Optimizing")
        new_mean_dist = zeros(length(choose_from), 1);
        for i = 1: length(choose_from)
            new_mean_dist(i) = (Nactual*mean_dist_piece + group(choose_from(i)).processed_stats.distance)/(Nactual+1);
        end
        [mean_dist_piece, bestid] = min(abs(new_mean_dist-mean_dist_all));
        to_add = choose_from(bestid);
        to_add_in_group_vel = group_vel(to_add);
        already_in_group_vel = find(group_vel(selected) == to_add_in_group_vel);
        excess_group = find(Nbin_dis_actual > Nbin_dis_group_rep);
        for i = excess_group
            in_excess_group = find(group_dis(selected) == i);
            to_delete = intersect(already_in_group_vel, in_excess_group);
            if ~isempty(to_delete)
                break
            end
        end
        difference = difference - 1;
        Nactual = Nactual + 1;
        choose_from = setdiff(choose_from, to_add);
        selected = [setdiff(selected, to_delete), to_add];
    end
    adjusted = selected;
end
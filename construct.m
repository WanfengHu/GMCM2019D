% construct constructs the representative driving cycle with the selected slices
% and raw data.
%
% Usage:
% rep_cyc = construct(d, selected_group, T_rep)
%
% Inputs:
%   d: raw data after preprocess.
%   selected_group: micro trips selected for construction.
%   T_rep: length of the representative cycle.
%
% Outputs:
%   rep_cyc: representative driving cycle. A structure with time and
%   velocity as its fields.

function rep_cyc = construct(d, selected_group, T_rep, idle_interval)
    global extract
    
    % Segregate idle times from the full length cycle into groups
    raw_time_idle = extract.total_time(d) - extract.total_drive_time(d);
    num = ceil(max(raw_time_idle)/idle_interval);
    raw_num_idle = zeros(num,2);
    for i = 1:num
        raw_num_idle(i,1) = (i-0.5)*idle_interval;
        raw_num_idle(i,2) = nnz(raw_time_idle>=(i-1)*idle_interval & raw_time_idle<i*idle_interval);
    end
    
    % Calculate the number of occurrences of the idle times for the rep cycle. 
    N_rep = length(selected_group);
    sele_mod = selected_group;
    for i=1:N_rep
        idle = sele_mod(i).processed.velocity == 0;
        sele_mod(i).processed(idle,:) = [];
    end
    percent_idle = raw_num_idle(:,2)/sum(raw_num_idle(:,2));
    rep_num_idle = [raw_num_idle(:,1), percent_idle*N_rep];
    rep_num_idle(:,2) = round(rep_num_idle(:,2));
    
    % Validation and adjustment of the above number
    N_rep_Real = sum(rep_num_idle(:,2));
    if N_rep_Real < N_rep
        [~,I] = max(percent_idle);
        rep_num_idle(I,2) = rep_num_idle(I,2) + N_rep-N_rep_Real;
    end
    while N_rep_Real > N_rep
        [~,I] = min(percent_idle(rep_num_idle(:,2)>0));
        rep_num_idle(I,2) = rep_num_idle(I,2)-1;
        N_rep_Real = N_rep_Real-1;
    end  
    
    % Calculate the total idle time and required idle time
    total_rep_idletime = rep_num_idle(:,1)'*rep_num_idle(:,2);
    mov_time = sum(extract.total_drive_time(sele_mod));
    desr_rep_idletime = T_rep - mov_time;
    
    % Adjustment to meet the required idle time
    if total_rep_idletime < desr_rep_idletime
        disp('Total idel time less than required');
        final_num_idle = total_less(desr_rep_idletime,rep_num_idle);
    elseif total_rep_idletime > desr_rep_idletime
        disp('Total idel time more than required');
        final_num_idle = total_more(desr_rep_idletime,rep_num_idle);
    end
    if final_num_idle(:,1)'*final_num_idle(:,2) ~= desr_rep_idletime
        disp('Wrong Final_num_idle')
    end
    final_num_idle(final_num_idle(:,2)==0,:) = [];
    
    % Positioning of selected trips
    loc_slice = zeros(N_rep,1);
    for i = 1:N_rep
        loc_slice(i) = sele_mod(i).id;
    end
    [~,loc_slice] = sort(loc_slice);
    
    % Storing the time and velocity information
    time = cell(1,2*N_rep);
    velo = cell(1,2*N_rep);
    for i = 1:N_rep
        time{2*i} = (0:length(sele_mod(loc_slice(i)).processed.time)-1);
        velo{2*i} = sele_mod(loc_slice(i)).processed.velocity';
    end
    
    % Distributing idle times randomly in between the trips
    loc_idle = 1:2:length(time);
    loc_idle = loc_idle(randperm(sum(final_num_idle(:,2))));
    k = 1;
    inx = final_num_idle(:,2);
    for i = 1:length(final_num_idle(:,2))
        while inx(i)~=0
            time{loc_idle(k)}=[0 final_num_idle(i,1)-1];
            velo{loc_idle(k)}=[0 0];
            inx(i)=inx(i)-1;
            k=k+1;
        end
    end
    
    % Putting together the time and velocity
    time(cellfun(@isempty,time))=[];
    velo(cellfun(@isempty,velo))=[];
    velo2=[];
    time2=time{1};
    for i=2:length(time)
        time2=cat(2, time2, 1+time2(end)+time{i});
    end
    for i=1:length(velo)
        velo2 = cat(2, velo2, velo{i});
    end
    
    % Representative cycle
    rep_cyc.time=time2;
    rep_cyc.velo=velo2;
end
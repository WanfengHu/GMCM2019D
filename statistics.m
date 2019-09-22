function stats = statistics(piece)
    if isempty(piece)
        stats = [];
        return
    end
    
    % Velocity
    vel = piece.velocity;
    stats.mean_vel =  mean(vel);
    stats.mean_driving_vel = mean(vel(vel > 0));
    stats.max_vel = max(vel);
    stats.std_vel = std(vel);
    
    % Acceleration
    time = piece.time;
    a = diff(vel)/seconds(diff(time))/3.6;
    acceleration = a > 0.1;
    deceleration = a < -0.1;
    stats.max_acc = max(a(acceleration));
    stats.min_acc = min(a(acceleration));
    stats.mean_acc = mean(a(acceleration));
    stats.max_dec = min(a(deceleration));
    stats.min_dec = max(a(deceleration));
    stats.mean_dec = mean(a(deceleration));
    stats.std_acc = std(a(acceleration));
    
    % Time
    total = length(time);
    idle = vel == 0;
    stats.idle_percent = nnz(idle)/total;
    stats.acc_percent = nnz(acceleration)/total;
    stats.dec_percent = nnz(deceleration)/total;
    stats.total_time = total;
    
    % Congestion (max_velocity < 10 km/h) --> idle
    if stats.max_vel < 10
        stats.idle_percent = 1;
        stats.acc_percent = 0;
        stats.dec_percent = 0;
    end
    
    % Distance
    stats.distance = trapz(vel)/3600;
end
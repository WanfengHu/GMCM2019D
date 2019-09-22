function total_drive_time = extract_total_drive_time(group)
    total_drive_time = extract_stats_form_group(group, 'TotalNonIdleTime');
end
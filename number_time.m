function [Tgroup_rep, Ngroup_rep] = number_time(Tfull, Trep, group)
    Ngroup = length(group);
    Tgroup = sum(extract_total_drive_time(group)); 
    Tgroup_rep = Tgroup/Tfull * Trep;
    Ngroup_rep = round(Tgroup_rep/Tgroup * Ngroup);   
end
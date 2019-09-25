% number_time calculates the number of trips to be selected from a group
% to construct a representative cycle and their time duration in a
% representative cycle.
%
% Usage:
% [Tgroup_rep, Ngroup_rep] = number_time(Tfull, Trep, group)
%
% Inputs:
%   Tfull: time duration of full length cycle.
%   Trep: time duration of representative cycle.
%   group: a set of trips belonging to the same group.
%   
% Outputs:
%   Tgroup_rep: time duration of selected group of micro-trips in 
%   representative cycle.
%   Ngroup_rep: number of trips selected from the group to construct
%   a representative cycle.

function [Tgroup_rep, Ngroup_rep] = number_time(Tfull, Trep, group)
    global extract
    Ngroup = length(group);
    Tgroup = sum(extract.total_drive_time(group)); 
    Tgroup_rep = Tgroup/Tfull * Trep;
    Ngroup_rep = round(Tgroup_rep/Tgroup * Ngroup);   
end
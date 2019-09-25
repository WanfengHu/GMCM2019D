% extract_slice extarcts cinematic slices of the driving test which are
% bracketed by two consecutive idle speed state (velocity = 0).
%
% Usage:
%   idx = extract_slice(velocity)

function idx = extract_slice(velocity)
    isZero = (velocity == 0);
    state_change = [0; diff(isZero)];
    idx = [1; find(state_change == 1)];
end

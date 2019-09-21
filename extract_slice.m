% *************************************************************
% extract_slice extarcts cinematic slices of the driving test which are
% bracketed by two idle speed state.
% *************************************************************
function idx = extract_slice(velocity)
    isZero = (velocity == 0);
    state_change = [0; diff(isZero)];
    idx = [1; find(state_change == 1)];
end

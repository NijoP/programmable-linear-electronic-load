function release = plel_release_decision(checks)
%PLEL_RELEASE_DECISION Fail-closed design-only aggregation.
% Hardware tests are separate. CONDITIONAL is accepted only with explicit
% design closure, an accepted modeled assumption, and recorded evidence.
    release='BLOCKED';
    if isempty(checks), return; end
    for k=1:numel(checks)
        c=checks{k};
        if ~isstruct(c) || ~isfield(c,'status') || ...
                ~isfield(c,'evidence') || isempty(strtrim(c.evidence))
            return;
        end
        if strcmp(c.status,'PASS'), continue; end
        if ~strcmp(c.status,'CONDITIONAL') || ...
                ~isfield(c,'design_closed') || ~isequal(c.design_closed,true) || ...
                ~isfield(c,'assumption_accepted') || ~isequal(c.assumption_accepted,true) || ...
                ~isfield(c,'assumption') || isempty(strtrim(c.assumption))
            return;
        end
    end
    release='PASS';
end

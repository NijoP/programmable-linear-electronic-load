function [value, entry] = plel_parameter(entries, id)
%PLEL_PARAMETER Strict lookup of one resolved parameter with provenance.
%   [VALUE, ENTRY] = PLEL_PARAMETER(ENTRIES, ID) consumes metadata returned by
%   PLEL_PARAMETERS. Unknown IDs and unresolved TBD values throw; there is no
%   fallback, default value, implicit calibration, or NaN substitution.

if isstring(id) && isscalar(id) && ~ismissing(id)
    id = char(id);
end
if ~(ischar(id) && isrow(id) && isvarname(id))
    error('plel:InvalidParameterID', 'ID must be a scalar MATLAB identifier.');
end
if ~(isstruct(entries) && isvector(entries) && ~isempty(entries) && ...
        all(isfield(entries, {'id', 'value', 'classification', 'context'})))
    error('plel:InvalidRegistry', 'Expected metadata returned by plel_parameters.');
end
matches = find(strcmp({entries.id}, id));
if isempty(matches)
    error('plel:UnknownParameter', 'Unknown parameter: %s', id);
elseif numel(matches) ~= 1
    error('plel:InvalidRegistry', 'Duplicate parameter: %s', id);
end
entry = entries(matches);
if strcmp(entry.classification, 'TBD')
    error('plel:UnresolvedParameter', 'Parameter %s is TBD; supply traceable evidence first.', id);
end
allowed = {'FROZEN_FROM_PDF', 'DATASHEET', 'MEASURED', 'CALIBRATED'};
if ~any(strcmp(allowed, entry.classification)) || strcmp(entry.context, 'unknown')
    error('plel:InvalidRegistry', 'Invalid resolved provenance for %s.', id);
end
value = entry.value;
numericValue = isnumeric(value) && ~islogical(value) && isreal(value) && ...
    isscalar(value) && isfinite(value);
textValue = ischar(value) && isrow(value) && ~isempty(strtrim(value));
if ~(numericValue || textValue)
    error('plel:InvalidRegistry', 'Parameter %s has no usable scalar value.', id);
end
end

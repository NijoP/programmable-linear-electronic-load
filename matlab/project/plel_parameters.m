function [params, entries] = plel_parameters(registryFile)
%PLEL_PARAMETERS Load and strictly validate the engineering parameter registry.
%   [PARAMS, ENTRIES] = PLEL_PARAMETERS() loads data/parameters.json relative
%   to this file. An optional filename supports validation of other registries.
%   PARAMS contains resolved numeric/text values ONLY. TBD IDs are omitted.
%   ENTRIES is a struct array retaining all provenance; TBD value is [].
%   Use PLEL_PARAMETER(ENTRIES, ID) to obtain a value with a hard error on TBD.
%   Classification is provenance, not evidence of physical qualification.

if nargin == 0
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    registryFile = fullfile(root, 'data', 'parameters.json');
end
if isstring(registryFile) && isscalar(registryFile) && ~ismissing(registryFile)
    registryFile = char(registryFile);
end
if ~(ischar(registryFile) && isrow(registryFile) && ~isempty(strtrim(registryFile)))
    error('plel:InvalidPath', 'Registry filename must be a nonempty text scalar.');
end
[fid, message] = fopen(registryFile, 'r', 'n', 'UTF-8');
if fid < 0
    error('plel:RegistryIO', 'Cannot open registry: %s (%s)', registryFile, message);
end
closeFile = onCleanup(@() fclose(fid)); %#ok<NASGU>
text = fscanf(fid, '%c');
try
    data = jsondecode(text);
catch cause
    error('plel:RegistryJSON', 'Invalid registry JSON: %s', cause.message);
end
require(isstruct(data) && isscalar(data), 'Registry must be a JSON object.');
require(isfield(data, 'schema_version') && ...
    finiteScalar(data.schema_version) && data.schema_version == 1, ...
    'Expected numeric schema_version 1.');
require(isfield(data, 'parameters'), 'Registry must contain parameters.');
raw = data.parameters;
require(~isempty(raw) && (isstruct(raw) || iscell(raw)) && isvector(raw), ...
    'Parameters must be a nonempty array of objects.');
if isstruct(raw)
    raw = num2cell(raw);
end
required = {'id', 'value', 'unit', 'classification', 'source', 'context', 'notes'};
classes = {'FROZEN_FROM_PDF', 'DATASHEET', 'MEASURED', 'CALIBRATED', 'TBD'};
contexts = {'specification', 'nominal', 'provisional', 'illustrative', 'unknown'};
entries = repmat(struct('id', '', 'value', [], 'unit', '', ...
    'classification', '', 'source', struct(), 'context', '', 'notes', ''), numel(raw), 1);
params = struct();
ids = cell(numel(raw), 1);
for k = 1:numel(raw)
    e = raw{k};
    require(isstruct(e) && isscalar(e) && all(isfield(e, required)), ...
        'Every parameter must be an object with all required fields.');
    require(textScalar(e.id) && isvarname(e.id) && numel(e.id) <= 63 && ...
        ~isempty(regexp(e.id, '^[a-z][a-zA-Z0-9_]*$', 'once')), ...
        'Parameter ID must be a lowercase-initial MATLAB identifier (max 63 characters).');
    require(~any(strcmp(ids(1:k-1), e.id)), ['Duplicate parameter ID: ' e.id]);
    ids{k} = e.id;
    require(textScalar(e.unit), ['Missing explicit unit for ' e.id]);
    require(textScalar(e.classification) && any(strcmp(classes, e.classification)), ...
        ['Invalid classification for ' e.id]);
    require(textScalar(e.context) && any(strcmp(contexts, e.context)), ...
        ['Invalid context for ' e.id]);
    require(textScalar(e.notes), ['Missing notes for ' e.id]);
    source = e.source;
    require(isstruct(source) && isscalar(source) && ...
        all(isfield(source, {'document', 'section', 'physical_page'})), ...
        ['Missing source metadata for ' e.id]);
    require(textScalar(source.document) && textScalar(source.section), ...
        ['Invalid source document or section for ' e.id]);
    page = source.physical_page;
    require(finiteScalar(page) && page >= 1 && page == fix(page), ...
        ['Source page must be a positive 1-based integer for ' e.id]);
    if strcmp(source.document, 'docs/source/design-source.pdf')
        require(page <= 34, ['Source page exceeds PDF page count for ' e.id]);
    end
    if strcmp(e.classification, 'FROZEN_FROM_PDF')
        require(strcmp(source.document, 'docs/source/design-source.pdf'), ...
            ['Frozen parameter must cite the archived specification: ' e.id]);
    end
    if strcmp(e.classification, 'TBD')
        % MATLAB releases decode object-valued JSON null as [] or scalar NaN.
        nullValue = isnumeric(e.value) && isreal(e.value) && ...
            (isempty(e.value) || (isscalar(e.value) && isnan(e.value)));
        require(nullValue && strcmp(e.context, 'unknown'), ...
            ['TBD must have null value and unknown context: ' e.id]);
        e.value = [];
    else
        require(~strcmp(e.context, 'unknown'), ['Resolved value has unknown context: ' e.id]);
        require(finiteScalar(e.value) || textScalar(e.value), ...
            ['Resolved value must be finite numeric scalar or nonempty text: ' e.id]);
        params.(e.id) = e.value;
    end
    entries(k) = struct('id', e.id, 'value', e.value, 'unit', e.unit, ...
        'classification', e.classification, 'source', source, ...
        'context', e.context, 'notes', e.notes);
end
end

function tf = finiteScalar(value)
tf = isnumeric(value) && ~islogical(value) && isreal(value) && ...
    isscalar(value) && isfinite(value);
end

function tf = textScalar(value)
tf = ischar(value) && isrow(value) && ~isempty(strtrim(value));
end

function require(condition, message)
if ~condition
    error('plel:InvalidRegistry', '%s', message);
end
end

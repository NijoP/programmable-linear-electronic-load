function test_foundation()
%TEST_FOUNDATION Execute base-MATLAB foundation and rejection tests.
%   Run from any working directory after adding this tests folder to path.
%   This executes the real MATLAB code, not Python reference arithmetic.

root = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
oldDir = pwd;
scratch = tempname;
mkdir(scratch);
cleanup = onCleanup(@() restoreEnvironment(oldPath, oldDir, scratch)); %#ok<NASGU>
addpath(fullfile(root, 'matlab', 'project'));
cd(scratch);
actualRoot = plel_setup();
assert(strcmp(actualRoot, root), 'Setup returned the wrong repository root.');
modules = {'project', 'main', 'hardware', 'electrical', 'control', ...
    'thermal', 'power', 'sensors', 'protection', 'firmware', 'battery', ...
    'simulation', 'validation', 'analysis', 'plotting'};
pathEntries = strsplit(path, pathsep);
for k = 1:numel(modules)
    assert(any(strcmp(pathEntries, fullfile(root, 'matlab', modules{k}))), ...
        'Missing explicit module path.');
end
[p, entries] = plel_parameters();
assert(isstruct(p) && isscalar(p));
assert(isstruct(entries) && isvector(entries));
assert(numel(unique({entries.id})) == numel(entries));
checks = { ...
    'vin_min_V', 10; 'vin_max_V', 15; 'current_max_A', 2; ...
    'power_peak_W', 30; 'power_initial_continuous_W', 24; ...
    'shunt_ohm', 0.01; 'sense_gain_V_V', 100; 'dac_bits', 12; ...
    'dac_code_cap', 2482; 'dac_transfer_denominator', 4096; ...
    'divider_high_ohm', 33000; 'divider_low_ohm', 7500; ...
    'ntc_r0_ohm', 10000; 'ntc_beta_K', 3950; 'ntc_t0_C', 25; ...
    'num_mosfets', 4; 'pcb_layers', 2; 't_shutdown_C', 85};
for k = 1:size(checks, 1)
    id = checks{k, 1};
    expected = checks{k, 2};
    assert(isfield(p, id), ['Missing mandatory field: ' id]);
    assert(isequal(p.(id), expected), ['Incorrect value: ' id]);
    [value, meta] = plel_parameter(entries, id);
    assert(isequal(value, expected));
    assert(strcmp(meta.id, id));
end
assert(strcmp(p.reset_pin, 'EN'));
assert(strcmp(plel_parameter(entries, "reset_pin"), 'EN'));
assert(2^p.dac_bits == p.dac_transfer_denominator);
assert(floor(2 * p.dac_transfer_denominator / p.dac_supply_V) == p.dac_code_cap);
assert(abs(p.dac_code_cap * p.dac_supply_V / p.dac_transfer_denominator ...
    - 1.999658203125) < 1e-12);
[~, capMeta] = plel_parameter(entries, 'dac_code_cap');
assert(capMeta.source.physical_page == 12);
[~, ntcMeta] = plel_parameter(entries, 'ntc_beta_K');
assert(ntcMeta.source.physical_page == 19);
[~, dacMeta] = plel_parameter(entries, 'dac_transfer_denominator');
assert(strcmp(dacMeta.classification, 'DATASHEET'));
assert(dacMeta.source.physical_page == 19);
for k = 1:numel(entries)
    e = entries(k);
    if strcmp(e.classification, 'TBD')
        assert(isempty(e.value));
        assert(~isfield(p, e.id), 'TBD must not enter the resolved parameter struct.');
        expectError(@() plel_parameter(entries, e.id), 'plel:UnresolvedParameter');
    else
        assert(isfield(p, e.id));
    end
end
expectError(@() plel_parameter(entries, 'adc_gain_V_per_code'), 'plel:UnresolvedParameter');
expectError(@() plel_parameter(entries, 'not_registered'), 'plel:UnknownParameter');
expectError(@() plel_parameter(entries, 2), 'plel:InvalidParameterID');
expectError(@() plel_parameter([entries; entries(1)], entries(1).id), 'plel:InvalidRegistry');
expectError(@() plel_parameters(42), 'plel:InvalidPath');
expectError(@() plel_parameters(fullfile(scratch, 'missing.json')), 'plel:RegistryIO');

registry = jsondecode(fileread(fullfile(root, 'data', 'parameters.json')));
mutatedFile = fullfile(scratch, 'mutated.json');
mutant = registry; mutant.schema_version = 2;
reject(mutant, mutatedFile);
mutant = registry; mutant.schema_version = true;
reject(mutant, mutatedFile);
mutant = rmfield(registry, 'schema_version');
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters = [];
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(end+1) = mutant.parameters(1);
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).id = 'invalid-id';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).id = repmat('a', 1, 64);
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).value = true;
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).value = [1 2];
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).value = NaN;
reject(mutant, mutatedFile); % jsonencode emits null, invalid for resolved entries.
mutant = registry; mutant.parameters(1).value = '';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).unit = '';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).notes = '';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).classification = 'ASSUMED';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).context = 'unknown';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).source.physical_page = 0;
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).source.physical_page = 35;
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).source.physical_page = 10.5;
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).source.section = '';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(1).source.document = 'wrong.pdf';
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters = rmfield(mutant.parameters, 'unit');
reject(mutant, mutatedFile);
tbdIndex = find(strcmp({registry.parameters.classification}, 'TBD'), 1);
assert(~isempty(tbdIndex));
mutant = registry; mutant.parameters(tbdIndex).value = 0;
reject(mutant, mutatedFile);
mutant = registry; mutant.parameters(tbdIndex).context = 'nominal';
reject(mutant, mutatedFile);
writeText(mutatedFile, '{broken json');
expectError(@() plel_parameters(mutatedFile), 'plel:RegistryJSON');
% Explicit filename produces exactly the same resolved values and metadata.
[p2, entries2] = plel_parameters(fullfile(root, 'data', 'parameters.json'));
assert(isequal(p, p2) && isequal(entries, entries2));
fprintf('MATLAB foundation tests passed: bootstrap, %d entries, strict lookup and mutation cases.\n', ...
    numel(entries));
end

function reject(data, filename)
writeText(filename, jsonencode(data));
expectError(@() plel_parameters(filename), 'plel:InvalidRegistry');
end

function writeText(filename, text)
[fid, message] = fopen(filename, 'w', 'n', 'UTF-8');
assert(fid >= 0, message);
closeFile = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s', text);
end

function expectError(action, expectedID)
try
    action();
catch cause
    assert(strcmp(cause.identifier, expectedID), ...
        'Expected %s, got %s: %s', expectedID, cause.identifier, cause.message);
    return
end
error('plel:TestFailure', 'Expected error %s was not raised.', expectedID);
end

function restoreEnvironment(oldPath, oldDir, scratch)
cd(oldDir);
path(oldPath);
if isfolder(scratch)
    rmdir(scratch, 's');
end
end

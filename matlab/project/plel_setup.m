function root = plel_setup()
%PLEL_SETUP Add explicit project module paths, independent of current folder.
%   ROOT = PLEL_SETUP() returns the repository root. No persistent path saving,
%   toolbox loading, file generation, hardware access, or model execution.

projectDir = fileparts(mfilename('fullpath'));
matlabDir = fileparts(projectDir);
root = fileparts(matlabDir);
modules = {'project', 'main', 'hardware', 'electrical', 'control', ...
    'thermal', 'power', 'sensors', 'protection', 'firmware', 'battery', ...
    'simulation', 'validation', 'analysis', 'plotting'};
folders = cellfun(@(name) fullfile(matlabDir, name), modules, ...
    'UniformOutput', false);
% Validate the complete layout before changing the caller's path.
for k = 1:numel(folders)
    if ~isfolder(folders{k})
        error('plel:MissingModule', 'Required module folder missing: %s', folders{k});
    end
end
addpath(folders{:});
end

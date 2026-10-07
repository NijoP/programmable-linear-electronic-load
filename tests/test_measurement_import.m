function test_measurement_import()
 cfgfile=fullfile(fileparts(fileparts(mfilename('fullpath'))),'measurements','hardware_validation_template.csv'); d=import_hardware_measurements(cfgfile); assert(ismember('current_A',d.Properties.VariableNames)); fprintf('PASS: measurement template import contract.\n');
end

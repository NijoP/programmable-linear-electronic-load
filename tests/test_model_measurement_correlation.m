function test_model_measurement_correlation()
 cfgfile=fullfile(fileparts(fileparts(mfilename('fullpath'))),'measurements','hardware_validation_template.csv'); d=import_hardware_measurements(cfgfile); r=correlate_hardware_vs_model(d,struct('current_A',NaN,'vin_V',NaN)); assert(isstruct(r)); fprintf('PASS: model/measurement correlation contract.\n');
end

function data = import_hardware_measurements(filename)
%IMPORT_HARDWARE_MEASUREMENTS Import explicitly measured prototype data.
    if nargin<1, filename=fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), ...
            'measurements','hardware_validation_template.csv'); end
    if ~isfile(filename), error('plel:MeasurementFile','Measurement file not found: %s',filename); end
    data=readtable(filename,'ReadVariableNames',true,'TextType','string');
    required={'timestamp','vin_V','current_A','power_W','ambient_C','sink_C','case_C', ...
        'gate_V','dac_V','sense_V','adc_raw','fault','estop','mode'};
    missing=setdiff(required,data.Properties.VariableNames);
    if ~isempty(missing), error('plel:MeasurementSchema','Missing columns: %s',strjoin(missing,', ')); end
    data.Properties.UserData=struct('provenance','MEASURED only when populated from actual hardware', ...
        'source_file',filename,'status','IMPORTED_NOT_VALIDATED');
end

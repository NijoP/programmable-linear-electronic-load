function result = correlate_hardware_vs_model(measurement, simulation)
%CORRELATE_HARDWARE_VS_MODEL Compare measured columns against model vectors.
% Simulation fields must be supplied by the caller; no measurement is invented.
    names={'vin_V','current_A','power_W','ambient_C','sink_C','case_C','gate_V','dac_V','sense_V'};
    result=struct();
    for k=1:numel(names)
        n=names{k};
        if ~ismember(n,measurement.Properties.VariableNames) || ~isfield(simulation,n), continue; end
        m=measurement.(n); s=simulation.(n); valid=isfinite(m) & isfinite(s);
        if ~any(valid), result.(n)=struct('status','NO_MEASURED_SAMPLES'); continue; end
        e=m(valid)-s(valid); denom=max(abs(s(valid)),eps);
        result.(n)=struct('status','CORRELATED','samples',sum(valid),'bias',mean(e), ...
            'rmse',sqrt(mean(e.^2)),'max_absolute_error',max(abs(e)), ...
            'mean_relative_error',mean(abs(e)./denom),'provenance','MEASURED versus SIMULATED');
    end
    result.note='No correlation result is hardware qualification; calibration status must be separately established.';
end

function test_current_sense_budget()
 cfg=plel_hardware_config(); r=plel_r1_sense_twin(cfg,300); assert(numel(r.current_A)==5); assert(all(isfinite(r.mean_A))); fprintf('PASS: shunt/INA180/ADC sense twin.\n');
end

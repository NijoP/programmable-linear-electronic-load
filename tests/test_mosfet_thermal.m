function test_mosfet_thermal()
 cfg=plel_hardware_config(); r=plel_r1_thermal_twin(cfg); assert(numel(r.ambient_C)==5); assert(all(r.margin_C>0)); fprintf('PASS: thermal twin ambient sweep.\n');
end

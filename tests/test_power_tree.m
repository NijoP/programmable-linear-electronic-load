function test_power_tree()
 cfg=plel_hardware_config(); r=plel_r1_power_tree_twin(cfg); assert(r.I3V3_margin_A>0); fprintf('PASS: R1 power-tree twin.\n');
end

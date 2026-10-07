function test_gate_drive()
 cfg=plel_hardware_config(); r=plel_r1_gate_twin(cfg); assert(all(r.tau_s>0)); assert(r.lm358_source_margin_A<0); assert(abs(r.initial_current_A-0.0328)<1e-12); fprintf('PASS: gate-loading design twin.\n');
end

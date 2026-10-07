function test_loop_model()
 cfg=plel_hardware_config(); r=plel_r1_loop_twin(cfg); assert(r.LOOP_STABILITY_HARDWARE_TEST_REQUIRED); assert(all(r.estimated_phase_margin_deg>0)); fprintf('PASS: loop design envelope remains explicitly unmeasured.\n');
end

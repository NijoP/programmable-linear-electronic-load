function test_operating_envelope()
 cfg=plel_hardware_config(); r=plel_r1_operating_envelope(cfg); assert(all(r.safe_current_A<=2+1e-9)); fprintf('PASS: operating envelope twin.\n');
end

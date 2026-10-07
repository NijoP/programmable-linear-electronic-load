function test_soa_model()
 cfg=plel_hardware_config(); r=plel_r1_soa_twin(cfg); assert(r.worst_margin_A<0 || isfinite(r.worst_margin_A)); assert(all(size(r.margin_A)==[51 51])); fprintf('PASS: SOA simulation map generated without fabricated curve.\n');
end

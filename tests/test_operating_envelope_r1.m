function test_operating_envelope_r1()
%TEST_OPERATING_ENVELOPE_R1 Verify bounded 10-15 V design envelope.
    cfg=plel_hardware_config(); e=plel_r1_operating_envelope(cfg);
    assert(numel(e.vin_V)==101); assert(e.I_at_10V_A <= 2+1e-12); assert(e.I_at_15V_A <= 2+1e-12);
    assert(all(e.safe_current_A >= 0)); assert(e.Pmax_W==30);
    fprintf('PASS: R1 operating envelope is bounded by electrical and thermal design limits.\n');
end

function test_startup_behavior()
 r=plel_r1_state_twin({'POWER_ON','SELF_TEST_OK','START','BROWNOUT'}); assert(strcmp(r.timeline{1}.state,'SELF_TEST')); assert(r.timeline{3}.power_stage_enable); assert(~r.timeline{4}.power_stage_enable); fprintf('PASS: startup/brownout state twin.\n');
end

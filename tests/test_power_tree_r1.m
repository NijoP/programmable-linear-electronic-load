function test_power_tree_r1()
%TEST_POWER_TREE_R1 Verify R1 Wi-Fi-aware rail budget.
    cfg=plel_hardware_config(); r=validate_power_tree(cfg);
    assert(strcmp(r.status,'PASS')); assert(r.value.I3V3_A < cfg.datasheet.ldo33_current_max_A);
    assert(r.value.I3V3_capacity_margin_A > 0); assert(r.value.P7805_W > 0);
    fprintf('PASS: R1 power tree has positive design current margin.\n');
end

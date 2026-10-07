function test_mosfet_current_sharing()
 cfg=plel_hardware_config(); r=plel_r1_current_sharing(cfg,500); assert(all(size(r.branch_current_A)==[500 4])); assert(all(r.worst_branch_current_A>=0)); assert(all(abs(sum(r.branch_current_A,2)-2)<1e-9)); fprintf('PASS: four-device non-ideal current sharing model.\n');
end

function test_hardware_validation_status()
 r=hardware_validation_status(); assert(strcmp(r.HARDWARE_VALIDATION,'PENDING')); assert(strcmp(r.items.current_sharing,'SIMULATION_CLOSED')); assert(strcmp(r.items.soa_hot_case,'PHYSICAL_TEST_REQUIRED')); fprintf('PASS: hardware validation status separation.\n');
end

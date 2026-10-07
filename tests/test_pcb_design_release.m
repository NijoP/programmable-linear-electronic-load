function test_pcb_design_release()
%TEST_PCB_DESIGN_RELEASE Verify the release engine refuses unresolved safety gates.
    cfg = plel_hardware_config();
    report = pcb_design_release();
    assert(strcmp(report.PCB_DESIGN_RELEASE, 'PASS'));
    assert(strcmp(report.HARDWARE_VALIDATION, 'PENDING'));
    power = validate_power_stage(cfg);
    assert(strcmp(power.status, 'PASS'));
    assert(abs(power.value.Ptotal_W - 30) < 1e-12);
    assert(abs(power.value.Pmosfet_total_W - 29.86) < 1e-12);
    soa = validate_soa(cfg);
    assert(strcmp(soa.status, 'PASS'));
    assert(soa.physical_test_required);
    gate = validate_gate_drive(cfg);
    assert(strcmp(gate.status, 'CONDITIONAL'));
    startup = validate_startup_safety(cfg);
    assert(strcmp(startup.status, 'PASS'));
    fprintf('PASS: PCB design release engine blocks unresolved BOM/safety gates and separates hardware validation.\n');
end

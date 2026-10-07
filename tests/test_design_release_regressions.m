function test_design_release_regressions()
%TEST_DESIGN_RELEASE_REGRESSIONS Regression tests for false-green mechanisms.
    p=struct('status','PASS','evidence','test evidence');
    assert(strcmp(plel_release_decision({p}),'PASS'));
    assert(strcmp(plel_release_decision({}),'BLOCKED'));
    for status={'FAIL','BLOCKED','PENDING','PARTIAL','UNKNOWN','CONDITIONAL',''}
        x=p; x.status=status{1};
        assert(strcmp(plel_release_decision({p,x}),'BLOCKED'));
    end
    x=p; x.evidence=''; assert(strcmp(plel_release_decision({x}),'BLOCKED'));
    x=p; x.status='CONDITIONAL'; x.design_closed=true;
    x.assumption_accepted=true; x.assumption='Explicit bounded test assumption';
    assert(strcmp(plel_release_decision({x}),'PASS'));
    x.design_closed=false;
    assert(strcmp(plel_release_decision({x}),'BLOCKED'));

    c=plel_hardware_config(); g=plel_r1_gate_twin(c);
    assert(abs(g.initial_current_A-0.0328)<1e-12);
    assert(all(abs(g.tau_s-([1.5 2]*1e-9)/(1/1000+1/100000))<1e-15));
    assert(g.lm358_source_margin_A<0);
    c1=c; c1.operating.mosfet_count=1; g1=plel_r1_gate_twin(c1);
    assert(abs(g.initial_current_A-4*g1.initial_current_A)<1e-12);
    assert(isequal(g.tau_s,g1.tau_s));

    s=validate_current_sense(c);
    assert(abs(s.value.input_referred_offset_A-0.05)<1e-12);
    assert(abs(s.value.worst_case_partial_error_A(end)-0.0907)<1e-12);
    pwr=validate_power_tree(c); twin=plel_r1_power_tree_twin(c);
    assert(abs(pwr.value.I5V_A-0.698)<1e-12);
    assert(abs(pwr.value.P7805_W-6.98)<1e-12);
    assert(abs(pwr.value.PLDO_W-0.9316)<1e-12);
    assert(abs(twin.P5V_reg_W-pwr.value.P7805_W)<1e-12);
    safe=validate_startup_safety(c);
    assert(sum(safe.value.truth_table(:,5))==1);
    assert(isequal(safe.value.truth_table(15,:),[1 1 1 0 1]));
    assert(~safe.value.implemented_connectivity_verified);
    release=pcb_design_release();
    assert(strcmp(release.PCB_DESIGN_RELEASE,'BLOCKED'));
    assert(strcmp(release.HARDWARE_VALIDATION,'PENDING'));
    fprintf('PASS: release semantics, four branches, offset gain, cascade power, safety polarity.\n');
end

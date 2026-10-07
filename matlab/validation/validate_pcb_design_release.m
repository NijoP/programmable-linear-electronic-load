function report = validate_pcb_design_release()
%VALIDATE_PCB_DESIGN_RELEASE Execute all pre-fabrication baseline checks.
% Physical validation is reported separately and is never inferred from MATLAB.
    cfg=plel_hardware_config();
    checks={validate_bom(cfg),validate_power_stage(cfg),validate_soa(cfg), ...
        validate_thermal(cfg),validate_current_sense(cfg),validate_gate_drive(cfg), ...
        validate_power_tree(cfg),validate_startup_safety(cfg), ...
        validate_pcb_current_paths(cfg),validate_footprints(cfg)};
    statuses=cellfun(@(x) x.status,checks,'UniformOutput',false);
    if any(strcmp(statuses,'BLOCKED'))
        release='BLOCKED';
    elseif any(strcmp(statuses,'CONDITIONAL'))
        release='CONDITIONAL';
    else
        release='PASS';
    end
    report=struct('PCB_DESIGN_RELEASE',release,'HARDWARE_VALIDATION','PENDING', ...
        'source',cfg.source,'checks',{checks}, ...
        'note','Hardware validation is pending and cannot be inferred from MATLAB execution.');
end

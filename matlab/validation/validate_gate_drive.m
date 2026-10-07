function result = validate_gate_drive(cfg)
%VALIDATE_GATE_DRIVE Correct branch count and refuse unqualified headroom.
    value=plel_r1_gate_twin(cfg);
    value.aggregate_Ciss_min_F=min(value.aggregate_Ciss_F);
    value.aggregate_Ciss_max_F=max(value.aggregate_Ciss_F);
    value.gate_network_tau_min_s=min(value.tau_s);
    value.gate_network_tau_max_s=max(value.tau_s);
    value.LM358_source_margin_mA=1000*value.lm358_source_margin_A;
    value.resistor_candidates_ohm=[1000 2200 3300 4700];
    value.candidate_step_current_A=cfg.operating.mosfet_count* ...
        cfg.operating.gate_zener_V./value.resistor_candidates_ohm;
    result=plel_validation_result('LM358B four-device gate drive','BLOCKED',value, ...
        cfg.datasheet.lm_output_source_mA*1e-3,value.lm358_source_margin_A, ...
        'CALCULATED/UNQUALIFIED_LIMIT','Four parallel gate branches; source-current and voltage-swing guarantees are not yet reconciled',true, ...
        'Resistor sweep is not component approval; current limit, switch range and DC headroom require design closure');
end

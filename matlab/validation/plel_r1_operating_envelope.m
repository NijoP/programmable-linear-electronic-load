function envelope = plel_r1_operating_envelope(cfg)
%PLEL_R1_OPERATING_ENVELOPE Map electrical and thermal design regions.
    v=linspace(cfg.operating.vin_min_V,cfg.operating.vin_max_V,101);
    i_power=min(cfg.operating.imax_A,cfg.operating.pmax_W./v);
    % Four-device thermal limit uses the released illustrative sink target.
    available_per_device=(cfg.thermal.junction_target_C-cfg.operating.ambient_example_C)/ ...
        (cfg.datasheet.mosfet_rthetaJC_K_W+cfg.thermal.rcs_design_K_W+cfg.thermal.rsa_target_K_W*cfg.operating.mosfet_count);
    i_thermal=max(0,min(cfg.operating.imax_A,available_per_device ./ max(v,eps)));
    safe=min(i_power,i_thermal);
    region=repmat({'SAFE_DESIGN_REGION'},size(v));
    region(safe < i_power)={'DERATING_REGION'};
    region(safe <= 0)={'PROHIBITED_REGION'};
    envelope=struct('vin_V',v,'electrical_current_limit_A',i_power, ...
        'thermal_current_limit_A',i_thermal,'safe_current_A',safe,'region',{region}, ...
        'thermal_basis','Calculated design target; not measured thermal performance', ...
        'I_at_10V_A',safe(1),'I_at_15V_A',safe(end),'Pmax_W',cfg.operating.pmax_W);
end

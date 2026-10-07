function out = plel_r1_power_tree_twin(cfg, ambient_C)
%PLEL_R1_POWER_TREE_TWIN R1 rail budget and illustrative regulator dissipation.
    if nargin<2, ambient_C=[10 25 35 45 55]; end
    i3=cfg.r1_power.three_v_three_budget_A;
    % A linear 3V3 regulator draws its output current from the 5V rail.
    % Quiescent currents are excluded: losses below are lower bounds.
    i5=cfg.r1_power.five_v_budget_A+i3;
    p5=(cfg.operating.vin_max_V-5)*i5; p3=(5-3.3)*i3;
    out=struct('ambient_C',ambient_C,'I5V_A',i5,'I3V3_A',i3,'P5V_reg_W',p5,'P3V3_ldo_W',p3, ...
        'I3V3_margin_A',cfg.datasheet.ldo33_current_max_A-i3, ...
        'I5V_local_A',cfg.r1_power.five_v_budget_A, ...
        'regulator_temperature_model','Design-time package/cooling thermal model required; prototype measurements are separate', ...
        'provenance','CALCULATED/DATASHEET/DESIGN_TARGET');
end

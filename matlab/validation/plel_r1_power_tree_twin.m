function out = plel_r1_power_tree_twin(cfg, ambient_C)
%PLEL_R1_POWER_TREE_TWIN R1 rail budget and illustrative regulator dissipation.
    if nargin<2, ambient_C=[10 25 35 45 55]; end
    i5=cfg.r1_power.five_v_budget_A; i3=cfg.r1_power.three_v_three_budget_A;
    p5=(cfg.operating.vin_max_V-5)*i5; p3=(5-3.3)*i3;
    out=struct('ambient_C',ambient_C,'I5V_A',i5,'I3V3_A',i3,'P5V_reg_W',p5,'P3V3_ldo_W',p3, ...
        'I3V3_margin_A',cfg.datasheet.ap2112_current_max_A-i3, ...
        'regulator_temperature_model','TBD without package thetaJA and board copper; measure after fabrication', ...
        'provenance','CALCULATED/DATASHEET/DESIGN_TARGET');
end

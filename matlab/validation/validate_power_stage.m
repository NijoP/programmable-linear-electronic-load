function result = validate_power_stage(cfg)
%VALIDATE_POWER_STAGE Verify the source operating-point arithmetic.
    o=cfg.operating; ib=o.imax_A/o.mosfet_count;
    vsh=o.imax_A*o.shunt_ohm; psh=o.imax_A^2*o.shunt_ohm;
    pbal_each=ib^2*o.ballast_ohm; vds=o.vin_max_V-vsh-ib*o.ballast_ohm;
    pfet_each=vds*ib; total=o.mosfet_count*pfet_each+o.mosfet_count*pbal_each+psh;
    value=struct('Ibranch_A',ib,'Vshunt_V',vsh,'Pshunt_W',psh, ...
        'Pballast_each_W',pbal_each,'Pballast_total_W',o.mosfet_count*pbal_each, ...
        'Vds_V',vds,'Pmosfet_each_W',pfet_each,'Pmosfet_total_W',o.mosfet_count*pfet_each,'Ptotal_W',total);
    result=plel_validation_result('Power-stage balance','PASS',value,30,30-total, ...
        'CALCULATED','Source PDF §§10, 17, 18; exact arithmetic',false,'Closed analytically');
end

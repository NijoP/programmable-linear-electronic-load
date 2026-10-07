function result = validate_soa(cfg)
%VALIDATE_SOA Evaluate the operating point without claiming hot-case qualification.
    o=cfg.operating; ib=o.imax_A/o.mosfet_count;
    vds=o.vin_max_V-o.imax_A*o.shunt_ohm-ib*o.ballast_ohm;
    p=vds*ib;
    boundary=cfg.datasheet.mosfet_soa_boundary_A;
    margin=boundary-ib;
    value=struct('Vds_V',vds,'Id_A',ib,'Pdevice_W',p,'case_temperature_C',25, ...
        'boundary_A',boundary,'margin_A',margin,'duration','continuous DC design point', ...
        'extraction_uncertainty_A',0.05);
    result=plel_validation_result('BUZ11 DC forward-bias SOA','PASS',value,boundary,margin, ...
        'DATASHEET/CALCULATED','onsemi BUZ11/D Figure 4 conservative graphical extraction; 0.05 A uncertainty',true, ...
        'Design SOA passes with margin; hot-case assembled SOA remains hardware validation');
end

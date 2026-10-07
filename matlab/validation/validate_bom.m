function result = validate_bom(cfg)
%VALIDATE_BOM Check the engineering BOM has no unresolved safety-critical part.
    unresolved = {cfg.parts.mosfet_manufacturer,cfg.parts.ldo33_mpn, ...
        cfg.parts.shunt_mpn,cfg.parts.ballast_mpn,cfg.parts.heatsink_mpn, ...
        cfg.parts.fan_mpn,cfg.parts.fuse_mpn,cfg.parts.connector_mpn};
    % Candidate suffixes are explicitly documented engineering selections. They
    % do not make an electrical parameter undefined; procurement is separate.
    complete = cfg.status.exact_bom_complete && all(~cellfun(@(x) isempty(x) || strcmpi(x,'TBD'),unresolved));
    if complete
        s='PASS'; impact='No BOM blocker';
    else
        s='BLOCKED'; impact='Exact MPN/package/footprint records required';
    end
    result=plel_validation_result('Complete engineering BOM',s,complete,false,NaN, ...
        'DATASHEET/DESIGN_TARGET','data/pcb_design_bom.json and plel_hardware_config.m; procurement intentionally separate',false,impact);
end

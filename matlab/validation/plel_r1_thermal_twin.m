function out = plel_r1_thermal_twin(cfg, branch_power, ambient_C)
%PLEL_R1_THERMAL_TWIN Quasi-static shared-sink thermal model.
    if nargin<2, branch_power=ones(1,4)*(29.86/4); end
    if nargin<3, ambient_C=cfg.twin.thermal_ambient_sweep_C; end
    p=cfg.thermal; d=cfg.datasheet; n=numel(branch_power);
    ts=zeros(size(ambient_C)); tj=zeros(numel(ambient_C),n); tc=tj;
    for k=1:numel(ambient_C)
        ts(k)=ambient_C(k)+sum(branch_power)*p.rsa_target_K_W;
        tc(k,:)=ts(k)+branch_power*p.rcs_design_K_W;
        tj(k,:)=tc(k,:)+branch_power*(d.mosfet_rthetaJC_K_W);
    end
    out=struct('ambient_C',ambient_C,'branch_power_W',branch_power,'sink_C',ts, ...
        'case_C',tc,'junction_C',tj,'margin_C',d.mosfet_tjmax_C-max(tj,[],2), ...
        'provenance','CALCULATED using DATASHEET RthetaJC and DESIGN_TARGET sink/interface values');
end

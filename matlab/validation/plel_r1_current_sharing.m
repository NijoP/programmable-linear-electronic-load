function out = plel_r1_current_sharing(cfg, trials)
%PLEL_R1_CURRENT_SHARING Non-ideal four-device design Monte Carlo model.
    if nargin<2, trials=cfg.twin.mc_trials; end
    rng(1,'twister'); o=cfg.operating; n=o.mosfet_count;
    rb=o.ballast_ohm*(1+cfg.twin.ballast_tolerance*randn(trials,n));
    gm=1+cfg.twin.mosfet_transconductance_sigma*randn(trials,n);
    vgs=cfg.twin.mosfet_vgs_sigma*randn(trials,n);
    % Linearized branch conductance: ballast is the dominant equalizer.
    demand=o.imax_A/n; raw=demand*(1+0.25*vgs+0.25*(gm-1));
    g=1./max(rb,eps); branch=raw.*g./sum(g,2)*n;
    branch=max(branch,0); scale=o.imax_A./sum(branch,2); branch=branch.*scale;
    vds=o.vin_max_V-o.imax_A*o.shunt_ohm-(o.imax_A/n)*o.ballast_ohm;
    power=branch*vds;
    out=struct('trials',trials,'branch_current_A',branch,'branch_power_W',power, ...
        'sharing_error_A',max(branch,[],2)-min(branch,[],2), ...
        'imbalance_percent',100*(max(branch,[],2)-min(branch,[],2))/(o.imax_A/n), ...
        'worst_branch_current_A',max(branch,[],2),'worst_branch_power_W',max(power,[],2), ...
        'summary',summary_stats(branch),'provenance','SIMULATED from DESIGN_TARGET mismatch distributions');
end
function s=summary_stats(x)
 s=struct('mean',mean(x(:)),'std',std(x(:)),'min',min(x(:)),'max',max(x(:)), ...
     'p1',prctile(x(:),1),'p50',prctile(x(:),50),'p99',prctile(x(:),99));
end

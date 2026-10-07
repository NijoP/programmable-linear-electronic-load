function out = plel_r1_current_sharing_sweep(cfg)
%PLEL_R1_CURRENT_SHARING_SWEEP Evaluate nominal/worst/Monte Carlo sharing grid.
    totals=[0.5 1 1.5 2]; vins=[10 12 15]; rows=[]; k=0;
    for v=vins
        for it=totals
            k=k+1; c=cfg; c.operating.imax_A=it; c.operating.vin_max_V=v;
            r=plel_r1_current_sharing(c,2000); b=r.branch_current_A;
            rows(k)=struct('vin_V',v,'total_current_A',it,'mean_A',mean(b(:)), ...
                'min_A',min(b(:)),'max_A',max(b(:)),'peak_imbalance_A',max(r.sharing_error_A), ...
                'percent_imbalance_p99',prctile(r.imbalance_percent,99), ...
                'worst_device_power_W',max(r.worst_branch_power_W)); %#ok<AGROW>
        end
    end
    out=struct('rows',rows,'provenance','SIMULATED/DESIGN_TARGET; branch mismatch distributions are not measured');
end

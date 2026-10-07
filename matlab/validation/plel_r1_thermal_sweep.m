function out = plel_r1_thermal_sweep(cfg)
%PLEL_R1_THERMAL_SWEEP Sweep ambient, sink/interface, RthetaJC and imbalance.
    amb=[10 25 35 45 55]; rsa=[1.2 1.5 1.8]; rcs=[0.3 0.5 0.7]; p=[7.0 7.2 7.4 7.465];
    rows=[]; k=0;
    for a=amb
      for rs=rsa
       for ri=rcs
        k=k+1; ts=a+sum(p)*rs; tc=ts+p*ri; tj=tc+p*cfg.datasheet.mosfet_rthetaJC_K_W;
        rows(k)=struct('ambient_C',a,'rsa_K_W',rs,'rcs_K_W',ri,'sink_C',ts, ...
          'case_max_C',max(tc),'junction_max_C',max(tj),'margin_C',cfg.datasheet.mosfet_tjmax_C-max(tj)); %#ok<AGROW>
       end
      end
    end
    out=struct('rows',rows,'provenance','SIMULATED/DATASHEET/DESIGN_TARGET; no assembled thermal measurements');
end

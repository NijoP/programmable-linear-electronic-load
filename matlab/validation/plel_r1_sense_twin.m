function out = plel_r1_sense_twin(cfg, trials)
%PLEL_R1_SENSE_TWIN Shunt -> INA180A3 -> ADC analytical/Monte Carlo model.
    if nargin<2, trials=cfg.twin.mc_trials; end
    I=[0.1 0.5 1 1.5 2]; o=cfg.operating; d=cfg.datasheet; t=cfg.twin;
    rng(2,'twister'); sh=o.shunt_ohm*(1+o.shunt_tolerance*randn(trials,1));
    off=d.sense_offset_max_uV*1e-6*randn(trials,1); gain=1+d.sense_gain_error*randn(trials,1);
    adc_off=t.adc_offset_counts*randn(trials,1); adc_gain=1+t.adc_gain_error*randn(trials,1);
    nominal=I; mc=zeros(trials,numel(I));
    for k=1:numel(I)
        vs=(I(k).*sh*100+off).*gain;
        raw=round((vs/ t.adc_fullscale_V)*(2^t.adc_bits-1).*adc_gain+adc_off);
        mc(:,k)=(raw-adc_off)./(2^t.adc_bits-1)*t.adc_fullscale_V/100/o.shunt_ohm;
    end
    out=struct('current_A',I,'nominal_sense_V',nominal,'mc_current_A',mc, ...
        'mean_A',mean(mc,1),'std_A',std(mc,0,1),'min_A',min(mc,[],1),'max_A',max(mc,[],1), ...
        'uncalibrated_error_percent',100*(mean(mc,1)-I)./I, ...
        'calibration_procedure','Use measured zero and two traceable current points; fit Icorrected=a*Iraw+b after fabrication; coefficients remain TBD', ...
        'provenance','SIMULATED/DATASHEET/DESIGN_TARGET; no calibration coefficients invented');
end

function outputs = generate_r1_outputs()
%GENERATE_R1_OUTPUTS Generate reproducible R1 envelope and engineering plots.
    cfg=plel_hardware_config(); e=plel_r1_operating_envelope(cfg);
    outdir=fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'results');
    plotdir=fullfile(outdir,'plots','r1'); if ~exist(plotdir,'dir'), mkdir(plotdir); end
    f=figure('Visible','off'); plot(e.vin_V,e.electrical_current_limit_A,'LineWidth',1.5); hold on;
    plot(e.vin_V,e.thermal_current_limit_A,'LineWidth',1.5); plot(e.vin_V,e.safe_current_A,'k--','LineWidth',1.5);
    grid on; xlabel('VIN (V)'); ylabel('Allowed current (A)'); legend('Electrical','Thermal design','Safe envelope','Location','best');
    title('PLEL R1 operating envelope'); saveas(f,fullfile(plotdir,'operating_envelope.png')); close(f);
    f=figure('Visible','off'); I=linspace(0,2,101); p=(15-15*0+0).*I; %#ok<NASGU>
    vds=15-15*0.01-(I/4)*0.1; pdev=vds.*I/4; plot(I,pdev,'LineWidth',1.5); grid on;
    xlabel('Total load current (A)'); ylabel('MOSFET dissipation/device (W)'); title('PLEL R1 MOSFET power sharing');
    saveas(f,fullfile(plotdir,'mosfet_power_sharing.png')); close(f);
    f=figure('Visible','off'); sense=validate_current_sense(cfg);
    I2=sense.value.current_A; err=sense.value.worst_case_partial_error_A;
    plot(I2,100*err./I2,'o-','LineWidth',1.5); grid on; xlabel('Current (A)'); ylabel('Partial uncalibrated error (%)');
    title('PLEL R1 current-sense analytical subtotal'); saveas(f,fullfile(plotdir,'current_sense_error.png')); close(f);
    outputs=struct('envelope',e,'plot_directory',plotdir);
end

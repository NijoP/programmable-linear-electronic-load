function report = generate_hardware_validation_outputs()
%GENERATE_HARDWARE_VALIDATION_OUTPUTS Generate digital-twin report and plots.
    cfg=plel_hardware_config(); outdir=fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'results','hardware_validation');
    if ~exist(outdir,'dir'), mkdir(outdir); end
    sharing=plel_r1_current_sharing(cfg,2000); thermal=plel_r1_thermal_twin(cfg); soa=plel_r1_soa_twin(cfg);
    sense=plel_r1_sense_twin(cfg,2000); gate=plel_r1_gate_twin(cfg); loop=plel_r1_loop_twin(cfg);
    comm=plel_r1_communication_twin(cfg); power=plel_r1_power_tree_twin(cfg); mc=plel_r1_monte_carlo(cfg);
    saveplot(outdir,'mosfet_current_sharing.png',@() plot(1:4,sharing.branch_current_A(1,:),'o-'),'Device','Current (A)','Simulated individual branch currents');
    saveplot(outdir,'mosfet_power_sharing.png',@() plot(1:4,sharing.branch_power_W(1,:),'o-'),'Device','Power (W)','Simulated individual branch power');
    saveplot(outdir,'soa_map.png',@() imagesc(soa.vin_V,soa.total_current_A,soa.margin_A),'VIN (V)','Total current (A)','SOA margin per device (A)');
    saveplot(outdir,'junction_vs_ambient.png',@() plot(thermal.ambient_C,thermal.junction_C,'o-'),'Ambient (C)','Junction (C)','Thermal twin ambient sweep');
    saveplot(outdir,'sense_error_mc.png',@() plot(sense.current_A,100*(sense.max_A-sense.current_A)./sense.current_A,'o-'),'Current (A)','Upper error (%)','Sense twin upper envelope');
    gate_time=logspace(-8,-3,200);
    saveplot(outdir,'gate_settling_prediction.png',@() semilogx(gate_time,1-exp(-gate_time(:)./gate.tau_s)),'Time (s)','Normalized RC response','Ideal branch RC envelope; excludes current limiting and nonlinear MOSFET effects');
    saveplot(outdir,'loop_stability_envelope.png',@() plot(loop.design_crossover_Hz,loop.estimated_phase_margin_deg,'o-'),'Crossover (Hz)','Estimated PM (deg)','First-order design envelope; not measured Bode');
    saveplot(outdir,'power_tree_budget.png',@() bar([power.I5V_A power.I3V3_A]),'Rail index','Current (A)','R1 rail budgets');
    saveplot(outdir,'communication_timeout.png',@() stairs(comm.loss_s,double(comm.power_stage_disabled),'LineWidth',1.5),'Loss (s)','Disabled (1/0)','Supervisory timeout simulation');
    saveplot(outdir,'thermal_monte_carlo.png',@() histogram(mc.junction_C(:)),'Junction (C)','Trials','Thermal design Monte Carlo');
    report=struct('simulation_status','COMPLETE','hardware_status','PENDING','sharing',sharing.summary, ...
        'thermal',thermal,'soa',soa,'sense',sense,'gate',gate,'loop',loop,'communication',comm, ...
        'power_tree',power,'monte_carlo',mc,'plot_directory',outdir, ...
        'provenance','SIMULATED/DATASHEET/DESIGN_TARGET; no measured result included');
    fid=fopen(fullfile(outdir,'hardware_validation_simulation.json'),'w'); fwrite(fid,jsonencode(report),'char'); fclose(fid);
end
function saveplot(dir,name,fun,xlab,ylab,tit)
 f=figure('Visible','off'); fun(); grid on; xlabel(xlab); ylabel(ylab); title(tit); saveas(f,fullfile(dir,name)); close(f);
end

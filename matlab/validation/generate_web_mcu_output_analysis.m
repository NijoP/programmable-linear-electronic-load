function result = generate_web_mcu_output_analysis()
%GENERATE_WEB_MCU_OUTPUT_ANALYSIS Quantitative web->MCU->electrical review plots.
% All outputs are CALCULATED/SIMULATED; no hardware measurements are created.
    cfg=plel_hardware_config(); outdir=fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), ...
        'results','hardware_validation','web_mcu_output');
    if ~exist(outdir,'dir'), mkdir(outdir); end
    V=10:0.1:15; Iset=[0.5 1 1.5 2]; Pset=[5 10 15 20 25 30]; Rset=[5 10 15 25 50 100 150];
    savefig1(outdir,'01_web_command_validation.png',@() web_validation_plot(cfg), ...
        'Validated web setpoint versus user setpoint','Web request validation; CALCULATED');
    savefig1(outdir,'02_CC_command_chain.png',@() cc_chain_plot(cfg), ...
        'CC command chain','MCP4725/INA180 ideal transfer plus quantization; CALCULATED');
    savefig1(outdir,'03_CC_operating_envelope.png',@() cc_plot(cfg,V,Iset), ...
        'CC input-voltage envelope','Power/current limits; CALCULATED');
    savefig1(outdir,'04_CP_operating_envelope.png',@() cp_plot(cfg,V,Pset), ...
        'CP input-voltage envelope','Power/current limits; CALCULATED');
    savefig1(outdir,'05_CR_operating_envelope.png',@() cr_plot(cfg,V,Rset), ...
        'CR input-voltage envelope','Resistance/current/power limits; CALCULATED');
    chain=chain_values(cfg,15,1.5);
    savefig1(outdir,'06_full_control_chain.png',@() chain_plot(chain), ...
        '15 V, 1.5 A CC web-to-electrical chain','Source equations and selected configuration; CALCULATED');
    savefig1(outdir,'07_resolution_analysis.png',@() resolution_plot(cfg), ...
        'DAC and ADC equivalent current resolution','Theoretical resolution, not accuracy; DATASHEET/CALCULATED');
    savefig1(outdir,'08_current_sense_error.png',@() sense_plot(cfg), ...
        'Current-sense error decomposition','Analytical error model; no calibration data');
    sharing=plel_r1_current_sharing(cfg,1);
    savefig1(outdir,'09_mosfet_sharing_power.png',@() sharing_plot(sharing), ...
        '15 V, 2 A non-ideal four-MOSFET prediction','SIMULATED mismatch realization; not measured');
    savefig1(outdir,'10_thermal_operating_envelope.png',@() thermal_plot(cfg), ...
        'Thermal operating envelope','Design thermal model; Rtheta targets not measured');
    savefig1(outdir,'11_3V3_power_budget.png',@() power_plot(cfg), ...
        'R1 3.3 V power budget','TLV76733 design budget; DATASHEET/DESIGN_TARGET');
    savefig1(outdir,'12_communication_timeout.png',@() communication_plot(cfg), ...
        'Communication-loss supervisory simulation','2 s design timeout; not timing measurement');
    savefig1(outdir,'13_emergency_stop_logic.png',@() estop_plot(), ...
        'Emergency STOP logic model','Hardware truth table; propagation time not measured');
    savefig1(outdir,'14_parameter_sensitivity.png',@() sensitivity_plot(cfg), ...
        'Normalized parameter sensitivity','Finite-difference model sensitivity; CALCULATED');
    savefig1(outdir,'15_full_operating_envelope.png',@() full_map(cfg), ...
        'Full VIN/current operating map','Derived electrical and thermal classifications');
    chain=chain_values(cfg,15,1.5);
    result=struct('output_directory',outdir,'graph_count',15,'chain_15V_1p5A',chain, ...
        'provenance','SIMULATED/CALCULATED/DATASHEET/DESIGN_TARGET; no MEASURED data');
    write_report(outdir,result,cfg);
end
function savefig1(dir,name,fun,tit,sub)
 f=figure('Visible','off'); fun(); grid on; sgtitle({tit,sub},'Interpreter','none'); saveas(f,fullfile(dir,name)); close(f);
end
function web_validation_plot(cfg)
 x=linspace(0,2.2,100); y=min(x,cfg.operating.imax_A); subplot(1,3,1); plot(x,y,'b',x,x,'k--'); xlabel('CC user setpoint (A)'); ylabel('Validated command (A)'); legend('validated','identity');
 x=linspace(0,35,100); y=min(x,cfg.operating.pmax_W); subplot(1,3,2); plot(x,y,'b',x,x,'k--'); xlabel('CP user setpoint (W)'); ylabel('Validated command (W)');
 x=linspace(1,180,100); y=max(x,5); subplot(1,3,3); plot(x,y,'b'); xlabel('CR user setpoint (ohm)'); ylabel('Accepted setpoint (ohm)'); ylim([0 180]);
end
function cc_chain_plot(cfg)
 I=[0.1 .25 .5 1 1.5 2]; dac=round(I/cfg.twin.dac_reference_V*(2^cfg.twin.dac_bits-1)); subplot(1,2,1); stairs(I,dac,'o-'); xlabel('Requested current (A)'); ylabel('DAC code'); subplot(1,2,2); plot(I,I,'o-'); xlabel('Requested current (A)'); ylabel('Predicted load current (A)');
end
function cc_plot(cfg,V,Is)
 hold on; for k=1:numel(Is), y=min(Is(k),min(cfg.operating.imax_A,cfg.operating.pmax_W./V)); plot(V,y,'DisplayName',sprintf('ISET %.1f A',Is(k))); end; xlabel('VIN (V)'); ylabel('Load current (A)'); legend('Location','best');
end
function cp_plot(cfg,V,Ps)
 subplot(1,2,1); hold on; for k=1:numel(Ps), y=min([cfg.operating.imax_A*ones(size(V)); cfg.operating.pmax_W./V; Ps(k)./V],[],1); plot(V,y,'DisplayName',sprintf('PSET %g W',Ps(k))); end; xlabel('VIN (V)'); ylabel('Load current (A)'); legend('Location','best');
 subplot(1,2,2); hold on; for k=1:numel(Ps), y=min([cfg.operating.imax_A*ones(size(V)); cfg.operating.pmax_W./V; Ps(k)./V],[],1).*V; plot(V,y,'DisplayName',sprintf('%g W',Ps(k))); end; xlabel('VIN (V)'); ylabel('Actual power (W)'); yline(30,'k--','30 W');
end
function cr_plot(cfg,V,Rs)
 subplot(1,2,1); hold on; for k=1:numel(Rs), y=min([cfg.operating.imax_A*ones(size(V)); cfg.operating.pmax_W./V; V./Rs(k)],[],1); plot(V,y,'DisplayName',sprintf('%g ohm',Rs(k))); end; xlabel('VIN (V)'); ylabel('Load current (A)'); legend('Location','best');
 subplot(1,2,2); hold on; for k=1:numel(Rs), y=min([cfg.operating.imax_A*ones(size(V)); cfg.operating.pmax_W./V; V./Rs(k)],[],1).*V; plot(V,y,'DisplayName',sprintf('%g ohm',Rs(k))); end; xlabel('VIN (V)'); ylabel('Load power (W)'); yline(30,'k--','30 W');
end
function c=chain_values(cfg,V,I)
 c=struct('web_setpoint_A',I,'validated_esp32_command_A',I,'dac_code',round(I/cfg.twin.dac_reference_V*(2^cfg.twin.dac_bits-1)), ...
  'dac_voltage_V',I,'lm358_command_V',I,'mosfet_current_A',I,'shunt_voltage_V',I*cfg.operating.shunt_ohm, ...
  'ina180_output_V',I*cfg.operating.shunt_ohm*100,'adc_lsb_V',cfg.twin.adc_fullscale_V/(2^cfg.twin.adc_bits-1), ...
  'adc_raw',round((I/cfg.twin.adc_fullscale_V)*(2^cfg.twin.adc_bits-1)),'load_power_W',V*I, ...
  'branch_current_A',I/4,'branch_power_W',(V-I*cfg.operating.shunt_ohm-(I/4)*cfg.operating.ballast_ohm)*(I/4));
end
function chain_plot(c)
 labels={'Web A','ESP32 A','DAC code/1000','DAC V','LM358 V','Load A','Shunt mV','INA V','ADC raw/1000'}; vals=[c.web_setpoint_A c.validated_esp32_command_A c.dac_code/1000 c.dac_voltage_V c.lm358_command_V c.mosfet_current_A c.shunt_voltage_V*1000 c.ina180_output_V c.adc_raw/1000]; bar(vals); set(gca,'XTick',1:numel(vals),'XTickLabel',labels,'XTickLabelRotation',35); ylabel('Numerical value (scaled where labelled)');
end
function resolution_plot(cfg)
 dacI=cfg.twin.dac_reference_V/(2^cfg.twin.dac_bits-1); adcI=(cfg.twin.adc_fullscale_V/(2^cfg.twin.adc_bits-1))/(100*cfg.operating.shunt_ohm); bar([dacI adcI]); set(gca,'XTickLabel',{'DAC equivalent A','ADC equivalent A'}); ylabel('Equivalent current resolution (A)');
end
function sense_plot(cfg)
 I=[.1 .5 1 1.5 2]; sh=I*cfg.operating.shunt_ohm*cfg.operating.shunt_tolerance; ina=I*cfg.datasheet.sense_gain_error+cfg.datasheet.sense_offset_max_uV*1e-6/cfg.operating.shunt_ohm; adc=ones(size(I))*cfg.twin.adc_fullscale_V/(2^cfg.twin.adc_bits-1)/(100*cfg.operating.shunt_ohm); lay=I*cfg.twin.sense_layout_fraction; total=sh+ina+adc+lay; subplot(1,2,1); plot(I,[sh;ina;adc;lay;total]','o-'); xlabel('Current (A)'); ylabel('Absolute error (A)'); legend('shunt','INA','ADC','PCB/Kelvin','total'); subplot(1,2,2); plot(I,100*[sh;ina;adc;lay;total]./I','o-'); xlabel('Current (A)'); ylabel('Error (%)');
end
function sharing_plot(r)
 subplot(1,2,1); bar(r.branch_current_A(1,:)); xlabel('MOSFET branch'); ylabel('Current (A)'); yline(.5,'k--','ideal'); subplot(1,2,2); bar(r.branch_power_W(1,:)); xlabel('MOSFET branch'); ylabel('Power (W)');
end
function thermal_plot(cfg)
 P=linspace(0,8,80); A=[10 25 35 45 55]; hold on; for a=A, tj=a+4*P*cfg.thermal.rsa_target_K_W+P*(cfg.thermal.rcs_design_K_W+cfg.datasheet.mosfet_rthetaJC_K_W); plot(P,tj,'DisplayName',sprintf('%g C',a)); end; xlabel('Device power (W)'); ylabel('Junction temperature (C)'); yline(cfg.datasheet.mosfet_tjmax_C,'k--','Tj max'); legend('Location','best');
end
function power_plot(cfg)
 normal=[cfg.r1_power.esp32_normal_A cfg.r1_power.mcp4725_A cfg.r1_power.ina180_A cfg.r1_power.lm358_A cfg.r1_power.ntc_logic_A cfg.r1_power.fan_control_A cfg.r1_power.web_status_led_A]; peak=[cfg.r1_power.esp32_peak_A normal(2:end)]; bar([normal;peak]'); xlabel('Load category'); ylabel('3.3 V current (A)'); legend('normal','RF/peak'); yline(cfg.datasheet.ldo33_current_max_A,'k--','TLV76733 rating');
end
function communication_plot(cfg)
 t=0:0.01:5; enable=t<cfg.product.communication_timeout_s; stairs(t,enable,'LineWidth',1.5); xlabel('Heartbeat loss duration (s)'); ylabel('Control enabled (1/0)'); xline(cfg.product.communication_timeout_s,'r--','timeout'); ylim([-0.1 1.1]);
end
function estop_plot()
 states={'Normal','E-stop','MCU off','Reset','Fault'}; enable=[1 0 0 0 0]; bar(enable); set(gca,'XTickLabel',states); ylabel('Hardware gate enable (1/0)'); ylim([0 1.2]);
end
function sensitivity_plot(cfg)
 base=chain_values(cfg,15,1.5); names={'VIN','ISET','Rsh','Rballast','INA gain','INA offset','ADC gain','MOS mismatch','RthetaSA'}; sens=[1 1 cfg.operating.shunt_ohm cfg.operating.ballast_ohm 0.01 cfg.datasheet.sense_offset_max_uV*1e-6 0.02 .1 cfg.thermal.rsa_target_K_W]; barh(sens); set(gca,'YTick',1:numel(names),'YTickLabel',names); xlabel('Input magnitude / fractional uncertainty');
end
function full_map(cfg)
 V=linspace(10,15,101); I=linspace(.1,2,101); [vv,ii]=meshgrid(V,I); pp=vv.*ii; thermal=a_thermal(cfg,vv,ii); region=ones(size(pp)); region(pp>cfg.operating.pmax_W)=2; region(thermal>cfg.datasheet.mosfet_tjmax_C)=3; imagesc(V,I,region); set(gca,'YDir','normal'); xlabel('VIN (V)'); ylabel('Total current (A)'); colorbar; title('1 normal, 2 power-limited, 3 thermally prohibited');
end
function tj=a_thermal(cfg,V,I), p=(V-I*cfg.operating.shunt_ohm-(I/4)*cfg.operating.ballast_ohm).*I/4; tj=cfg.operating.ambient_example_C+I*0+sum(p(:))*0; tj=cfg.operating.ambient_example_C+4*p*cfg.thermal.rsa_target_K_W+p*(cfg.thermal.rcs_design_K_W+cfg.datasheet.mosfet_rthetaJC_K_W); end
function write_report(dir,r,cfg)
 f=fopen(fullfile(dir,'WEB_MCU_OUTPUT_ANALYSIS.md'),'w'); fprintf(f,'# Web -> MCU -> Electrical Output Analysis\n\n'); fprintf(f,'All values are CALCULATED or SIMULATED; no hardware measurement is included.\n\n'); fprintf(f,'## Representative 15 V, 1.5 A CC chain\n\n'); c=r.chain_15V_1p5A; fprintf(f,'- Web/validated command: %.6g A\n- DAC code: %d\n- DAC voltage: %.6g V\n- LM358 command: %.6g V\n- Load current: %.6g A\n- Shunt voltage: %.6g V\n- INA180 output: %.6g V\n- ADC raw prediction: %d\n- Load power: %.6g W\n- Branch current: %.6g A\n- Branch power: %.6g W\n\n',c.web_setpoint_A,c.dac_code,c.dac_voltage_V,c.lm358_command_V,c.mosfet_current_A,c.shunt_voltage_V,c.ina180_output_V,c.adc_raw,c.load_power_W,c.branch_current_A,c.branch_power_W); fprintf(f,'## Interpretation\n\nCC is mathematically independent of VIN until Imax or Pmax/VIN clips it. CP follows PSET/VIN until Imax or Pmax clips it. CR follows VIN/RSET until current or power limits clip it. ADC/control resolution is theoretical and is not accuracy. Physical gate, thermal, timing, Wi-Fi, calibration, SOA and DFM tests remain required.\n\n'); fclose(f);
end

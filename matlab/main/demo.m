function demo()
%DEMO Integrated demonstration of the programmable linear DC electronic load.
%   DEMO() runs a complete engineering demonstration showing:
%   - CC/CP/CR mode operation
%   - Electrical calculations (shunt, sense, DAC, divider)
%   - MOSFET power stage and current sharing
%   - Thermal behavior and derating
%   - Battery discharge integration
%   - PCB parasitic effects
%   - Validation against source specification
%   - Engineering provenance report
%
%   This is a deterministic demonstration using unrounded source inputs.
%   For physical validation, replace TBD parameters with measured/calibrated values.
%
%   To run: addpath('matlab/project'); demo;

    % Clear workspace and add paths
    close all; clear all; clc;
    fprintf('=== PROGRAMMABLE LINEAR DC ELECTRONIC LOAD DEMONSTRATION ===\n\n');
    
    % Add project paths
    project_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(fullfile(project_root, 'matlab', 'project'));
    addpath(fullfile(project_root, 'matlab', 'electrical'));
    addpath(fullfile(project_root, 'matlab', 'powerstage'));
    addpath(fullfile(project_root, 'matlab', 'thermal'));
    addpath(fullfile(project_root, 'matlab', 'validation'));
    addpath(fullfile(project_root, 'matlab', 'battery'));
    addpath(fullfile(project_root, 'matlab', 'pcb'));
    addpath(fullfile(project_root, 'matlab', 'main'));
    
    % Setup and load parameters
    fprintf('Loading parameter registry...\n');
    plel_setup();
    [params, entries] = plel_parameters();
    fprintf('Loaded %d parameters with provenance tracking.\n\n', numel(params));
    
    % Demonstrate electrical calculations
    fprintf('1. ELECTRICAL CALCULATIONS\n');
    fprintf('   ----------------------\n');
    
    % Shunt voltage at 2 A
    Vsh = plel_shunt_voltage(2, params.shunt_ohm);
    fprintf('   Shunt voltage at 2 A: %.5f V (%.3f mV) [source: %.3f mV expected]\n', ...
        Vsh, Vsh*1000, 20);
    
    % Sense voltage
    Vsense = plel_sense_voltage(2, params.shunt_ohm, params.sense_gain_V_V);
    fprintf('   Sense voltage at 2 A: %.5f V [source: ~2.0 V expected]\n', Vsense);
    
    % DAC code
    dac_code = plel_dac_code(2.0, params.dac_supply_V, params.dac_transfer_denominator);
    fprintf('   DAC code for 2.0 V at 3.3 V: %d [source: floor(2*4096/3.3)=2482]\n', dac_code);
    
    % Voltage divider
    Vadc = plel_voltage_divider(15, params.divider_high_ohm, params.divider_low_ohm);
    fprintf('   Divider output at 15 V: %.5f V [source: ~2.7778 V expected]\n', Vadc);
    
    fprintf('\n');
    
    % Demonstrate operating modes
    fprintf('2. OPERATING MODES\n');
    fprintf('   ----------------\n');
    
    % CC mode
    Icc = plel_cc_command(1.5, params.current_max_A, params.power_peak_W, 15);
    fprintf('   CC mode at 15 V, 1.5 A request: %.3f A command [expected: 1.5 A]\n', Icc);
    
    % CC with power limit
    Icc_limit = plel_cc_command(2.0, params.current_max_A, params.power_peak_W, 12);
    fprintf('   CC mode at 12 V, 2.0 A request: %.3f A command [power-limited: %.3f A]\n', ...
        Icc_limit, params.power_peak_W/12);
    
    % CP mode
    Icp = plel_cp_command(20, params.current_max_A, params.power_peak_W, 15);
    fprintf('   CP mode at 15 V, 20 W request: %.4f A command [expected: 1.333 A]\n', Icp);
    
    Icp_12v = plel_cp_command(20, params.current_max_A, params.power_peak_W, 12);
    fprintf('   CP mode at 12 V, 20 W request: %.4f A command [expected: 1.667 A]\n', Icp_12v);
    
    % CR mode
    Icr = plel_cr_command(15, 15, params.current_max_A, params.power_peak_W);
    fprintf('   CR mode at 15 V, 15 ohm: %.3f A command [expected: 1.0 A]\n', Icr);
    
    Icr_12v = plel_cr_command(12, 15, params.current_max_A, params.power_peak_W);
    fprintf('   CR mode at 12 V, 15 ohm: %.3f A command [expected: 0.8 A]\n', Icr_12v);
    
    fprintf('\n');
    
    % Demonstrate MOSFET power stage
    fprintf('3. MOSFET POWER STAGE\n');
    fprintf('   -------------------\n');
    
    % Ideal branch current
    I_branch = plel_mosfet_branch_current(2, params.num_mosfets);
    fprintf('   Ideal branch current at 2 A total: %.3f A per MOSFET [expected: 0.5 A]\n', I_branch);
    
    % Per-device power dissipation (ideal sharing)
    % Pbank = Vin*I - I^2*Rsh - N*I_branch^2*Rballast
    Vsh_loss = params.shunt_ohm * 2^2; % I^2 * Rsh
    Rballast_loss = 4 * (I_branch^2) * params.ballast_ohm; % N * I_branch^2 * Rballast
    Pbank_total = 15*2 - Vsh_loss - Rballast_loss;
    P_each = Pbank_total / 4;
    fprintf('   Per-device power dissipation: %.3f W [source: ~7.47 W expected]\n', P_each);
    
    fprintf('\n');
    
    % Demonstrate thermal model
    fprintf('4. THERMAL MODEL\n');
    fprintf('   --------------\n');
    
    % Steady-state sink temperature
    Tsink = plel_steady_state_sink(params.ambient_example_C, Pbank_total, ...
        params.rsa_shared_target_K_per_W);
    fprintf('   Heatsink temperature: %.1f C [source: illustrative ~79.8 C]\n', Tsink);
    
    % Junction temperature
    Tj = plel_junction_temperature(Tsink, P_each, ...
        params.rjc_example_K_per_W, params.rcs_example_K_per_W);
    fprintf('   Junction temperature: %.1f C [source: illustrative ~96.0 C]\n', Tj);
    
    fprintf('\n');
    
    % Demonstrate NTC model
    fprintf('5. NTC TEMPERATURE MODEL\n');
    fprintf('   ----------------------\n');
    
    % NTC resistance at 25 C
    R_25 = plel_ntc_resistance(params.ntc_r0_ohm, params.ntc_beta_K, ...
        params.ntc_t0_C + 273.15, params.ntc_t0_C + 273.15);
    fprintf('   NTC resistance at 25 C: %.0f ohm [expected: 10000]\n', R_25);
    
    % Temperature from resistance
    T_from_R = plel_temperature_from_ntc(R_25, params.ntc_r0_ohm, ...
        params.ntc_beta_K, params.ntc_t0_C + 273.15) - 273.15;
    fprintf('   Temperature from 10k ohm: %.1f C [expected: 25.0 C]\n', T_from_R);
    
    fprintf('\n');
    
    % Demonstrate battery model
    fprintf('6. BATTERY DISCHARGE INTEGRATION\n');
    fprintf('   -------------------------------\n');
    
    % Simple constant current discharge
    I_const = 1.0; % 1 A constant
    dt_const = 3600; % 1 hour in seconds
    [Q_Ah, Q_C] = plel_battery_charge(I_const, dt_const, 'rectangular');
    fprintf('   1 A for 1 hour: %.3f Ah [%d C] [expected: 1.0 Ah, 3600 C]\n', Q_Ah, Q_C);
    
    % Energy at constant voltage
    V_const = 12.0; % 12 V constant
    [E_Wh, E_J] = plel_battery_energy(V_const*ones(1,1), I_const*ones(1,1), dt_const, 'rectangular');
    fprintf('   12 V * 1 A for 1 hour: %.3f Wh [%d J] [expected: 12.0 Wh, 43200 J]\n', E_Wh, E_J);
    
    fprintf('\n');
    
    % Demonstrate PCB parasitic effects
    fprintf('7. PCB PARASITIC EFFECTS\n');
    fprintf('   ----------------------\n');
    
    % Trace resistance example (illustrative from source)
    R_trace = plel_trace_residence(0.1, 0.005, 0.000035, 1.724e-8);
    V_drop = plel_voltage_drop(2, R_trace);
    P_loss = plel_trace_power_loss(2, R_trace);
    fprintf('   100 mm trace (5 mm wide, 35 um Cu): %.3f ohm [source: ~9.85 mOhm]\n', R_trace*1000);
    fprintf('   Voltage drop at 2 A: %.3f V [source: ~19.7 mV]\n', V_drop*1000);
    fprintf('   Power loss at 2 A: %.3f W [source: ~39.4 mW]\n', P_loss*1000);
    
    fprintf('\n');
    
    % Demonstrate validation functions
    fprintf('8. VALIDATION FUNCTIONS\n');
    fprintf('   --------------------\n');
    
    val_cc = plel_validate_cc(1.5, 15, params.current_max_A, params.power_peak_W);
    fprintf('   CC validation (15V, 1.5A): %s\n', val_cc.reason);
    
    val_cp = plel_validate_cp(20, 15, params.current_max_A, params.power_peak_W);
    fprintf('   CP validation (15V, 20W): %s\n', val_cp.reason);
    
    val_cr = plel_validate_cr(15, 15, params.current_max_A, params.power_peak_W);
    fprintf('   CR validation (15V, 15R): %s\n', val_cr.reason);
    
    fprintf('\n');
    
    % Demonstrate engineering report
    fprintf('9. ENGINEERING PROVENANCE REPORT\n');
    fprintf('   ------------------------------\n');
    report = plel_engineering_report();
    fprintf('%s\n', report);
    
    fprintf('=== DEMONSTRATION COMPLETE ===\n');
    fprintf('Replace TBD parameters with measured/calibrated values for physical validation.\n');
end

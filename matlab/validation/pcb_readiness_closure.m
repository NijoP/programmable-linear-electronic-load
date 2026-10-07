function results = pcb_readiness_closure()
%PCB_READINESS_CLOSURE Reproducible analytical PCB-readiness calculations.
% Values sourced from docs/source/design-source.pdf unless noted.
% This script does not qualify hardware SOA, thermal performance, or ADC accuracy.

    Vin = 15; Itotal = 2; N = 4; Rsh = 0.01; Rballast = 0.1;
    Pset = 20; Pmax = 30; Imax = 2;

    results.Ibranch = Itotal / N;
    results.Vshunt = Itotal * Rsh;
    results.Pshunt = Itotal^2 * Rsh;
    results.Pballast_each = results.Ibranch^2 * Rballast;
    results.Pballast_total = N * results.Pballast_each;
    results.Vds_branch = Vin - results.Vshunt - results.Ibranch * Rballast;
    results.Pmosfet_each = results.Vds_branch * results.Ibranch;
    results.Pmosfet_total = N * results.Pmosfet_each;
    results.Pload = Vin * Itotal;
    results.Paccounted = results.Pmosfet_total + results.Pballast_total + results.Pshunt;

    vin_points = [10 12 15];
    results.cp_current = arrayfun(@(v) min([Imax, Pmax/v, Pset/v]), vin_points);
    results.cp_expected = [2, 20/12, 20/15];
    assert(max(abs(results.cp_current - results.cp_expected)) < 1e-12);

    % Datasheet-bounded, uncalibrated current-sense error only.
    % INA180A3: |VOS|max=500 uV, gain error max=1% (SBOS741H).
    % Shunt tolerance is +/-1% from the source PDF. TCR and ADC terms remain TBD.
    I = [0.1 0.5 1.0 1.5 2.0];
    shunt_gain_error = 0.01 + 0.01;
    offset_A = 500e-6 / (Rsh * 100);
    results.sense_current_A = I;
    results.sense_nominal_V = I; % Rsh*100 = 1 V/A
    results.sense_partial_worst_A = I * shunt_gain_error + offset_A;
    results.sense_partial_worst_percent = 100 * results.sense_partial_worst_A ./ I;
    results.sense_bound_note = 'Excludes shunt TCR, ADC, layout, temperature and calibration terms.';

    % IPC-2221 empirical external-layer sizing check, 2 oz copper, 10 C rise.
    % k=0.048, I=k*dT^0.44*A^0.725; A in mil^2; t=2.8 mil.
    copper_thickness_mil = 2.8;
    allowed_rise_C = 10;
    area_mil2 = (Itotal / (0.048 * allowed_rise_C^0.44))^(1/0.725);
    results.trace_width_min_mil = area_mil2 / copper_thickness_mil;
    results.trace_width_min_mm = results.trace_width_min_mil * 0.0254;
    results.trace_width_design_target_mm = 1.0; % design target, not PDF requirement
    trace_length_m = 0.1;
    rho_copper = 1.724e-8;
    width_m = 0.005;
    thickness_m = 70e-6;
    results.source_example_trace_R_ohm = rho_copper * trace_length_m / (width_m * thickness_m);
    results.source_example_trace_drop_V = Itotal * results.source_example_trace_R_ohm;
    results.source_example_trace_loss_W = Itotal^2 * results.source_example_trace_R_ohm;

    fprintf('CP [10 12 15 V] = [%.6f %.6f %.6f] A\n', results.cp_current);
    fprintf('Ibranch=%.6f A, Vshunt=%.6f V, Pshunt=%.6f W\n', results.Ibranch, results.Vshunt, results.Pshunt);
    fprintf('Pballast(each,total)=[%.6f %.6f] W\n', results.Pballast_each, results.Pballast_total);
    fprintf('Vds=%.6f V, Pmosfet(each,total)=[%.6f %.6f] W\n', results.Vds_branch, results.Pmosfet_each, results.Pmosfet_total);
    fprintf('Power accounted=%.6f W; load=%.6f W; residual=%.3g W\n', results.Paccounted, results.Pload, results.Paccounted-results.Pload);
    fprintf('Partial uncalibrated sense error A at [0.1 0.5 1 1.5 2] A:\n');
    fprintf('  '); fprintf('%.6f ', results.sense_partial_worst_A); fprintf('\n');
    fprintf('Partial uncalibrated sense error %%:\n  '); fprintf('%.3f ', results.sense_partial_worst_percent); fprintf('\n');
    fprintf('IPC-2221 external-layer minimum width at 2 A/10 C/2 oz = %.3f mm\n', results.trace_width_min_mm);
end

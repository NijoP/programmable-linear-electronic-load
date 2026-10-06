function generate_hardware_readiness_plots()
%GENERATE_HARDWARE_READINESS_PLOTS Generate all 10 hardware-readiness validation plots.
%   This function creates the plots used for hardware-readiness validation and
%   saves them to 'results/plots/hardware-readiness/'.
%
%   Usage:
%   >>> addpath('matlab/project');
%   >>> plel_setup();
%   >>> generate_hardware_readiness_plots()
%
%   See also: plel_setup, plel_parameters

% Add project paths and load parameters
addpath('matlab/project');
root = plel_setup();
[params, ~] = plel_parameters();

% Ensure results directory exists
plotDir = fullfile(root, 'results', 'plots', 'hardware-readiness');
mkdir(plotDir);

% 01_operating_envelope.png
figure;
I = 0:0.1:20;
hold on;
plot(2*ones(size(0:0.1:20)), 0:0.1:20, 'b-', 'LineWidth', 2); % CC limit
plot(30./I, I, 'r-', 'LineWidth', 2); % CP limit
plot(15*I, I, 'g-', 'LineWidth', 2); % CR limit
hold off;
xlabel('Voltage V (V)');
ylabel('Current I (A)');
title('Operating Envelope');
legend('CC limit (2 A)', 'CP limit (30 W)', 'CR limit (15 \Omega)');
grid on;
xlim([0 20]);
ylim([0 20]);
saveas(gcf, fullfile(plotDir, '01_operating_envelope.png'));
close(gcf);

% 02_mosfet_stress.png
figure;
I = 0:0.01:2;
I_branch = I / 4;
Vin = 15;
Rsh = params.shunt_ohm;
Rballast = params.ballast_ohm;
N = params.num_mosfets;
Ptotal = Vin.*I - I.^2*Rsh - N*(I/N).^2*Rballast;
Pper = Ptotal / N;
plot(I, Pper, 'b-', 'LineWidth', 2);
rated_per = 7.47;
yline(rated_per, '--', 'Rated per MOSFET');
xlabel('Total Current I (A)');
ylabel('Power per MOSFET (W)');
title('MOSFET Stress: Power Dissipation vs Current');
legend('Per-MOSFET Power', 'Rated Power');
grid on;
saveas(gcf, fullfile(plotDir, '02_mosfet_stress.png'));
close(gcf);

% 03_thermal_sweep.png
figure;
Tc = 0:0.1:100;
P_loss = 7.47;
Rjc = params.rjc_example_K_per_W;
TJ = Tc + (P_loss * Rjc);
plot(Tc, TJ, 'b-', 'LineWidth', 2);
xlabel('Case Temperature T_C (°C)');
ylabel('Junction Temperature T_J (°C)');
title('Thermal Sweep: Junction Temperature vs Case Temperature');
grid on;
saveas(gcf, fullfile(plotDir, '03_thermal_sweep.png'));
close(gcf);

% 04_current_sense.png
figure;
I = 0:0.01:2;
Vsh = zeros(size(I));
Vsense = zeros(size(I));
% Handle zero current to avoid errors in plel_shunt_voltage and plel_sense_voltage
if I(1) == 0
    Vsh(1) = 0;
    Vsense(1) = 0;
    startIdx = 2;
else
    startIdx = 1;
end
for i = startIdx:numel(I)
    Vsh(i) = plel_shunt_voltage(I(i), params.shunt_ohm);
    Vsense(i) = plel_sense_voltage(I(i), params.shunt_ohm, params.sense_gain_V_V);
end
plot(I, Vsh, 'b-', 'LineWidth', 2);
hold on;
plot(I, Vsense, 'r-', 'LineWidth', 2);
hold off;
xlabel('Load Current I (A)');
ylabel('Voltage (V)');
title('Current-Sense Output');
legend('Shunt Voltage', 'Sense Voltage');
grid on;
saveas(gcf, fullfile(plotDir, '04_current_sense.png'));
close(gcf);
% 05_dac_resolution.png
figure;
Videal = 0:0.001:params.dac_supply_V;
N = 2^params.dac_bits;
codes = zeros(size(Videal));
for i = 1:numel(Videal)
    codes(i) = plel_dac_code(Videal(i), params.dac_supply_V, params.dac_transfer_denominator);
end
Vactual = codes * params.dac_supply_V / N;
plot(Videal, Vactual, 'b-', 'LineWidth', 2);
hold on;
plot(Videal, Videal, 'k--', 'LineWidth', 1);
hold off;
xlabel('Ideal Output Voltage (V)');
ylabel('Actual Output Voltage (V)');
title('DAC Resolution');
legend('Actual output', 'Ideal output');
grid on;
saveas(gcf, fullfile(plotDir, '05_dac_resolution.png'));
close(gcf);

% 06_pcb_parasitics.png
figure;
L = 0:0.001:0.5;
w = 0.005;
t = 35e-6;
rho = 1.724e-8;
% Handle zero trace length to avoid errors in plel_trace_resistance
if L(1) == 0
    R(1) = 0;
    startIdx = 2;
else
    startIdx = 1;
end
for i = startIdx:numel(L)
    R(i) = plel_trace_resistance(L(i), w, t, rho);
end
plot(L*1000, R*1000, 'b-', 'LineWidth', 2);
xlabel('Trace Length (mm)');
ylabel('Trace Resistance (mohm)');
title('PCB Parasitics: Trace Resistance vs Length');
grid on;
saveas(gcf, fullfile(plotDir, '06_pcb_parasitics.png'));
close(gcf);
figure;
Tc = 0:0.1:100;
Icmd_nominal = 1.5;
T_shutdown = params.t_shutdown_C;
T_derating = params.t_derating_C;
T_fan_high = params.t_fan_high_C;
Icmd = zeros(size(Tc));
for i = 1:numel(Tc)
    [Icmd(i), ~, ~] = plel_derating_logic(Icmd_nominal, Tc(i), T_shutdown, T_derating, T_fan_high);
end
plot(Tc, Icmd, 'b-', 'LineWidth', 2);
grid on;
xlabel('Case Temperature T_C (°C)');
ylabel('Icmd (A)');
title('Protection Boundaries: Derating Logic');
legend('Icmd (Actual)');
yline(Icmd_nominal, '--', 'Nominal Icmd');
xline(T_derating, '--', 'Derating Start');
xline(T_shutdown, '--', 'Shutdown Threshold');
xline(T_fan_high, '--', 'Fan High');
saveas(gcf, fullfile(plotDir, '07_protection_boundaries.png'));
close(gcf);

% 08_bringup_points.png
figure;
V = [10, 10, 12, 15, 15];
I = [0.2, 0.5, 1.0, 1.5, 2.0];
P = V .* I;
plot(V, P, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
hold on;
V_vec = 10:0.1:15;
Imax = params.current_max_A;
Pmax = params.power_peak_W;
I_limited = Pmax ./ V_vec;
I_limited(I_limited > Imax) = Imax;
plot(V_vec, V_vec .* I_limited, 'k--', 'LineWidth', 1);
hold off;
xlabel('Input Voltage V_{IN} (V)');
ylabel('Power (W)');
title('Bring-up Points on Power Limitation Curve');
legend('Bring-up Points', 'Pmax Limit');
grid on;
saveas(gcf, fullfile(plotDir, '08_bringup_points.png'));
close(gcf);

% 09_tolerance_analysis.png
figure;
I = 0:0.01:2;
Rnom = params.shunt_ohm;
Rtol = Rnom * 0.01;
Rmin = Rnom - Rtol;
Rmax = Rnom + Rtol;
Vsh_nom = zeros(size(I));
Vsh_min = zeros(size(I));
Vsh_max = zeros(size(I));
% Handle zero current to avoid errors in plel_shunt_voltage
if I(1) == 0
    Vsh_nom(1) = 0;
    Vsh_min(1) = 0;
    Vsh_max(1) = 0;
    startIdx = 2;
else
    startIdx = 1;
end
for i = startIdx:numel(I)
    Vsh_nom(i) = plel_shunt_voltage(I(i), Rnom);
    Vsh_min(i) = plel_shunt_voltage(I(i), Rmin);
    Vsh_max(i) = plel_shunt_voltage(I(i), Rmax);
end
plot(I, Vsh_nom, 'b-', 'LineWidth', 2);
hold on;
plot(I, Vsh_min, 'k:', 'LineWidth', 1.5);
plot(I, Vsh_max, 'k:', 'LineWidth', 1.5);
hold off;
xlabel('Load Current I (A)');
ylabel('Shunt Voltage V_{sh} (V)');
title('Tolerance Analysis: Shunt Voltage vs Current');
legend('Nominal (1%)', 'Min Tolerance', 'Max Tolerance');
grid on;
saveas(gcf, fullfile(plotDir, '09_tolerance_analysis.png'));
close(gcf);
% 10_MOSFET_current_sharing.png
figure;
I_total = 2;
N = params.num_mosfets;
I_branch = I_total / N * ones(1, N);
branches = 1:N;
plot(branches, I_branch, 'b-', 'LineWidth', 2);
xlabel('MOSFET Branch Number');
ylabel('Branch Current (A)');
title('MOSFET Current Sharing: Ideal Equal Sharing');
grid on;
saveas(gcf, fullfile(plotDir, '10_MOSFET_current_sharing.png'));
close(gcf);
end

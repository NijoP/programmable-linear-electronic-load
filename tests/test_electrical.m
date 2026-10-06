function test_electrical()
%TEST_ELECTRICAL Verify core electrical calculations against source specification.
%   This test checks the electrical model functions for correctness
%   using the source PDF reference values.

    % Clear workspace
    close all; clear all; clc;

    % Test 1: Shunt voltage
    % Source §11: Vsh = I × Rsh. At 2 A with 0.01 ohm: 20 mV
    Vsh = plel_shunt_voltage(2, 0.01);
    assert(abs(Vsh - 0.02) < 1e-15, ...
        sprintf('Shunt voltage: expected 0.02 V, got %g V', Vsh));
    fprintf('PASS: Shunt voltage at 2 A = %.5f V (expected 0.02 V)\n', Vsh);

    % Test 2: Shunt voltage at 0.5 A
    Vsh = plel_shunt_voltage(0.5, 0.01);
    assert(abs(Vsh - 0.005) < 1e-15, ...
        sprintf('Shunt voltage: expected 0.005 V, got %g V', Vsh));
    fprintf('PASS: Shunt voltage at 0.5 A = %.5f V (expected 0.005 V)\n', Vsh);

    % Test 3: Sense voltage
    % Source §12: Vsense = 100 × Vsh = 100 × I × Rsh. At 2 A: 2 V
    Vsense = plel_sense_voltage(2, 0.01, 100);
    assert(abs(Vsense - 2.0) < 1e-15, ...
        sprintf('Sense voltage: expected 2.0 V, got %g V', Vsense));
    fprintf('PASS: Sense voltage at 2 A = %.5f V (expected 2.0 V)\n', Vsense);

    % Test 4: Sense voltage at 0.5 A
    Vsense = plel_sense_voltage(0.5, 0.01, 100);
    assert(abs(Vsense - 0.5) < 1e-15, ...
        sprintf('Sense voltage: expected 0.5 V, got %g V', Vsense));
    fprintf('PASS: Sense voltage at 0.5 A = %.5f V (expected 0.5 V)\n', Vsense);

    % Test 5: DAC code for 2 V at 3.3 V with 4096 denominator
    % Source §13: code = Vout × 4096 / 3.3. Floor to 2482.
    % code = 2.0 × 4096 / 3.3 = 2482.4242... -> floor = 2482
    code = plel_dac_code(2.0, 3.3, 4096);
    assert(code == 2482, ...
        sprintf('DAC code: expected 2482, got %d', code));
    fprintf('PASS: DAC code for 2 V at 3.3 V = %d (expected 2482)\n', code);

    % Test 5: DAC code for 0 V
    code = plel_dac_code(0, 3.3, 4096);
    assert(code == 0, sprintf('DAC code for 0 V: expected 0, got %d', code));
    fprintf('PASS: DAC code for 0 V = %d\n', code);

    % Test 6: Voltage divider
    % Source §14: R1=33k, R2=7.5k, at 15 V: Vadc = 15 × 7500/40500 = 2.7778 V
    Vadc = plel_voltage_divider(15, 33000, 7500);
    expected = 15 * 7500 / 40500;
    assert(abs(Vadc - expected) < 1e-15, ...
        sprintf('Divider: expected %.5f V, got %g V', expected, Vadc));
    fprintf('PASS: Voltage divider at 15 V = %.5f V (expected %.5f V)\n', Vadc, expected);

    % Test 7: CC command
    % Source §22: Icmd = min(Iset, Imax, Pmax/Vin). At Iset=1.5A, Imax=2A, Pmax=30W, Vin=15V
    Icmd = plel_cc_command(1.5, 2, 30, 15);
    assert(abs(Icmd - 1.5) < 1e-15, ...
        sprintf('CC command: expected 1.5 A, got %g A', Icmd));
    fprintf('PASS: CC command at 15 V = %.5f A (expected 1.5 A)\n', Icmd);

    % Test 8: CC command with power limit
    % At Vin=12 V, Pmax=30W gives Ilimit = 30/12 = 2.5 A, but Imax=2A clips it
    Icmd = plel_cc_command(1.5, 2, 30, 12);
    assert(abs(Icmd - 1.5) < 1e-15, ...
        sprintf('CC command at 12 V: expected 1.5 A, got %g A', Icmd));
    fprintf('PASS: CC command at 12 V = %.5f A (expected 1.5 A)\n', Icmd);

    % Test 9: CP command
    % Source §23: At Pset=20W, Vin=15V: Ireq = 20/15 = 1.333 A
    Icmd = plel_cp_command(20, 2, 30, 15);
    expected = 20/15;
    assert(abs(Icmd - expected) < 1e-9, ...
        sprintf('CP command: expected %.4f A, got %g A', expected, Icmd));
    fprintf('PASS: CP command at 15 V = %.4f A (expected %.4f A)\n', Icmd, expected);

    % Test 10: CP command at 12 V
    Icmd = plel_cp_command(20, 2, 30, 12);
    expected = 20/12;
    assert(abs(Icmd - expected) < 1e-9, ...
        sprintf('CP command at 12 V: expected %.4f A, got %g A', expected, Icmd));
    fprintf('PASS: CP command at 12 V = %.4f A (expected %.4f A)\n', Icmd, expected);

    % Test 10: CR command
    % Source §24: At Vin=15V, Rset=15 ohm: Ireq = 15/15 = 1 A
    Icmd = plel_cr_command(15, 15, 2, 30);
    assert(abs(Icmd - 1.0) < 1e-15, ...
        sprintf('CR command: expected 1.0 A, got %g A', Icmd));
    fprintf('PASS: CR command at 15 V, 15 ohm = %.5f A (expected 1.0 A)\n', Icmd);

    % Test 11: NTC resistance
    % Source §26: R0=10k at 25°C, beta=3950 K. At 25°C (same temp): R=10k
    R = plel_ntc_resistance(10000, 3950, 298.15, 298.15);
    assert(abs(R - 10000) < 1, ...
        sprintf('NTC resistance: expected ~10000 ohms, got %g ohms', R));
    fprintf('PASS: NTC resistance at 25°C = %.1f ohms (expected 10000)\n', R);

    % Test 12: NTC resistance at 0°C (approximate)
    R = plel_ntc_resistance(10000, 3950, 298.15, 273.15);
    fprintf('INFO: NTC resistance at 0°C = %.1f ohms\n', R);

    % Test 13: Temperature from NTC
    T_K = plel_temperature_from_ntc(10000, 10000, 3950, 298.15);
    assert(abs(T_K - 298.15) < 0.01, ...
        sprintf('Temperature from NTC: expected 298.15 K, got %g K', T_K));
    T_C = T_K - 273.15;
    fprintf('PASS: Temperature from NTC = %.2f°C (expected 25.00°C)\n', T_C);

    % Test 14: Derating logic - normal range
    [Icmd, state, reason] = plel_derating_logic(1.5, 30, 85, 75, 60);
    assert(strcmp(state, 'active'), ...
        sprintf('Derating: expected state active, got %s', state));
    fprintf('PASS: Derating logic at 30°C = state %s\n', state);

    % Test 15: Derating logic - shutdown
    [Icmd, state, reason] = plel_derating_logic(1.5, 90, 85, 75, 60);
    assert(strcmp(state, 'shutdown'), ...
        sprintf('Derating: expected state shutdown, got %s', state));
    assert(abs(Icmd) < 1e-15, sprintf('Derating: expected Icmd=0, got %g', Icmd));
    fprintf('PASS: Derating logic at 90°C = state %s, Icmd = %g\n', state, Icmd);

    % Test 16: Derating logic - derating region
    [Icmd, state, reason] = plel_derating_logic(1.5, 75, 85, 75, 60);
    assert(strcmp(state, 'derating'), ...
        sprintf('Derating: expected state derating, got %s', state));
    fprintf('PASS: Derating logic at 75°C = state %s, Icmd = %.4f A\n', state, Icmd);

    % Test 17: Derating logic - fan high
    [Icmd, state, reason] = plel_derating_logic(1.5, 65, 85, 75, 60);
    assert(strcmp(state, 'fan_high'), ...
        sprintf('Derating: expected state fan_high, got %s', state));
    fprintf('PASS: Derating logic at 65°C = state %s\n', state);

    fprintf('\n=== All electrical tests passed! ===\n');
end
# PLEL R1 Hardware-Validation Digital-Twin Report

```text
PCB_DESIGN_RELEASE = PASS
HARDWARE_VALIDATION = PENDING
HARDWARE_VALIDATION_SIMULATION = COMPLETE
```

This report contains simulated and datasheet-derived predictions only. It does
not claim prototype measurement, calibration, or hardware qualification.

## 1. Simulation scope

The digital-twin layer models the R1 command path, four-device current sharing,
BUZ11 design SOA envelope, quasi-static thermal network, INA180A3/shunt/ADC
error chain, DAC quantization, gate loading, conservative loop-design region,
startup/fault states, emergency STOP logic, communication timeout, R1 power
tree, Monte Carlo uncertainty, and operating envelope.

## 2. MOSFET sharing

`matlab/validation/plel_r1_current_sharing.m` models four individual branches
with ballast tolerance, VGS-related mismatch, transconductance mismatch, and
current normalization to the requested total current. Results include every
branch current/power, imbalance, worst branch, and mean/std/min/max/percentiles.
The distributions are design assumptions and are not device matching data.

## 3. SOA

`plel_r1_soa_twin` maps VDS, ID, device power, and margin against the released
conservative graphical BUZ11 boundary. It does not invent a temperature curve.
The model is based on the 25 °C graphical extraction and keeps hot-case SOA as
a physical test requirement.

## 4. Thermal

`plel_r1_thermal_twin` calculates case, shared sink, and junction temperature
for branch powers and ambient sweeps. RthetaJC is datasheet-derived; RthetaSA,
RthetaCS, TIM, airflow, and ambient scenarios are design targets. No measured
temperature is present.

## 5. Current sense

`plel_r1_sense_twin` includes shunt tolerance, INA180 offset/gain variation,
ADC offset/gain/quantization design terms, and returns Monte Carlo current
statistics at 0.1, 0.5, 1, 1.5, and 2 A. The calibration transform is defined
but coefficients remain TBD until traceable hardware data exists.

## 6. Gate drive

`plel_r1_gate_twin` predicts aggregate Ciss, 1 kΩ time constants, initial gate
current, predicted 7.5–8.2 V design region, and LM358B source-current margin.
Loaded gate waveforms remain physical validation.

## 7. Loop stability

`plel_r1_loop_twin` provides a conservative first-order design envelope around
the 159 Hz feedback filter and <=25 Hz design crossover. MOSFET gm, wiring,
output capacitance, and assembled parasitics remain unknown.

```text
LOOP_STABILITY_HARDWARE_TEST_REQUIRED = TRUE
```

No measured Bode result is claimed.

## 8. Power tree

The R1 model uses the OLED-free budget and includes ESP32 normal/peak allowance,
MCP4725, INA180A3, LM358B, NTC/logic, fan-control, and status support. The
3.3 V design budget is 0.548 A against the selected 0.6 A nominal AP2112K
limit, leaving approximately 52 mA nominal current margin. Regulator
temperature remains physical validation.

## 9. Startup, E-stop, and communication

State simulation covers POWER_ON, SELF_TEST, STANDBY, ACTIVE, FAULT, RESET,
MCU off, BOOT, brownout, and communication loss. Emergency STOP logic is
independent of software and forces the gate path off. A 2 s communication
watchdog enters `COMMUNICATION_FAULT` and commands zero; physical timeout
measurement remains pending.

## 10. Monte Carlo and operating envelope

The system Monte Carlo output reports mean, standard deviation, min, max, and
percentiles for sharing, sense, power, and thermal quantities. Operating-region
plots distinguish electrical/thermal safe, derating, and prohibited regions.
All outliers are retained.

## 11. Physical test plan

The complete instrument list, conditions, expected model quantities, and
correlation variables are in `docs/HARDWARE_VALIDATION_PLAN_R1.md`.
Populate only actual measurements in `measurements/hardware_validation_template.csv`.

## 12. Correlation methodology

Use `import_hardware_measurements` to import measured data and
`correlate_hardware_vs_model` to calculate bias, relative error, RMSE, and
maximum deviation. `MEASURED` and `CALIBRATED` status require real data files;
MATLAB simulation cannot promote them automatically.

## 13. Remaining unknowns

- Device-to-device actual VGS/gm and current sharing
- Hot-case BUZ11 SOA
- Assembled thermal resistance and airflow
- Shunt TCR/Kelvin parasitics
- ADC transfer and calibration coefficients
- Loaded gate waveforms
- Physical loop gain/phase margins
- Startup/brownout/fault propagation timing
- Actual Wi-Fi/RF current and regulator temperature
- Final PCB DFM/production inspection

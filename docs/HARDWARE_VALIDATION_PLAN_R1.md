# PLEL R1 Hardware Validation Plan

**PCB_DESIGN_RELEASE:** PASS
**HARDWARE_VALIDATION:** PENDING

This plan defines measurements to be performed on the fabricated PCB. MATLAB
simulation and datasheet review are not physical validation.

| Item | Measurement / instrument | Test condition | Simulation comparison | Acceptance criterion | MATLAB variable |
|---|---|---|---|---|---|
| Current sharing | Four current probes or shunt branch measurements; DMM/current source | 15 V, 2 A, steady state | `plel_r1_current_sharing` branch currents | Confirm each branch stays within released design SOA and no unstable sharing; numerical tolerance to be set from measured setup uncertainty | `branch_current_A` |
| MOSFET VDS/ID/power | Differential HV probe + current measurement | 10–15 V, 0.1–2 A | VDS, ID, Pdevice envelope | No device exceeds datasheet SOA or released thermal design point | `vds_V`, `id_per_device_A`, `power_per_device_W` |
| MOSFET temperature | Thermocouple/IR with emissivity control | Worst ambient and 30 W target | `junction_C`, `case_C` | Tj inferred below selected derating limit with stated sensor uncertainty | `junction_C` |
| Heatsink temperature | Thermocouple | 10/25/35/45 °C ambient where practical | `sink_C` | Compare RθSA estimate; no claim before test | `sink_C` |
| Ambient | Calibrated temperature logger | Same thermal runs | `ambient_C` sweep | Record actual ambient | `ambient_C` |
| Current-sense output | DMM/oscilloscope | 0.1, 0.5, 1, 1.5, 2 A | INA180 output and sense model | Fit calibration; report residual and uncertainty | `sense_V` |
| ESP32 ADC | Firmware raw ADC log + traceable input | Same current points and VIN points | ADC/non-ideal sense twin | Calibration residual documented; no ideal ADC assumption | `adc_raw` |
| DAC output | DMM/oscilloscope | Codes across 0–full scale and operating setpoints | `plel_r1_dac_twin` | Code monotonicity and measured transfer compared with datasheet limits | `dac_V` |
| Gate voltage | Differential oscilloscope probes | 2 A / 15 V and startup/stop | `plel_r1_gate_twin` | Loaded VGS remains in released design region; no unsafe overshoot | `gate_V` |
| Control loop | FRA/Bode injection or swept setpoint with oscilloscope | Small-signal perturbations at representative load points | `plel_r1_loop_twin` | Measured gain/phase recorded; margins assessed, not assumed | loop model fields |
| Startup | Oscilloscope on inhibit, DAC, gate, VIN | Power-on, reset, boot | `plel_r1_state_twin` | Gate path remains off until authorized | state timeline |
| Brownout | Programmable supply ramp | Controlled brownout/reset | state twin | Power stage off throughout unsafe reset interval | state timeline |
| Fault | Assert hardware fault input | Active load and standby | state twin | Fault disables gate path and records latch behavior | `fault` |
| Emergency STOP | Press/operate NC E-stop; oscilloscope/current probe | Active load | `plel_r1_emergency_stop_logic` | Gate-enable opens and branch current decays safely; hardware path independent | `estop`, gate-enable |
| Regulator voltage/current/temp | DMM, current meter, thermocouple | Wi-Fi idle, active, RF activity, fan start | `plel_r1_power_tree_twin` | Rails remain within selected regulator limits and thermal design | power-tree fields |
| Wi-Fi operating current | Supply current logger | Association, web telemetry, command activity | ESP32 normal/peak budget | Compare to 3.3 V budget; record RF peaks | `I3V3_A` |
| Communication loss | Disable client heartbeat/network | ACTIVE, 1/2/3 s and long loss | `plel_r1_communication_twin` | Safe state at released timeout; physical inhibit response recorded | timeout state |

## Correlation data contract

Populate `measurements/hardware_validation_template.csv` only with actual
prototype measurements. Use `import_hardware_measurements` and
`correlate_hardware_vs_model` for measured-versus-simulated bias, relative
error, RMSE, and maximum deviation. Empty template rows are not measurements.

## Status semantics

- `SIMULATION_CLOSED`: model executed with explicit assumptions.
- `DATASHEET_CLOSED`: component limit or transfer supported by manufacturer data.
- `PHYSICAL_TEST_REQUIRED`: no fabricated result permitted.
- `MEASURED`: only populated from a real measurement file.
- `CALIBRATED`: only after a documented calibration procedure and data record.

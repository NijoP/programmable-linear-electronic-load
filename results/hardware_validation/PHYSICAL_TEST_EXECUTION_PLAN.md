# PLEL R1 Physical Test Execution Plan

This is an execution checklist for the fabricated prototype. No row is
`MEASURED` until a real data file is saved and imported.

## Common setup and safety

Use an isolated 15 V current-limited supply, calibrated DMM, differential HV
probe, isolated oscilloscope, thermocouples, current probes or branch shunts,
and a calibrated electronic source/load as appropriate. Start at low current,
use a guarded DUT, and place a fast input fuse. Abort if any MOSFET, connector,
regulator, or heatsink exceeds its design limit.

## Test matrix

| ID | Objective and setup | Equipment/probes | Expected model | Acceptance criterion | Data file / variables |
|---|---|---|---|---|---|
| HV-01 | Current sharing at 10/12/15 V and 0.5/1/1.5/2 A | Four isolated current probes or four branch shunts, DMM | `plel_r1_current_sharing_sweep` | All branches remain inside SOA and thermal design; report imbalance and uncertainty | `current_sharing.csv`; `branch_current_A`, `branch_power_W` |
| HV-02 | VDS/ID/SOA at 15 V, 2 A | Differential probe, current probe, scope | `plel_r1_soa_twin` | No branch crosses conservative manufacturer SOA boundary | `soa.csv`; `vds_V`, `id_per_device_A`, `power_per_device_W` |
| HV-03 | Thermal steady state at 10/25/35/45/55 °C ambient | Thermocouples on case/sink/ambient | `plel_r1_thermal_sweep` | Measured inferred Tj remains below selected derating limit with uncertainty | `thermal.csv`; `ambient_C`, `case_C`, `sink_C` |
| HV-04 | TIM/fan/Rθ assembly performance | Thermocouples, airflow meter, fan current meter | Thermal twin with actual airflow/Rθ | Compare inferred RθSA/RθCS; document deviation and derating | `thermal_assembly.csv`; `sink_C`, `case_C` |
| HV-05 | Current-sense calibration | Traceable current source/DMM, INA output probe | `plel_r1_sense_twin` | Fit zero/gain; independent points meet documented accuracy target | `sense_cal.csv`; `current_A`, `sense_V`, `adc_raw` |
| HV-06 | ESP32 current/voltage/NTC ADC calibration | Firmware raw log, reference meter, temperature reference | `plel_r1_adc_calibration_model` | Two-point coefficients and residuals recorded; no ideal ADC assumption | `adc_cal.csv`; `adc_raw`, `vin_V`, `current_A`, `ambient_C` |
| HV-07 | DAC transfer | DMM/scope at DAC test point | `plel_r1_dac_twin` | Monotonic transfer and residual versus code recorded | `dac.csv`; `dac_code`, `dac_V` |
| HV-08 | Loaded gate waveform | Differential gate probe at common bus and each branch | `plel_r1_gate_twin` | VGS remains in 7.5–8.2 V region; no unsafe overshoot/ringing | `gate.csv`; `gate_V`, `timestamp` |
| HV-09 | Loop response | FRA or injection resistor/scope | `plel_r1_loop_twin` | Measured crossover/phase/gain margins documented; do not assume stability | `loop.csv`; frequency, gain, phase |
| HV-10 | Startup/brownout | Scope on VIN, 3.3 V, reset, DAC, enable, gate | `plel_r1_state_twin` | Gate enable remains off until authorized and during brownout/reset | `startup.csv`; `startup_ms`, `dac_V`, `gate_enable`, `reset_line` |
| HV-11 | Fault propagation | Assert fault input during active load; scope | State twin | Gate-enable off and fault latch behavior recorded | `fault.csv`; `fault_ms`, `fault`, `gate_enable` |
| HV-12 | Emergency STOP propagation | Press NC E-stop under controlled active load; scope/current probe | E-stop truth model | Gate-enable opens, VGS collapses, branch current decays safely | `estop.csv`; `estop_ms`, `estop`, `gate_V`, `current_A` |
| HV-13 | Regulator/RF load | Supply logger, rail DMM, thermocouple | `plel_r1_power_tree_twin` | Rails and regulator temperature remain within selected regulator design limits | `power_tree.csv`; rail V/I/temp |
| HV-14 | Communication timeout | Disable heartbeat at 0.5/1/2/3 s and long loss | `plel_r1_communication_twin` | Safe state occurs at released timeout; timestamp measured | `communication.csv`; `timeout_ms`, `gate_enable`, `fault` |
| HV-15 | Final DFM/production inspection | CAD checklist, microscope, continuity meter | DFM checklist; no simulation substitute | All pre-fabrication checks closed; record post-build deviations | `dfm_inspection.csv`; checklist status |

## Required metadata

Every file must include `test_id`, timestamp, operator, instrument IDs and
instrument calibration dates. Preserve raw data; do not overwrite a failed run.
Use `import_hardware_measurements` only after mapping the file to the template
schema.

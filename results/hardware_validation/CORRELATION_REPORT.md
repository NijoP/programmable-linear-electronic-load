# PLEL R1 Model-to-Hardware Correlation Report

**Current status:** `NO_MEASURED_DATA`

This report is a correlation procedure and empty-result declaration. No
prototype measurement has been supplied, so no measured error, bias, RMSE, or
calibration result is claimed.

## Procedure

1. Populate `measurements/hardware_validation_template.csv` from the real PCB.
2. Preserve test metadata, instrument IDs, calibration dates, operator, test
   condition, and raw values.
3. Import using `import_hardware_measurements`.
4. Generate simulation vectors using the applicable twin function.
5. Call `correlate_hardware_vs_model` with aligned measured and simulated data.
6. Review bias, relative error, RMSE, and maximum deviation for every channel.
7. Only after real reference data exists may calibration coefficients be fitted.
8. Store the calibration data and coefficients as `CALIBRATED`; never infer them
   from simulation.

## Supported comparison groups

- DC operating point: VIN, current, power
- Thermal: ambient, sink, case
- Current sense: sense voltage, ADC raw code, corrected current
- DAC: code and measured DAC voltage
- Gate waveform: gate voltage and timing
- Startup/fault/E-stop: event timing, gate enable, reset/fault lines
- Communication timeout: timeout interval and safe-state transition

## Metrics

For each aligned signal:

```text
error = measurement - simulation
relative_error = abs(error) / max(abs(simulation), epsilon)
bias = mean(error)
RMSE = sqrt(mean(error^2))
max_deviation = max(abs(error))
```

Alignment and instrument uncertainty must be recorded with the test data.

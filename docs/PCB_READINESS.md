# PCB Readiness Report

This document summarizes the readiness of the Programmable Linear Electronic Load (PLEL) design for PCB fabrication.

## Status Summary

| Item | Status | Notes |
|------|--------|-------|
| Electrical Limits (CC/CP/CR) | READY | CP implementation corrected |
| Power Balance | READY | Corrected to ~30 W |
| Thermal Model (Shared Heatsink) | READY | Illustrative values labeled as provisional |
| BUZ11 SOA Evidence | DATASHEET REQUIRED | Datasheet identified; SOA curve evaluation pending |
| Shunt Resistor Specification | DATASHEET REQUIRED | Need exact part with tolerance and TCR |
| INA180A3 Variant | DATASHEET REQUIRED | Need exact part and error specifications |
| MCP4725 Variant | DATASHEET REQUIRED | Need exact part and startup behavior |
| LM358B Supply/Headroom | DATASHEET REQUIRED | Need to verify supply and output swing |
| ESP32-WROOM-32 Module | DATASHEET REQUIRED | Need to verify current draw and land pattern |
| 3.3V LDO Selection | DATASHEET REQUIRED | Need to select exact part |
| NTC Thermistor | DATASHEET REQUIRED | Need exact part and tolerance |
| Ballast Resistors | DATASHEET REQUIRED | Need exact part and tolerance |
| Gate Resistors | DATASHEET REQUIRED | Need exact part and tolerance |
| Gate Pull-downs | DATASHEET REQUIRED | Need exact part and tolerance |
| Gate Zeners | DATASHEET REQUIRED | Need exact part and tolerance |
| Heatsink | DATASHEET REQUIRED | Need to select part with measured thermal resistance |
| Fan | DATASHEET REQUIRED | Need to select part with airflow characteristics |
| Fuse | DATASHEET REQUIRED | Need to select rating and type |
| Connectors | DATASHEET REQUIRED | Need to select terminals/current rating |
| OLED Display | DATASHEET REQUIRED | Need to select exact module |
| Power-Rail Budget | MEASUREMENT REQUIRED | Need to measure actual currents |
| Current-Sense Error Budget | MEASUREMENT REQUIRED | Need to characterize shunt, INA, ADC |
| Startup Safety Path | SCHEMATIC REQUIRED | Need to define hardware inhibit |
| Kelvin-Sense Strategy | LAYOUT REQUIRED | Need to define sense routing |
| High-Current Routing | LAYOUT REQUIRED | Need to define trace widths/via requirements |
| Thermal/Placement Requirements | LAYOUT REQUIRED | Need to define component placement and thermal vias |
| MATLAB Regression Tests | READY | All tests passing |

## Next Steps

1. Obtain datasheets for all critical components and populate hardware matrix.
2. Perform SOA evaluation for BUZ11 at design point.
3. Characterize current-sense chain (shunt, INA180A3, ESP32 ADC).
4. Measure power-rail currents under worst-case conditions.
5. Define hardware startup inhibit circuit.
6. Complete schematic and layout based on derived requirements.
7. Perform thermal validation with selected heatsink and airflow.
8. Update MATLAB models with measured/calibrated values where appropriate.
9. Re-run validation tests with updated parameters.
10. Finalize PCB readiness sign-off.

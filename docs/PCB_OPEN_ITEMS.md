# PCB Open Items Tracking

This document tracks open items that need to be resolved before PCB fabrication can proceed.

## Critical Blockers (Must be resolved before PCB commit)

| Item | Status | Required Action | Owner | Due Date |
|------|--------|-----------------|-------|----------|
| BUZ11 SOA Evaluation | OPEN | Evaluate DC SOA curve at design point (VDS≈15V, ID≈0.5A per device) with actual case temperature and duration | Hardware Engineer | TBD |
| Shunt Resistor Selection | OPEN | Select exact part with tolerance and TCR specifications | Hardware Engineer | TBD |
| INA180A3 Error Budget | OPEN | Characterize offset voltage, gain error, and bandwidth at operating point | Test Engineer | TBD |
| MCP4725 Startup Mitigation | OPEN | Implement hardware inhibit or firmware mitigation for EEPROM midscale startup | Firmware Engineer | TBD |
| LM358B Supply Validation | OPEN | Verify op-amp supply arrangement and output swing sufficient for gate drive | Hardware Engineer | TBD |
| Heatsink Selection | OPEN | Select heatsink with measured RθSA ≤ 1.5 K/W at required airflow | Thermal Engineer | TBD |
| Fan Selection | OPEN | Select PWM-controllable fan with sufficient airflow and current draw | Hardware Engineer | TBD |
| Power Rail Measurement | OPEN | Measure actual currents drawn by ESP32, OLED, analog circuitry, and fan | Test Engineer | TBD |
| Current-Sense Calibration | OPEN | Calibrate shunt, INA180A3, and ADC chain to characterize end-to-end accuracy | Test Engineer | TBD |
| Startup Inhibit Circuit | OPEN | Design and validate hardware inhibit circuit to ensure power stage defaults OFF | Hardware Engineer | TBD |

## Required Documents (Must be completed before PCB commit)

| Item | Status | Required Action | Owner | Due Date |
|------|--------|-----------------|-------|----------|
| Schematic Capture | OPEN | Complete electrical schematic based on PCB requirements | Hardware Engineer | TBD |
| PCB Layout | OPEN | Complete PCB layout meeting all requirements (clearances, trace widths, via stitching, etc.) | PCB Engineer | TBD |
| Design Review | OPEN | Conduct formal design review of schematic and layout | Lead Engineer | TBD |
| DFM Check | OPEN | Perform Design for Manufacturing check | Manufacturing Engineer | TBD |
| Gerber Generation | OPEN | Generate fabrication files | PCB Engineer | TBD |

## Measurements Required (Must be completed before PCB commit)

| Item | Status | Required Action | Owner | Due Date |
|------|--------|-----------------|-------|----------|
| Shunt Resistance Measurement | OPEN | Measure actual resistance of selected shunt at operating temperature | Test Engineer | TBD |
| INA180A3 Offset/Gain | OPEN | Measure offset voltage and gain error at operating point | Test Engineer | TBD |
| ADC Characterization | OPEN | Measure ADC offset, gain, and linearity | Test Engineer | TBD |
| Power Rail Currents | OPEN | Measure actual current draw from 5V and 3.3V rails under worst-case conditions | Test Engineer | TBD |
| Thermal Resistance Validation | OPEN | Measure actual RθSA of selected heatsink with fan at specified airflow | Thermal Engineer | TBD |
| MOSFET Junction Temp | OPEN | Validate junction temperature prediction with thermal camera or IR measurement | Thermal Engineer | TBD |

## Firmware Tasks (Must be completed before PCB commit)

| Item | Status | Required Action | Owner | Due Date |
|------|--------|-----------------|-------|----------|
| Current Limit Implementation | OPEN | Implement Icmd = min(Iset, Imax, Pmax/Vin, Pset/Vin) | Firmware Engineer | TBD |
| Power Limit Implementation | OPEN | Implement Pmax/Vin limit | Firmware Engineer | TBD |
| Derating Logic | OPEN | Implement fan high (60°C), derating start (75°C), shutdown (85°C) | Firmware Engineer | TBD |
| Startup Sequence | OPEN | Ensure MCP4725 initialized to zero before enabling power stage | Firmware Engineer | TBD |
| Fault Handling | OPEN | Implement over-current and over-temperature fault handling | Firmware Engineer | TBD |
| Battery Tracking (Optional) | OPEN | Implement battery charge/energy tracking if required | Firmware Engineer | TBD |

## Notes
- All items marked as OPEN must be resolved before proceeding to PCB fabrication
- Due dates should be assigned as items are planned
- Status should be updated regularly (OPEN, IN PROGRESS, RESOLVED, VERIFIED)
- Critical blockers prevent PCB commit; other items should be resolved before first article build
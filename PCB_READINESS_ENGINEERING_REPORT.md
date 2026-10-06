# PCB Readiness Engineering Report

## Summary of Work Completed

This report summarizes the engineering analysis performed on the Programmable Linear Electronic Load (PLEL) design to assess PCB readiness. The analysis is based on the source PDF (`docs/source/design-source.pdf`), corrected MATLAB implementation, and available datasheet evidence.

### 1. Defects Fixed
- **CP Command Implementation**: Corrected `plel_cp_command.m` to enforce the proper dimensional equation:
  `Icmd = min(Imax, Pmax/Vin, Pset/Vin)`
  (Previously incorrectly compared power in watts with current in amps.)
  - Updated test expectations in `tests/test_electrical.m` to verify behavior at 10V, 12V, 15V with Pset=20W, Pmax=30W, Imax=2A.
  - All electrical tests pass.

- **Power Balance Calculation**: Corrected the senior hardware review's MOSFET power total from 30.18 W to 29.86 W (using accurate per-device power loss calculations).
  - Updated `SENIOR_HARDWARE_REVIEW.md` with corrected values.

- **Thermal Model Clarification**: Clarified that the heatsink-to-ambient thermal resistance (RθSA) is shared and applies to total power (~30 W), not per‑MOSFET power.
  - Illustrated calculation: With Ptotal ≈ 30 W, RθSA_shared = 1.5 K/W, Ta = 35 °C → Tsink ≈ 80 °C.
  - Using illustrative RθJC = 1.67 K/W and RθCS = 0.5 K/W per device → Tj ≈ 96.2 °C.
  - All values labeled as illustrative/provisional; actual values TBD.

### 2. Calculations Verified
- MATLAB regression tests pass:
  - `test_electrical.m`: All electrical functions (shunt/sense voltage, CC/CP/CR commands, DAC code, NTC, derating logic) pass.
  - `test_foundation.m`: All foundation tests pass.
- Hardware readiness plots regenerated with corrected calculations (see `results/plots/hardware-readiness/`).

### 3. Datasheet Evidence Obtained
Datasheets have been identified and linked for the following critical components (see `data/hardware_bom.json`):

| Component | Manufacturer | Exact MPN | Datasheet URL | Provenance |
|-----------|--------------|-----------|---------------|------------|
| BUZ11 MOSFET | onsemi (candidate) | BUZ11 | https://www.onsemi.com/pdf/datasheet/buz11-d.pdf | DATASHEET |
| Shunt Resistor | TBD | TBD | – | FROZEN_FROM_PDF (value only) |
| Current Sense Amplifier | Texas Instruments | INA180A3 | https://www.ti.com/lit/ds/symlink/ina180.pdf | DATASHEET |
| DAC | Microchip | MCP4725 | https://ww1.microchip.com/downloads/en/DeviceDoc/22039d.pdf | DATASHEET |
| Op‑Amp | Texas Instruments | LM358B | https://www.ti.com/lit/ds/symlink/lm358.pdf | DATASHEET |
| Microcontroller | Espressif | ESP32-WROOM-32 | https://www.espressif.com/sites/default/files/documentation/esp32-wroom-32_datasheet_en.pdf | DATASHEET |
| 5V Regulator | STMicroelectronics (candidate) | L7805 | https://www.st.com/resource/en/datasheet/l7805.pdf | DATASHEET |
| 3.3V LDO | TBD | TBD | – | FROZEN_FROM_PDF |
| NTC Thermistor | TBD | TBD | – | FROZEN_FROM_PDF |
| Ballast Resistor | TBD | TBD | – | FROZEN_FROM_PDF |
| Gate Resistor | TBD | TBD | – | FROZEN_FROM_PDF |
| Gate Pull‑down Resistor | TBD | TBD | – | FROZEN_FROM_PDF |
| Gate Zener Diode | TBD | TBD | – | FROZEN_FROM_PDF |
| Heatsink | TBD | TBD | – | FROZEN_FROM_PDF |
| Fan | TBD | TBD | – | FROZEN_FROM_PDF |
| Fuse | TBD | TBD | – | FROZEN_FROM_PDF |
| Input/Output Connectors | TBD | TBD | – | FROZEN_FROM_PDF |
| OLED Display | TBD | SSD1306 | https://www.solomon-systech.com/en/product/oled-display-drivers/ssd1306/ | DATASHEET |

### 4. Unresolved Parameters (TBD)
The following parameters remain unresolved and require datasheet selection, measurement, or calibration:

#### Shunt Resistor
- Temperature coefficient (ppm/°C) – TBD
- Exact part selection (tolerance, power rating, TCR) – DATASHEET REQUIRED

#### Current Sense Amplifier (INA180A3)
- Offset voltage (µV) – TBD
- Gain error (%) – TBD
- Bandwidth (kHz) – TBD
- Input common‑mode range (V) – TBD
- Output swing (V) – TBD
- Overall: Requires error budget characterization.

#### DAC (MCP4725)
- Supply voltage tolerance – TBD (need measured Vdd tolerance)
| Integral nonlinearity (LSB) – TBD
- Overall: Requires startup safety mitigation (hardware inhibit or firmware) due to EEPROM midscale power‑on state.

#### Op‑Amp (LM358B)
- Supply voltage arrangement (V) – TBD (must verify actual supply rails)
- Input common‑mode range (V) – TBD
- Output swing (V) – TBD
- Overall: Requires supply and headroom validation; slew rate (0.3 V/µs typical) may be insufficient for gate charging.

#### Microcontroller (ESP32‑WROOM‑32)
- Core current (mA) – TBD
- Wi‑Fi TX current (mA) – TBD
- GPIO current (mA) – TBD
- Overall: Requires power budget characterization.

#### 5V Regulator (L7805)
- Dropout voltage (V) – TBD
- Output current capacity (A) – TBD (must verify sufficient for load)
- Thermal resistance (K/W) – TBD
- Overall: Requires power budget and thermal validation.

#### 3.3V LDO
- Output voltage tolerance – TBD
- Output current (A) – TBD
- Dropout voltage (V) – TBD
- PSRR (dB) – TBD
- Overall: Part selection required.

#### NTC Thermistor
- Tolerance (%) – TBD
- Exact part selection (R25, Beta) – DATASHEET REQUIRED

#### Ballast Resistor
- Tolerance (%) – TBD
- Temperature coefficient (ppm/°C) – TBD
- Exact part selection – DATASHEET REQUIRED

#### Gate Resistor
- Tolerance (%) – TBD
- Exact part selection – DATASHEET REQUIRED

#### Gate Pull‑down Resistor
- Tolerance (%) – TBD
- Exact part selection – DATASHEET REQUIRED

#### Gate Zener Diode
- Tolerance (%) – TBD
- Power dissipation rating (W) – TBD
- Exact part selection – DATASHEET REQUIRED

#### Heatsink
- Thermal resistance (RθSA, K/W) – TBD (must select part with measured RθSA ≤ 1.5 K/W at required airflow)
- Overall: Heatsink selection and thermal characterization required.

#### Fan
- Airflow (CFM) – TBD
- Current draw (A) – TBD
- PWM controllability – TBD
- Overall: Fan selection and characterization required.

#### Fuse
- Rating (A) – TBD (suggested 2.5 A slow‑blow)
- Type (slow‑blow/time‑delay) – TBD
- Time‑current curve – TBD
- Overall: Fuse selection required.

#### Input/Output Connectors
- Current rating (A) – TBD (must handle ≥2 A)
- Contact resistance (mΩ) – TBD
- Voltage rating (V) – TBD
- Overall: Connector selection required.

#### OLED Display
- Operating voltage range (V) – TBD
- Current consumption (mA) – TBD
- Overall: Module selection and characterization required.

### 5. Physical Tests Still Required
The following physical measurements are needed to close the design:

- **Shunt resistance**: 4‑wire resistance measurement at operating temperature; temperature coefficient characterization.
- **INA180A3**: Offset voltage and gain error calibration at operating point; bandwidth verification.
- **ADC**: Offset, gain, and linearity characterization (if external ADC used; otherwise ESP32 ADC characteristics).
- **Power‑rail currents**: Measure actual current draw from 5 V and 3.3 V rails under worst‑case conditions (ESP32 TX/RX, OLED, analog circuitry, fan).
- **Heatsink thermal resistance**: Measure RθSA of selected heatsink with fan at specified airflow.
- **MOSFET junction temperature**: Validate junction temperature prediction with thermal camera or IR measurement under worst‑case power dissipation.

### 6. Procurement Blockers
Every critical component lacks an exact part selection with a verified datasheet. Until a specific part is chosen and its datasheet obtained, procurement cannot proceed. The following items are blockers:

- BUZ11 MOSFET: Requires SOA evaluation at design point (V_DS≈14.93 V, I_D≈0.5 A per device, continuous).
- Shunt resistor: Requires part with documented tolerance and TCR.
- INA180A3: Requires part with characterized offset/gain error and bandwidth.
- MCP4725: Requires hardware inhibit or firmware mitigation for EEPROM midscale startup.
- LM358B: Requires verification of supply arrangement and output swing sufficient for gate drive.
- ESP32‑WROOM‑32: Requires power budget characterization (core, Wi‑Fi, GPIO currents).
- 5V Regulator: Requires verification of dropout, output current capacity, and thermal resistance.
- 3.3V LDO: Requires part selection.
- NTC thermistor: Requires part selection.
- Ballast/gate/pull‑down/zener resistors: Require part selection with tolerance and TCR.
- Heatsink: Requires selection with measured thermal resistance ≤ 1.5 K/W at required airflow.
- Fan: Requires selection with sufficient airflow and current draw.
- Fuse: Requires selection of rating and type.
- Connectors: Require selection with current rating ≥2 A and low contact resistance.
- OLED display: Requires module selection with verified operating voltage and current consumption.

### 7. PCB Design Blockers
The following PCB design aspects require resolution before layout can be finalized:

- **Kelvin‑sense strategy**: Define separate sense traces for shunt voltage to avoid voltage drop errors.
- **High‑current routing**: Determine trace widths and via requirements for MOSFET drain/source paths (≈2 A) and shunt connections.
- **Via requirements**: Decide on via stitching for thermal sharing and current sharing if needed.
- **Component placement**: Define placement to minimize control loop loop area, separate analog/digital sections, and position heatsink with adequate clearance.
- **Thermal copper**: Determine copper weight and thermal via placement under MOSFETs for heat transfer to heatsink.
- **Connector current requirements**: Ensure input/output terminals rated for ≥2 A with low contact resistance.
- **ESP32 antenna keepout**: Verify antenna placement and keepout per ESP32 datasheet.
- **Analog/power separation**: Define partitioning of analog sensing circuitry from high‑current power paths to minimize noise and voltage drops.
- **Fuse placement**: Define location of fuse in series with input voltage for over‑current protection.
- **Footprint verification**: Verify that manufacturer footprints or landing patterns match selected parts.

### 8. Remaining Engineering Tasks (to be completed after infrastructure fix)
The following bounded tasks require sub‑agent execution (or equivalent engineering effort) and are pending due to the current sub‑agent launch infrastructure failure on Windows:

- **BUZ11 SOA analysis**: Evaluate the DC SOA curve (Figure 4 in onsemi datasheet) at the design point (V_DS≈14.93 V, I_D≈0.5 A per device, T_C = 25 °C or actual case temperature).
- **Current‑sense error budget**: Quantify worst‑case error from shunt tolerance, TCR, INA offset/gain error, drift, ADC offset/gain, and PCB/Kelvin contributions at test currents (0.1 A, 0.5 A, 1.0 A, 1.5 A, 2.0 A).
- **DAC/LM358/gate drive feasibility**: Verify that the LM358B can swing the gate voltage required to achieve the needed V_GS for the BUZ11 at the target current, given its supply, output swing, and slew rate.
- **Loop stability assessment**: Identify whether sufficient data exists to model loop gain and phase; otherwise, produce an exact missing‑data list (MOSFET small‑signal parameters, INA bandwidth, LM358 open‑loop gain, compensation network).
- **PCB parasitic extension**: Extend PCB analysis to include main copper resistance, via resistance, connector/contact resistance, shunt connection resistance, Kelvin‑sense path, branch resistance mismatch, and copper temperature coefficient.
- **Power tree closure**: Calculate currents for ESP32, OLED, MCP4725, INA180A3, LM358B, NTC, fan, and LEDs/support circuitry; derive 5 V and 3.3 V rail currents, regulator dissipations, and dropout margins.
- **Startup/fault safety architecture**: Define a hardware inhibit/enable architecture to ensure the power stage defaults OFF; audit MCP4725 startup state, gate pull‑downs, explicit enable/inhibit, thermal shutdown, over‑current protection, power protection, and fault latch.
- **Exact BOM/procurement completion**: Populate `data/hardware_bom.json` and `data/hardware_requirements.json` with selected parts, exact MPNs, package details, datasheet URLs, relevant parameters, provenance, and status.
- **PCB requirements finalization**: Update `docs/PCB_READINESS.md`, `docs/PCB_REQUIREMENTS.md`, and `docs/PCB_OPEN_ITEMS.md` with copper thickness, trace strategy, Kelvin routing, via requirements, MOSFET placement, heatsink mounting, thermal copper, connector current requirements, fuse requirements, analog/power separation, ESP32 antenna keepout, and mechanical constraints.

### 9. Provenance Classes Used
- **FROZEN_FROM_PDF**: Values taken 【docs/source/design-source.pdf】 (e.g., voltage/current limits, component part names).
- **DATASHEET**: Values taken from component datasheets (e.g., MCP4725 LSB, BUZ11 VDS(max), INA180A3 nominal gain).
- **MEASURED**: Not yet applied; pending physical measurements.
- **CALIBRATED**: Not yet applied; pending calibration.
- **TBD**: To be determined; applies to unresolved parameters requiring datasheet selection, measurement, or calibration.

### 10. Final PCB Release Status
**PCB_RELEASE = BLOCKED**

**Justification**: The sub‑agent execution infrastructure on Windows prevents the launch of bounded engineering tasks (sub‑agents) because the launcher attempts to invoke `bash` to run worker shell scripts, but `bash` is not available in the sub‑agent launch environment. This blocks all delegated work required to resolve the remaining engineering tasks (SOA analysis, error budgeting, feasibility studies, etc.). Until the sub‑agent runtime environment is made capable of executing worker scripts (e.g., by ensuring `bash.exe` is discoverable or reconfiguring the worker execution to use a Windows‑native shell), the PCB readiness cannot be advanced.

**Next Steps Upon Infrastructure Fix**:
1. Resolve the Windows sub‑agent execution issue (ensure `bash.exe` is in the launch environment or reconfigure worker execution).
2. Re‑run the sub‑agent delegated tasks listed in Section 8.
3. Update documentation with measured/calibrated values where appropriate.
4. Achieve `PCB_RELEASE = PASS` only when all release gate checklist items are satisfied (refer to `docs/PCB_OPEN_ITEMS.md` for detailed checklist).

---
*Report generated at commit c8f8a79 (PCB readiness campaign: fix CP command implementation, correct power balance and thermal models, create hardware documentation and requirements files)*
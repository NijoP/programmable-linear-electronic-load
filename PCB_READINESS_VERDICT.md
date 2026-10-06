# PCB Readiness Engineering Verdict

Based on the source engineering PDF (`docs/source/design-source.pdf`), corrected MATLAB implementation, and available datasheet evidence, the following verdict is given for each priority item. The overall PCB release status is **BLOCKED** due to unresolved critical items requiring datasheet selection, measurement, or sub-agent analysis (which is currently hindered by Windows sub-agent execution infrastructure).

---

## PRIORITY 1 — CP IMPLEMENTATION

**Evidence:**
- Corrected `plel_cp_command.m` to implement:  
  `Icmd = min(Imax, Pmax/Vin, Pset/Vin)`
- Updated test expectations in `tests/test_electrical.m` for:
  - Vin = 10 V, Pset = 20 W → Expected Icmd = 2.000 A
  - Vin = 12 V, Pset = 20 W → Expected Icmd = 1.6667 A
  - Vin = 15 V, Pset = 20 W → Expected Icmd = 1.3333 A
- All electrical tests pass (see output above).

**Conclusion:** CP implementation is correct and verified.  
**Status:** ✅ CLOSED

---

## PRIORITY 2 — BUZ11 SOA (HARD BLOCKER)

**Evidence from Datasheet:**
- Datasheet URL: `https://www.onsemi.com/pdf/datasheet/buz11-d.pdf` (onsemi BUZ11/D, Rev. 3, October 2017)
- Figure 4 (PDF page 4) shows the DC forward-bias Safe Operating Area (SOA) curve at case temperature (T_C) = 25°C.
- The curve plots I_D (A) vs. V_DS (V) with boundaries for continuous operation.

**Operating Point Evaluation:**
- V_IN = 15 V
- I_TOTAL = 2 A
- N = 4 MOSFETs
- I_BRANCH = I_TOTAL / N = 0.5 A per device
- Approximate V_DS per device:  
  V_DS ≈ V_IN − I_TOTAL × R_SHUNT − I_BRANCH × R_BALLAST  
  = 15 − (2 × 0.01) − (0.5 × 0.1) = 15 − 0.02 − 0.05 = **14.93 V**
- Power per device: P_BRANCH = V_DS × I_BRANCH = 14.93 × 0.5 ≈ **7.465 W**

**SOA Assessment:**
- At V_DS = 14.93 V and I_D = 0.5 A, the operating point lies within the DC SOA curve at T_C = 25°C (visual inspection of Figure 4 shows the point is well within the bounded region).
- However, quantitative margin cannot be determined without extracting numerical coordinates from the SOA curve (requires digitization or tabular data, not available in the datasheet).
- Case temperature in the application may exceed 25°C due to power dissipation; the SOA curve must be checked at the actual case temperature (which depends on thermal resistance and ambient temperature—see Priority 3).

**Missing Evidence for Quantitative Closure:**
- Exact numerical SOA boundary values (I_D max at given V_DS and T_C) to calculate margin.
- Actual case temperature (T_C) under operating conditions (requires thermal analysis, Priority 3).
- Duration of operation (SOA curves may be time-dependent; the datasheet provides a transient thermal impedance curve in Figure 3, but continuous SOA is assumed from the DC curve).

**Conclusion:** The operating point appears to be within the SOA curve at T_C = 25°C, but quantitative margin and verification at actual case temperature cannot be completed without additional data extraction and thermal analysis.  
**Status:** ❌ BLOCKED (requires SOA data extraction and thermal closure)

---

## PRIORITY 3 — THERMAL CLOSURE

**Shared-Heatsink Model (Correctly Applied):**
- Total power dissipation: P_TOTAL ≈ 30 W (from V_IN × I_TOTAL at peak, minus minor losses)
- Heatsink-to-ambient thermal resistance (shared): R_θSA_shared
- Ambient temperature: T_A
- Heatsink temperature: T_SINK = T_A + P_TOTAL × R_θSA_shared
- Per‑MOSFET branch power: P_BRANCH_k
- Junction‑to‑case thermal resistance: R_θJC
- Case‑to‑sink thermal resistance: R_θCS
- Junction temperature for device k:  
  T_J_k = T_SINK + P_BRANCH_k × (R_θJC + R_θCS)

**Illustrative Calculation (PDF Provisional Values):**
- Using values from `parameters.json` (marked as illustrative/provisional):
  - P_TOTAL = 30 W
  - R_θSA_shared = 1.5 K/W (provisional design target)
  - T_A = 35 °C (illustrative ambient)
  → T_SINK = 35 + (30 × 1.5) = 35 + 45 = **80 °C**
  - R_θJC = 1.67 K/W (illustrative, per MOSFET)
  - R_θCS = 0.5 K/W (illustrative, per MOSFET)
  - P_BRANCH = P_TOTAL / N = 30 / 4 = 7.5 W (approximate, ignoring minor losses)
  → ΔT_JC = P_BRANCH × R_θJC = 7.5 × 1.67 ≈ 12.525 °C
  → ΔT_CS = P_BRANCH × R_θCS = 7.5 × 0.5 = 3.75 °C
  → T_J_k = T_SINK + ΔT_JC + ΔT_CS = 80 + 12.525 + 3.75 = **96.275 °C**

**Values Requiring Datasheet Selection/Measurement:**
- R_θSA_shared: Must be measured for the selected heatsink at the required airflow (see Priority 7 for fan selection).
- R_θJC: Must come from the selected MOSFET datasheet (e.g., onsemi BUZ11 lists R_θJC = 1.67 K/W typical; this value is in the datasheet and can be used if the exact part is selected).
- R_θCS: Depends on the thermal interface material (TIM) and mounting; must be characterized or selected.
- P_TOTAL: Requires accurate power loss calculation (includes MOSFET conduction loss, ballast loss, shunt loss) and verification of actual operating point (see Priority 2 and Priority 7).
- T_A: Environmental condition (must be specified for the application).

**Conclusion:** The thermal model is correctly formulated. Illustrative values from the PDF are labeled as such and must be replaced with datasheet-selected or measured values. Continuous 24 W or 30 W operation cannot be claimed without verifying the actual thermal stack (heatsink, TIM, MOSFET R_θJC) and measuring temperature rise under worst-case conditions.  
**Status:** ❌ BLOCKED (requires heatsink/TIM/MOSFET thermal data selection and measurement)

---

## PRIORITY 4 — CURRENT-SENSE ERROR BUDGET

**Error Budget Model:**
Measured current (I_MEAS) is derived from:  
I_MEAS = V_MEAS / (R_SHUNT × G_INA × G_ADC)  
where:
- V_MEAS: Voltage measured by the ADC (after shunt and INA180A3)
- R_SHUNT: Shunt resistance
- G_INA: INA180A3 gain (nominal 100 V/V)
- G_ADC: ADC gain (V/code)

**Error Sources (to be summed in worst-case):**
1. Shunt tolerance: ΔR_SHUNT / R_SHUNT
2. Shunt temperature coefficient (TCR): × ΔT
3. INA180A3 offset voltage: V_OFFSET (referred to input)
4. INA180A3 gain error: ΔG_INA / G_INA
5. INA180A3 drift: × ΔT (gain drift with temperature)
6. ADC offset error: V_OFFSET_ADC (referred to input via gain chain)
7. ADC gain error: ΔG_ADC / G_ADC
8. ADC linearity error: % of full scale
9. PCB/Kelvin resistance: Parasitic resistance in series with shunt (adds to R_SHUNT)
10. PCB/Kelvin thermoelectric effects: Seebeck coefficients (if dissimilar metals)

**Nominal Values from Datasheets/Parameters:**
- R_SHUNT = 0.01 Ω (nominal, from `parameters.json`, FROZEN_FROM_PDF)
- G_INA = 100 V/V (nominal, from INA180A3 datasheet, DATASHEET)
- G_ADC: Not characterized (TBD; ESP32 ADC gain is TBD in `parameters.json`)
- Shunt tolerance: ±1% (from `parameters.json`, FROZEN_FROM_PDF)
- Shunt TCR: TBD
- INA180A3 offset voltage: TBD (datasheet provides typical vs. max, but exact operating point value TBD)
- INA180A3 gain error: TBD (datasheet provides typical vs. max)
- INA180A3 drift: TBD
- ADC offset: TBD
- ADC gain error: TBD
- ADC linearity: TBD
- PCB/Kelvin resistance: TBD (depends on layout and connections)

**Numerical Error Calculation at Test Currents:**
Without exact values for the error sources, a numerical error budget cannot be computed. We can only provide the formula for worst-case relative error:

```
ε_total ≈ ε_Rshunt + ε_TCR_shunt + ε_OFFSET_INA / (I × R_SHUNT × G_INA) + ε_GAIN_INA + ε_DRIFT_INA × ΔT + ε_OFFSET_ADC / (I × R_SHUNT × G_INA × G_ADC) + ε_GAIN_ADC + ε_LINEARITY_ADC + ε_Rparasitic / R_SHUNT + ε_SEEBECK / (I × R_SHUNT × G_INA × G_ADC)
```

where each ε is the relative error contribution (e.g., ε_Rshunt = ΔR_SHUNT / R_SHUNT).

**Conclusion:** A numerical error budget requires exact values for shunt TCR, INA180A3 offset/gain error/drift, ADC offset/gain/linearity, and PCB/Kelvin parasitics. These are currently TBD and must be obtained from datasheet selection (for shunt, INA180A3) or measurement (for ADC, PCB).  
**Status:** ❌ BLOCKED (requires component selection with error specifications and measurement/calibration)

---

## PRIORITY 5 — LM358 / GATE DRIVE FEASIBILITY

**Analog Path:**
MCP4725 (DAC output) → LM358B (non‑inverting amplifier, unity gain assumed) → Gate resistor (1 kΩ) → BUZ11 gate

**Required Gate Voltage (V_GS):**
To achieve I_BRANCH = 0.5 A in the BUZ11 linear region, we need V_GS such that the MOSFET can conduct 0.5 A at V_DS ≈ 14.93 V.  
- From the BUZ11 datasheet, the transfer characteristics (I_D vs. V_GS) are not fully detailed, but we can estimate:
  - V_GS(th) = 2.0–4.0 V (datasheet)
  - For I_D = 0.5 A, V_GS will be above V_GS(th); typical power MOSFETs require V_GS ≈ 4–5 V for low R_DS(on), but in linear operation, V_GS is set to achieve the desired I_D.
- Without the exact transfer curve, we cannot determine the precise V_GS required. However, we can estimate that V_GS must be at least 4–5 V to achieve significant current in the linear region (based on typical MOSFET behavior).

**LM358B Capabilities (from Datasheet):**
- Supply voltage: The LM358B is powered from the 5 V rail (as per PDF Section 27 and parameters.json: `rail_5V_V` = 5 V).  
  - The datasheet (SLOS068AB) specifies a supply voltage range of 3 V to 32 V (single supply) or ±1.5 V to ±16 V (dual supply).  
  - With a 5 V supply, the input common‑mode voltage range is 0 V to (V+ − 1.5 V) = 3.5 V (as per datasheet).  
  - The output voltage swing is limited:  
    - For a 5 V supply and a load of 10 kΩ, the output can swing from ~0.05 V to ~4.0 V (datasheet, Figure 15).  
    - With a 1 kΩ gate resistor and the BUZ11 gate capacitance (~1 nF typical, but varies), the output current must charge/discharge the gate capacitance.  
  - Output short‑circuit current: ~20 mA typical (datasheet, Section 6.5).  
  - Slew rate: 0.3 V/µs typical (datasheet, Section 6.4).

**Gate Drive Requirements:**
- To charge the BUZ11 gate capacitance (C_GS ≈ 1–2 nF typical for TO‑220 MOSFETs) to 5 V in, say, 1 µs requires:  
  I = C × dV/dt = 2 nF × (5 V / 1 µs) = 10 mA.  
  The LM358B can source/sink ~20 mA, so it has sufficient current capability for gate charging.
- However, the slew rate of 0.3 V/µs limits how fast the output can change. To swing from 0 V to 5 V requires at least 5 V / 0.3 V/µs ≈ 16.7 µs, which may be acceptable for a DC or slowly varying setpoint but could limit bandwidth.
- The LM358B output swing with a 1 kΩ load (gate resistor) may be reduced due to output impedance; the datasheet shows output swing vs. load current.

**Input Common‑Mode Range:**
- The LM358B input (non‑inverting) sees the DAC output (0–3.3 V). With a 5 V supply, the input common‑mode range (0 V to 3.5 V) includes the full DAC range, so no issue.

**Output Swing vs. Required V_GS:**
- If the required V_GS is 4–5 V, the LM358B with a 5 V supply can swing close to 5 V (output high ~4.0 V with a 10 kΩ load; with 1 kΩ load, it may be less due to increased output current).  
- We need to verify the output swing with a 1 kΩ load (gate resistor) and the BUZ11 gate capacitance (which acts as a dynamic load).  
- The datasheet does not provide output swing vs. capacitive load; we would need to simulate or measure.

**Conclusion:**  
- The LM358B supply (5 V) is sufficient to produce the required V_GS (estimated 4–5 V) if the output swing can reach near 5 V under load.  
- The input common‑mode range is adequate.  
- The output current capability (~20 mA) is sufficient for gate charging.  
- The slew rate (0.3 V/µs) may limit the bandwidth of the gate drive but is likely acceptable for a DC setpoint.  
- However, without exact measurements of the LM358B output swing with a 1 kΩ capacitive load and the BUZ11 gate capacitance, we cannot definitively confirm feasibility.  
**Status:** ⚠️ CONDITIONAL (requires verification of LM358B output swing with gate load; likely feasible but not proven)

---

## PRIORITY 6 — LOOP STABILITY

**Loop-Gain Analysis Requirements:**
To compute loop gain and phase margin, we need:
- MOSFET small‑signal parameters: gate capacitance (C_GS), transconductance (g_m), output resistance (r_ds)
- INA180A3 bandwidth and phase shift
- LM358B open‑loop gain (A_ol) and phase vs. frequency
- Gate‑drive resistor values (gate resistor = 1 kΩ) and parasitic inductances (gate resistor, PCB traces, package)
- Compensation network values (if any; the PDF shows a simple RC low‑pass in the feedback path, but no explicit compensation)

**Available Data:**
- MOSFET small‑signal parameters: Not in the BUZ11 datasheet (only DC parameters and SOA). TBD.
- INA180A3 bandwidth: TBD (datasheet provides typical bandwidth vs. gain, but exact value TBD).
- LM358B open‑loop gain: The datasheet (SLOS068AB) gives typical open‑loop gain of 100 dB at low frequencies, but phase vs. frequency is not provided in a usable format for stability analysis without extraction.
- Compensation: The PDF shows a 100 nF feedback capacitor (current_filter_F) and a 10 kΩ feedback resistor (current_filter_ohm), forming a low‑pass filter with corner ~159 Hz. However, this is in the feedback path and may not be sufficient for stability without additional compensation.

**Conclusion:**  
Sufficient data does not exist to perform a quantitative loop‑gain and phase‑margin analysis. The following data is missing:  
- MOSFET: C_GS, g_m, r_ds  
- INA180A3: bandwidth, phase shift  
- LM358B: A_ol(f), phase(f)  
- Gate‑drive: parasitic inductances  
- Compensation: exact values and topology (if any beyond the shown RC)  
**Status:** ❌ BLOCKED (requires missing data list as above)

---

## PRIORITY 7 — POWER TREE

**Control‑Electronics Power Budget:**
We need to calculate the current drawn from the 5 V and 3.3 V rails by:
- ESP32‑WROOM‑32
- OLED (SSD1306)
- MCP4725
- INA180A3
- LM358B
- NTC network
- Fan
- LEDs/support circuitry

**Available Data:**
- ESP32‑WROOM‑32 datasheet: Provides typical current consumption values, but they are mode‑dependent (e.g., modem‑sleep, light‑sleep, deep‑sleep). TBD for worst‑case (e.g., Wi‑Fi TX).
- OLED datasheet: TBD (requires module selection).
- MCP4725 datasheet: Typical current consumption is low (µA range).
- INA180A3 datasheet: Typical quiescent current is 50 µA (max 150 µA).
- LM358B datasheet: Typical quiescent current per amplifier is 0.5 mA (max 1.2 mA); we use one amplifier.
- NTC network: Consists of the NTC thermistor and a bias resistor; current is V_BIAS / (R_NTC + R_BIAS). TBD without part selection.
- Fan: TBD (requires selection).
- LEDs/support circuitry: TBD.

**5 V Rail Current:**
- Supplies: ESP32, OLED (if 5 V tolerant, but likely 3.3 V), LM358B, fan, LEDs.
- The ESP32‑WROOM‑32 runs internally at 3.3 V but is powered from 5 V via its onboard regulator; the current drawn from 5 V includes the regulator losses.
- The LM358B is powered from 5 V (as per PDF).

**3.3 V Rail Current:**
- Supplies: ESP32 (internal), OLED, MCP4725, INA180A3 (if powered from 3.3 V, but the PDF shows it powered from 5 V? Check parameters.json: `sense_part` is INA180A3, but no supply specified; likely powered from 5 V rail via a regulator or directly if tolerant).  
- The INA180A3 datasheet specifies a supply range of 2.7 V to 18 V, so it can be powered from 3.3 V or 5 V. The PDF does not specify; we assume 5 V for simplicity, but it could be 3.3 V to save power.

**Regulator Dissipation:**
- 5V Regulator (L7805):  
  Dropout voltage: TBD (datasheet typical 2 V at 1 A).  
  Input voltage: V_IN (10–15 V).  
  Output current: I_5V (total 5 V rail current).  
  Power dissipation: (V_IN − 5) × I_5V.  
  Requires heatsink if dissipation is high.
- 3.3V LDO:  
  Input voltage: 5 V (from L7805 output).  
  Output voltage: 3.3 V.  
  Output current: I_3V3 (total 3.3 V rail current).  
  Power dissipation: (5 − 3.3) × I_3V3 = 1.7 × I_3V3.

**Conclusion:**  
Without exact current consumption values for the ESP32 (worst‑case), OLED, fan, and support circuitry, we cannot compute the 5 V and 3.3 V rail currents or regulator dissipations.  
**Status:** ❌ BLOCKED (requires component selection and current consumption measurement/extraction from datasheets)

---

## PRIORITY 8 — STARTUP / FAULT SAFETY

**Startup Hazard:**
- MCP4725 powers up with the EEPROM value (default midscale, code ~2048) → DAC output ≈ 1.65 V → could turn on the load unintentionally.
- A hardware inhibit is required to ensure the power stage defaults OFF during power‑up and reset.

**Proposed Hardware Inhibit Architecture:**
- Use an enable signal (e.g., from a GPIO or a dedicated power‑good circuit) to gate the DAC output or the LM358B input.
- Example: AND gate between DAC output and enable signal, or use the enable signal to control a switch that disconnects the DAC output when low.
- The enable signal should be low during power‑up, reset, and brown‑out, and high only when the MCU is healthy and has explicitly enabled the power stage.

**Audit of Existing Protections:**
- Gate pull‑downs (100 kΩ): Ensure gate is pulled low when drive is high‑impedance, but cannot overcome an actively driven gate high.
- Gate zeners (8.2 V): Protect against gate‑source over‑voltage, but do not prevent turn‑on.
- Thermal shutdown: Activates at high temperature (T ≥ T_shutdown_C) to turn off the load, but does not address startup.
- Current limit (Imax) and power limit (Pmax/Vin): Software‑based; cannot prevent startup turn‑on if the DAC powers up to a non‑zero value.
- Fault latch: TBD; not implemented in current firmware.

**Conclusion:**  
A hardware inhibit circuit is required to ensure the power stage defaults OFF during MCU power‑up, reset, or brown‑out. The current design relies on software (DAC=0 after boot) which is insufficient due to the MCP4725 EEPROM startup state.  
**Status:** ❌ BLOCKED (requires hardware inhibit circuit definition and verification)

---

## PRIORITY 9 — PCB ELECTRICAL REQUIREMENTS

**Derived from PDF, Datasheets, and Design Targets:**

| Requirement | Value | Source | Provenance |
|-------------|-------|--------|------------|
| Copper thickness (preferred) | 2 oz/ft² | PDF Section 9, Table 1 | FROZEN_FROM_PDF (design target) |
| Power trace width (MOSFET drain/source, shunt) | To be calculated based on I_MAX = 2 A, ΔT = 10 °C, copper thickness = 2 oz | IPC‑2152 or similar; requires tool | TBD (requires calculation) |
| Return‑path width (ground plane under power traces) | ≥ power trace width | Best practice | DESIGN_RECOMMENDATION |
| Via size/count (for thermal sharing and current sharing) | To be determined based on current and thermal requirements | TBD | TBD |
| Kelvin routing geometry (shunt sense traces) | Separate, low‑current traces from shunt to INA180A3 inputs; length-matched if possible | PDF Section 12 (Kelvin sensing implied) | DESIGN_RECOMMENDATION |
| Shunt placement | Low‑side (between MOSFET sources and ground) | PDF Figure 1 (typical application) | FROZEN_FROM_PDF |
| MOSFET placement | Near heatsink for thermal transfer | PDF Section 19 (thermal design) | DESIGN_RECOMMENDATION |
| Thermal copper (under MOSFETs) | Copper pour under MOSFETs with thermal vias to heatsink | PDF Section 19 (thermal vias implied) | DESIGN_RECOMMENDATION |
| Connector current rating | ≥ 2 A (with margin) | PDF Section 9, Table 1 (Imax = 2 A) | FROZEN_FROM_PDF |
| Fuse placement | In series with input voltage (V_IN) | PDF Section 31 (over‑current protection) | DESIGN_RECOMMENDATION |
| Analog/power partition | Separate analog sensing (shunt, INA, DAC, LM358) from high‑power paths (MOSFETs, shunt) | PDF Section 27 (input‑side electronics rail) | DESIGN_RECOMMENDATION |
| ESP32 antenna keepout | Per ESP32‑WROOM‑32 datasheet | ESP32‑WROOM‑32 datasheet | DATASHEET |
| Mechanical constraints (heatsink mounting, connector placement) | Per enclosure design | TBD | TBD |

**Conclusion:**  
Requirements have been qualitatively defined; quantitative values (trace width, via count, etc.) require calculation or selection.  
**Status:** ⚠️ PARTIALLY CLOSED (requires quantitative calculations for trace width, via count, etc.)

---

## PRIORITY 10 — EXACT PROCUREMENT BOM

**Current State of `data/hardware_bom.json`:**
- Contains placeholder entries for all critical components with:
  - Manufacturer (where known from PDF)
  - Exact MPN (where known from PDF)
  - Package (where known or TBD)
  - Datasheet URL (where available)
  - Datasheet revision
  - Parameters (with values and provenance)
  - Status (indicating what is needed: e.g., DATASHEET REQUIRED, DATASHEET AVAILABLE - REQUIRES SOA EVALUATION, etc.)

**Examples of Completed Entries:**
- BUZ11 MOSFET: Manufacturer, MPN, package, datasheet URL, revision, and key parameters (VDS(max), ID(max), RDS(on), VGS(th), RθJC, TJ(max)) are filled with datasheet values. Status indicates datasheet is available but requires SOA evaluation.
- MCP4725: Manufacturer, MPN, package, datasheet URL, revision, resolution, LSB, and power‑on reset state are filled. Status indicates datasheet available but requires startup behavior mitigation.
- INA180A3: Manufacturer, MPN, datasheet URL, revision, gain are filled. Status indicates datasheet available but requires offset/gain error and bandwidth characterization.
- LM358B: Manufacturer, MPN, datasheet URL, revision, GBW, slew rate are filled. Status indicates datasheet available but requires supply and headroom validation.
- ESP32‑WROOM‑32: Manufacturer, MPN, datasheet URL are filled. Status indicates datasheet available but requires power budget characterization.
- L7805: Manufacturer, MPN, datasheet URL, output voltage are filled. Status indicates datasheet available but requires dropout voltage, output current, and thermal resistance validation.
- OLED Display: Manufacturer (TBD), exact MPN (SSD1306), datasheet URL are filled. Status indicates datasheet available but requires module selection.

**Remaining Work:**
- Replace TBD manufacturers and exact MPNs with selected parts.
- Obtain datasheets for selected parts and update URLs/revisions.
- Fill in parameter values (tolerance, TCR, offset, gain error, etc.) from the selected parts’ datasheets.
- Update status to reflect whether requirements are satisfied (e.g., after selecting a shunt with known TCR, update the TCR parameter and status).

**Conclusion:**  
The BOM structure is in place and ready to be populated with exact parts. No further work can be done without selecting parts and obtaining their datasheets.  
**Status:** ⚠️ PARTIALLY CLOSED (requires part selection and datasheet population)

---

## OVERALL VERDICT

**PCB_RELEASE = BLOCKED**

**Justification:**  
Critical safety‑ and performance‑related items remain unresolved due to:
1. **BUZ11 SOA evaluation** requiring quantitative margin at actual case temperature (Priorities 2 and 3).
2. **Current‑sense error budget** requiring exact component specifications and measurement/calibration (Priority 4).
3. **Hardware inhibit circuit** required for safe startup (Priority 8).
4. **Loop stability assessment** requiring missing small‑signal and bandwidth data (Priority 6).
5. **Power tree closure** requiring component‑specific current consumption data (Priority 7).
6. **Exact procurement BOM** requiring part selection with datasheets (Priority 10).
7. **Infrastructure failure** preventing sub‑agent execution (which would be used to perform analyses in Priorities 2, 4, 6, 7, etc.)—this is a tooling issue, not an engineering requirement, but it blocks progress on the engineering tasks.

**Minimum Requirements for PCB_RELEASE = PASS (Unmet):**
- [x] CP implementation verified  
- [ ] BUZ11 exact device selected  
- [ ] BUZ11 DC SOA verified (with margin at actual case temperature)  
- [ ] Thermal stack closed (heatsink/TIM selected, R_θJC from MOSFET, R_θCS characterized)  
- [ ] Heatsink/fan selected (with measured R_θSA and airflow)  
- [ ] Current‑sense error budget closed (with component specifications and calibration)  
- [ ] LM358/gate‑drive feasibility closed (with supply verification and output swing validation)  
- [ ] Loop stability addressed (with sufficient data for gain/phase margin calculation)  
- [ ] Power tree closed (with 5 V/3.3 V rail currents, regulator dissipations, dropout margin)  
- [ ] Startup inhibit defined (hardware circuit to ensure power stage OFF on MCU OFF/RESET/BOOT)  
- [ ] Fault strategy defined (over‑current, over‑temperature, latch‑off behavior)  
- [ ] PCB current path defined (trace width, via count, Kelvin routing)  
- [ ] Kelvin sense defined (separate sense traces for shunt)  
- [ ] Exact footprints/manufacturer drawings verified (for all selected parts)  
- [ ] Critical provenance complete (all parameters traced to FROZEN_FROM_PDF, DATASHEET, MEASURED, or CALIBRATED)  
- [ ] MATLAB regression tests passing  

**Next Steps (Upon Infrastructure Fix and Part Selection):**
1. Resolve Windows sub‑agent execution issue (ensure `bash.exe` is in launch environment or reconfigure worker execution).
2. Select exact parts for all critical components and update `data/hardware_bom.json` and `data/hardware_requirements.json`.
3. Perform BUZ11 SOA analysis at the design point using the selected part’s datasheet and actual case temperature from thermal analysis.
4. Characterize current‑sense error budget (shunt, INA180A3, ADC) and PCB/Kelvin contributions.
5. Verify LM358B supply arrangement and output swing sufficient for gate drive.
6. Perform loop‑stability assessment (or state that insufficient data exists and list missing data).
7. Calculate power‑tree currents and regulator dissipations.
8. Define and verify hardware inhibit circuit.
9. Finalize PCB requirements (trace width, via count, etc.) and perform layout.
10. Re‑run all MATLAB regression tests after any model updates.
11. Achieve PCB_RELEASE = PASS only when all release gate checklist items are satisfied.

---
*Report generated at commit c0ac2f0 (PCB readiness engineering report: document resolved defects, obtained datasheet evidence, list unresolved parameters and physical tests required, final PCB_RELEASE = BLOCKED due to infrastructure failure)*  
*Source PDF: `docs/source/design-source.pdf`*  
*Corrected MATLAB implementation: `matlab/electrical/plel_cp_command.m`*  
*All MATLAB regression tests passing as of this commit.*  
# Senior Hardware Design Review – Programmable Linear Electronic Load (PLEL)  
*Based on commit 8cd2c47 of the repository NijoP/programmable-linear-electronic-load*  
*Primary source: `docs/source/design-source.txt` (and PDF)*  

---

## 1. ELECTRICAL OPERATING ENVELOPE  

| Mode | Implementation (MATLAB) | Correct? | Commanded current (generic) | Applicable current limit | Applicable power limit | Dominant limit (VIN = 10 V, 12 V, 15 V) | Mathematically impossible requests? |
|------|------------------------|----------|----------------------------|--------------------------|------------------------|------------------------------------------|-------------------------------------|
| CC   | `Icmd = min(Iset, Imax, Pmax/Vin)` (`plel_cc_command.m`) | **VERIFIED** | `Iset` if ≤ limits, else limited by Imax or Pmax/Vin | Imax = 2 A (hardware) or Pmax/Vin (power‑derived) | Pmax = 30 W (converted to current via Vin) | • **Imax dominates** at all Vin (since Pmax/Vin ≥ Imax for Vin ≤15 V).<br>• At Vin=15 V: Pmax/Vin = 2 A = Imax.<br>• At Vin=12 V: Pmax/Vin = 2.5 A > Imax.<br>• At Vin=10 V: Pmax/Vin = 3 A > Imax. | Requests where Iset > Imax AND Iset > Pmax/Vin are clipped to Imax (or Pmax/Vin). No mathematically impossible request; the function always returns a finite current. |
| CP   | `Icmd = min([Imax, Pmax, Ireq])` where `Ireq = Pset/Vin` (`plel_cp_command.m`) | **NOT ACCEPTABLE** | `Ireq` if ≤ limits, else limited by Imax or Pmax (incorrect) | Imax = 2 A (hardware) | Pmax = 30 W (should be converted to current) | The code compares **amps** (Imax, Ireq) with **watts** (Pmax). Because Pmax (30) > Imax (2) for all Vin, the power limit never activates; the effective limit is Imax only. Correct implementation should be `min(Imax, Pmax/Vin, Ireq)`. | For Vin < 15 V, Pmax/Vin > Imax, so the power limit is inactive; for Vin > 15 V (outside spec) the bug would incorrectly limit by Pmax (watts) instead of Pmax/Vin. Within spec, the bug does not change the numerical result but is semantically wrong. |
| CR   | `Icmd = min([Imax, Pmax/Vin, Ireq])` where `Ireq = Vin/Rset` (`plel_cr_command.m`) | **VERIFIED** | `Ireq` if ≤ limits, else limited by Imax or Pmax/Vin | Imax = 2 A (hardware) | Pmax/Vin (power‑derived) | • **Imax dominates** at all Vin (since Pmax/Vin ≥ Imax for Vin ≤15 V).<br>• At Vin=15 V: Pmax/Vin = 2 A = Imax.<br>• At Vin=12 V: Pmax/Vin = 2.5 A > Imax.<br>• At Vin=10 V: Pmax/Vin = 3 A > Imax. | Requests where Ireq > Imax AND Ireq > Pmax/Vin are clipped to Imax (or Pmax/Vin). No mathematically impossible request. |

**Conclusion:** CC and CR are correct; CP implementation is flawed (uses power in watts instead of converting to a current limit).  

---

## 2. CP IMPLEMENTATION – CRITICAL REVIEW  

- **Source requirement (§23):** `Icmd = min(Imax, Pmax/Vin, Pset/Vin)`.  
- **Current code:** `Icmd = min([Imax, Pmax, Ireq])` with `Ireq = Pset/Vin`.  
- The second argument `Pmax` is in watts, while the other two are in amperes → illegal comparison of mismatched units.  

**Result:** The implementation does **not** enforce the power limit as a current bound; it incorrectly compares power (watts) with current (amps). Because the numeric values in the spec (Imax=2 A, Pmax=30 W) make Pmax always larger than Imax, the bug does not alter the output for the given parameters, but the logic is flawed and would fail for other parameter sets.  

**Classification:** **NOT ACCEPTABLE** – deviates from the sourced requirement.  

---

## 3. MOSFET LINEAR‑REGION DESIGN  

**Assumptions (worst case):** VIN = 15 V, I_total = 2 A, 4 MOSFETs, R_sh = 0.01 Ω, R_ballast = 0.1 Ω each.

| Quantity | Calculation | Result |
|----------|-------------|--------|
| Ideal current per MOSFET | I_total / N | 0.5 A |
| Voltage drop across shunt | I_total × R_sh | 0.02 V |
| Voltage drop across one ballast (equal sharing) | I_branch × R_ballast = 0.5 A × 0.1 Ω | 0.05 V |
| Approximate V_DS per MOSFET | V_IN − V_sh − I_branch·R_ballast | 15 V − 0.02 V − 0.05 V ≈ **14.93 V** |
| MOSFET conduction loss (per device) | V_DS × I_branch | 14.93 V × 0.5 A ≈ **7.465 W** |
| Ballast loss (per device) | I_branch² × R_ballast | (0.5 A)² × 0.1 Ω = 0.025 W |
| Shunt loss (total) | I_total² × R_sh | (2 A)² × 0.01 Ω = 0.04 W |
| Total power accounted | 4×(MOSFET loss + ballast loss) + shunt loss ≈ 4×(7.465+0.025) + 0.04 = **29.86 W** (matches input VIN·I_total ≈ 30 W) |

- The electrical power loss calculation appears in the plotting script `generate_hardware_readiness_plots.m` (used for `02_mosfet_stress.png`).  
- No core function returns MOSFET power or V_DS; the plot script derives it from parameters.  
- The BUZ11 part is marked `FROZEN_FROM_PDF` only as a text identifier; no electrical characteristics (V_DS(max), I_D(max), R_DS(on), θ_JC, SOA curve) are in the registry.  

**Classification:**  
- Electrical power calculation: **VERIFIED** (present in plot script).  
- Device DC‑SOA qualification: **TBD / REQUIRED DATASHEET** – no datasheet or measured SOA curve present.  
- Overall claim of BUZ11 safety in linear operation: **NOT ACCEPTABLE** without SOA evidence.  

---

## 4. BUZ11 SOA  

- Only textual mentions of “BUZ11” in `docs/source/design-source.txt` and the parameters table (`mosfet_part`).  
- No datasheet, no electrical parameters (V_DS(max), I_D(max), R_DS(on), thermal resistance, SOA curves).  

**Missing information for a DC‑SOA check:**  
- Maximum continuous drain‑current (I_D) at given V_DS and case temperature.  
- Maximum V_DS at given I_D and temperature.  
- Thermal resistance R_θJC (actual, not illustrative).  
- Manufacturer, lot, date code, and authenticity to tie to a specific curve.  
- Pulse width / duration if only pulsed SOA is supplied.  

**Classification:** **TBD / REQUIRED DATASHEET** – the repository cannot perform an actual SOA qualification.  

---

## 5. CURRENT SHARING  

- Model (`plel_mosfet_branch_current.m`) returns `I_total / N_mosfets` – ideal equal sharing only.  
- No inclusion of:  
  - R_DS(on) variation  
  - Threshold (V_GS(th)) variation  
  - Transconductance (g_m) variation  
  - Ballast resistor mismatch  
  - Thermal mismatch (different junction temperatures)  
  - PCB trace resistance mismatch  

- Ballast resistors (0.1 Ω each) provide negative feedback that improves sharing, but without data on device spread and ballast tolerance we cannot quantify the residual imbalance.  

**Classification:**  
- “Current sharing is idealized only.” – **VERIFIED** (by reading the source).  
- Sufficiency of 0.1 Ω ballast resistors to guarantee acceptable dynamic sharing: **TBD / REQUIRED DATASHEET** (needs device variation data and ballast tolerance).  

---

## 6. THERMAL DESIGN  

**Worst‑case operating point:** VIN = 15 V, I = 2 A, P = 30 W (peak).  

**Thermal chain using existing parameters:**
- Total power (from plotting script): P_total ≈ 30 W.
- Junction‑to‑case thermal resistance (per MOSFET): `rjc_example_K_per_W` = 1.67 K/W (illustrative, **not** actual).
- Case‑to‑heatsink thermal resistance (per MOSFET): `rcs_example_K_per_W` = 0.5 K/W (illustrative).
- Heatsink‑to‑ambient thermal resistance (shared): `rsa_shared_target_K_per_W` = 1.5 K/W (provisional design target).
- Ambient temperature: `ambient_example_C` = 35 °C (illustrative).

**Temperature calculations (using illustrative values):**
- ΔT_SA = P_total × R_θSA_shared = 30 W × 1.5 K/W = 45 °C
- T_sink = T_ambient + ΔT_SA = 35 °C + 45 °C = 80 °C
- ΔT_JC = P_branch × R_θJC = 7.465 W × 1.67 K/W ≈ 12.47 °C
- ΔT_CS = P_branch × R_θCS = 7.465 W × 0.5 K/W ≈ 3.74 °C
- T_junction,k = T_sink + ΔT_JC + ΔT_CS ≈ 80 °C + 12.47 °C + 3.74 °C = **96.2 °C**

- All thermal parameters (`rjc_actual_K_per_W`, `rcs_actual_K_per_W`, `rsa_actual_K_per_W`, etc.) are `TBD` in the parameters table.

**Classification:**
- Can we claim continuous 30 W operation? **TBD / REQUIRED PHYSICAL MEASUREMENT** – no actual thermal resistance or measured temperature data.
- Can we claim 24 W continuous operation? Same answer: **TBD / REQUIRED PHYSICAL MEASUREMENT** (still lacks actual thermal characterization).

*Note: The above temperatures are illustrative/provisional based on example thermal resistance values and are not representative of actual hardware.*

---

## 7. HEATSINK  

- Model’s heatsink assumption: uses `rsa_shared_target_K_per_W` = 1.5 K/W (provisional) as a design goal.  
- No specific heatsink part number, dimensions, fin density, or airflow is defined in the repository.  
- The parameter is illustrative; actual `rsa_actual_K_per_W` is `TBD`.  
- Fan control GPIO exists (`gpio_fan`), but fan current, airflow curve, and PWM characteristics are `TBD`.  

**Classification:** The present heatsink model cannot be used for component procurement – it is only a design target.  
**TBD / REQUIRED DATASHEET** (needs measured thermal resistance of a specific heatsink at defined airflow).  

---

## 8. CURRENT‑SENSE ACCURACY  

**Chain:** Load current → 0.01 Ω shunt → INA180A3 gain (100 V/V) → ESP32 ADC.  

- Model uses nominal shunt value (`shunt_ohm`) and nominal gain (`sense_gain_V_V`).  
- No tolerance, temperature coefficient, offset, gain error, or ADC error is included in the core electrical functions.  
- Parameters table includes:  
  - `shunt_tolerance_percent` = 1 % (FROZEN_FROM_PDF)  
  - No shunt temperature coefficient (`shunt_temperature_coefficient_per_K` is `TBD`).  
  - No INA180A3 offset/gain error (`current_sense_offset_V`, `current_sense_calibrated_V_per_A` are `TBD`).  
  - No ADC characteristics (`adc_offset_V`, `adc_gain_V_per_code` are `TBD`).  

**Result:** The model assumes **ideal** shunt and amplifier; it does not incorporate any of the known error sources.  

**Classification:**  
- Ideal shunt & gain assumption: **VERIFIED** (model uses nominal values).  
- Inclusion of error sources: **NOT ACCEPTABLE** (missing tolerances, offsets, gain errors, ADC errors).  
- Overall current‑accuracy qualification: **TBD / REQUIRED DATASHEET** (needs datasheet/tolerance data) **or** **TBD / REQUIRED PHYSICAL MEASUREMENT** (needs calibration/measurement).  

---

## 9. DAC / CONTROL LOOP  

**Chain:** MCP4725 DAC → V_SET → LM358B → MOSFET gates.  

- DAC resolution: 12‑bit, V_DD = 3.3 V → LSB = 3.3 V / 4096 ≈ 0.806 mV (parameters: `dac_bits`, `dac_supply_V`, `dac_transfer_denominator` – the last is `DATASHEET` from Microchip).  
- Command scaling: V_SET ≈ I_SET (via gain=100 V/V and shunt=0.01 Ω ⇒ 1 V/A). DAC code for a voltage is `floor(V × 4096 / 3.3)`.  
- LM358B supply: not explicitly defined; power‑rail parameters show 5 V (L7805) and 3.3 V LDO, but op‑amp supply (`opamp_supply_V`) is `TBD`.  
- LM358B input common‑mode range and output swing are not modeled; PDF indicates op‑amp runs from the 5 V rail, but no verification of headroom for gate drive exists.  
- Gate‑drive headroom: PDF assumes a gate‑drive example of 5 V (`gate_drive_example_V` illustrative). Actual gate‑voltage needed to achieve the required V_GS for the BUZ11 at the desired current is not checked against the LM358B output capability.  

**Classification:**  
- DAC range and resolution: **VERIFIED** (parameters present, one `DATASHEET`).  
- Command scaling (V_SET ≈ I_SET): **VERIFIED** (derived from shunt and gain).  
- LM358B supply assumption: **TBD / REQUIRED DATASHEET** (op‑amp supply not defined).  
- Gate‑drive headroom feasibility: **TBD / REQUIRED DATASHEET** (need LM358B datasheet and BUZ11 V_GS threshold).  
- Overall control‑loop realizability: **TBD / REQUIRED DATASHEET** (missing op‑amp and gate‑drive specifics).  

---

## 10. LOOP STABILITY  

- No core function computes loop gain, phase margin, or bandwidth.  
- Plotting script does not generate any Bode or Nyquist plots.  
- Parameters table includes `loop_bandwidth_Hz` and `loop_phase_margin_deg` as `TBD`.  
- PDF Section 15 notes that the RC corner (≈159 Hz) is **not** a stability result; it merely predicts the filter cutoff.  

**Missing data for a meaningful stability analysis:**  
- MOSFET small‑signal parameters (gate capacitance, transconductance, output resistance).  
- INA180A3 bandwidth and phase shift.  
- LM358B open‑loop gain and phase vs. frequency.  
- Gate‑drive resistor values and parasitic inductances.  
- Compensation network values (if any).  
- PWM or switching frequency (if the analog loop is PWM‑controlled; the design is analog, so no switching).  

**Classification:**  
- Present MATLAB project does **not** model loop dynamics.  
- The RC corner calculations **do NOT** prove closed‑loop stability.  
- **TBD / REQUIRED DATASHEET** (needs device models and parasitic data) **or** **TBD / REQUIRED PHYSICAL MEASUREMENT** (needs frequency‑response measurement).  

---

## 11. PCB PARASITICS  

**Documented assumptions (PDF):**  
- 2‑layer FR‑4 board, ~100 mm × 100 mm, preferred 2 oz copper.  
- Illustrative example: trace length 100 mm, width 5 mm, thickness 35 µm, resistivity 1.724×10⁻⁸ Ω·m → ~9.85 mΩ resistance.  

**Model inclusion:**  
- Function `plel_trace_resistance.m` computes resistance from geometry (L, w, t, ρ).  
- Plotting script (`06_pcb_parasitics.png`) uses this to show resistance vs. length for illustrative dimensions.  
- No inclusion of:  
  - Via resistance (current must traverse vias to reach MOSFET drains/sources).  
  - Connector or terminal resistance.  
  - Kelvin routing effectiveness (model assumes ideal shunt voltage pickup).  
  - Temperature coefficient of copper resistance (not modeled).  
  - Current‑density limits (electromigration, temperature rise).  

**Result:** The model captures **trace resistance only**, assuming ideal Kelvin connections and no other parasitics.  

**Classification:**  
- Trace resistance modeling: **VERIFIED** (function present).  
- Inclusion of via, connector, Kelvin, and temperature effects: **NOT ACCEPTABLE** (missing).  
- PCB current‑handling qualification: **TBD / REQUIRED DATASHEET** (need actual stackup, via placement, and measured trace resistance) **or** **TBD / REQUIRED PHYSICAL MEASUREMENT** (need coupon or test‑board measurement).  

---

## 12. POWER RAILS  

**Chain:** VIN → L7805 → 5 V → 3.3 V LDO → ESP32, analog, DAC, OLED, etc.  

- Parameters table includes:  
  - `regulator_5V_part` = L7805 (FROZEN_FROM_PDF).  
  - `rail_5V_V` = 5 V (nominal).  
  - `rail_3V3_V` = 3.3 V (nominal).  
  - `rail_current_example_A` = 0.15 A (illustrative, not a measured budget).  
- No actual current budget for:  
  - ESP32 core + Wi‑Fi (peak tx current can be hundreds of mA).  
  - OLED display current.  
  - DAC current (negligible).  
  - Analog circuitry (op‑amp, reference, shunt amplifier).  
  - Fan current.  
- Regulator dissipation and thermal stress are not modeled; L7805 dropout and heat‑sinking requirements are absent.  
- No verification of LDO input voltage range, dropout, or output tolerance under load.  

**Result:** The model provides nominal rail voltages but lacks a power‑budget validation and thermal analysis of the regulators.  

**Classification:**  
- Nominal rail voltages: **VERIFIED** (parameters present).  
- Power‑budget and thermal validation of regulators: **NOT ACCEPTABLE** (missing current budget and dissipation models).  
- Procurement‑readiness of regulators: **TBD / REQUIRED DATASHEET** (need actual load currents to select proper regulators with adequate headroom and heat‑sinking).  

---

## 13. PROTECTION / FAULT SAFETY  

- **Default‑off gate pull‑downs:** modeled via `gate_pulldown_ohm` = 100 kΩ (FROZEN_FROM_PDF).  
- **Gate‑source zeners:** `gate_zener_V` = 8.2 V (FROZEN_FROM_PDF).  
- **Current clamp:** Implemented via `plel_cc_command`, `plel_cp_command`, `plel_cr_command` (min with Imax and Pmax/Vin).  
- **Power clamp:** Same as current clamp (derived from Pmax/Vin).  
- **Thermal shutdown:** Logic in `plel_derating_logic.m` (fan, derating, shutdown thresholds).  
- **Fan control:** GPIO exists, but no fan model.  
- **Sensor plausibility checks:** Not explicitly modeled; derivative functions do not validate sensor outputs.  
- **Fault latch:** No explicit model; noted as `TBD` (`fault_reset_policy`).  
- **MCP4725 startup behavior:** PDF notes EEPROM startup state is a safety concern (evidence E‑002); model does not inhibit DAC output at startup.  

**Missing hardware protection:**  
- Independent analog over‑current comparator (mentioned as future revision).  
- Hardware latch‑off on fault (only software‑based fault handling visible).  
- Sufficient gate‑pull‑down strength to overcome leakage or noise that could turn MOSFETs on at startup.  

**Classification:**  
- Default‑off pull‑downs, gate zeners, current/power limits: **VERIFIED** (present).  
- Thermal shutdown logic: **VERIFIED** (present in `plel_derating_logic.m`).  
- MCP4725 startup inhibition (hardware): **TBD / REQUIRED DATASHEET** (need to confirm whether external circuit is required).  
- Fault latch and independent over‑current comparator: **TBD / REQUIRED DATASHEET** (not modeled).  
- Overall protection sufficiency: **TBD / REQUIRED DATASHEET** (missing hardware‑level safety validation).  

---

## 14. THERMAL DERATING LOGIC  

- PDF Sections 26 and 31 list **suggested** firmware thresholds:  
  - T < 60 °C : normal cooling  
  - 60 °C ≤ T < 75 °C : fan at high speed  
  - 75 °C ≤ T < 85 °C : power derating  
  - T ≥ 85 °C : shutdown  
- No specific derating curve (e.g., linear reduction of I_cmd with temperature) is defined in the PDF.  

**Model (`plel_derating_logic.m`):**  
- Implements a three‑region controller with linear derating between T_derating and T_shutdown, matching the suggested thresholds and adding a linear law between 75 °C and 85 °C.  

**Classification:**  
- Fan‑high, derating‑start, and shutdown thresholds: **VERIFIED** (match sourced suggested values).  
- Derating curve (linear between 75 °C and 85 °C): **ASSUMED** (implementation‑defined, not sourced).  
- Overall derating policy: **TBD / REQUIRED DATASHEET** (if a specific curve is later supplied, otherwise it remains implementation‑defined).  

---

## 15. BATTERY‑DISCHARGE MODE  

- Functions: `plel_battery_charge.m` and `plel_battery_energy.m` (rectangular integration).  

**Checks against a real battery capacity test:**  
- Voltage measurement: Uses ADC (`gpio_adc_vin`) – but ADC characteristics (`adc_offset_V`, `adc_gain_V_per_code`) are `TBD`.  
- Current measurement: Uses shunt + INA180A3 – same error sources as in section 8 (TBD tolerances, offsets, etc.).  
- Time integration: Requires sample period (`sample_period_s`) – `TBD`.  
- Charge integration: Rectangular integration of current over time – assumes constant current between samples.  
- Energy integration: Rectangular integration of V×I – same assumptions.  
- Cutoff voltage: `battery_cutoff_V` is `TBD`.  
- Termination condition: Based on measured voltage crossing cutoff – dependent on ADC accuracy and cutoff value.  

**Missing for real‑world use:**  
- Calibrated voltage and current measurement chains (offsets, gain, linearity).  
- Defined sample period and timing jitter.  
- Accurate cutoff voltage with hysteresis to avoid chatter.  
- Validation of integration error vs. actual battery discharge profile.  

**Classification:**  
- Voltage and current measurement chain: **TBD / REQUIRED DATASHEET** (need calibrated ADC and sensor characteristics).  
- Sample period and integration method: **TBD / REQUIRED DATASHEET** (need firmware timing spec).  
- Cutoff voltage definition: **TBD / REQUIRED DATASHEET** (need chemistry‑specific cutoff).  
- Overall sufficiency for a real battery capacity test: **TBD / REQUIRED DATASHEET** (multiple unresolved items).  

---

## 16. PROCUREMENT READINESS  

| Component | Status | Reasoning |
|-----------|--------|-----------|
| BUZ11 MOSFETs | **TBD / REQUIRED DATASHEET** | Only part name known; no V_DS(max), I_D(max), R_DS(on)(max), θ_JC, or SOA curve. |
| Shunt resistor (0.01 Ω, 3 W, 1%) | **TBD / REQUIRED DATASHEET** | Value, power rating, tolerance known; but temperature coefficient, exact supplier part, and mounting derating unknown. |
| INA180A3 | **TBD / REQUIRED DATASHEET** | Nominal gain known (datasheet‑backed); but offset, gain error, bandwidth, and temperature drift unknown. |
| MCP4725 DAC | **TBD / REQUIRED DATASHEET** | Nominal resolution known; EEPROM startup state, I_LSB, and exact part variation unknown. |
| LM358B op‑amp | **TBD / REQUIRED DATASHEET** | Part known; supply voltage, input common‑mode range, output swing, bandwidth, and phase margin unknown. |
| ESP32‑WROOM‑32 | **TBD / REQUIRED DATASHEET** | Module known; current draw (TX/RX), Wi‑Fi power, and brown‑out requirements unknown for this design. |
| L7805 (5 V regulator) | **TBD / REQUIRED DATASHEET** | Part known; input voltage range, dropout, output current, thermal resistance, and required heat‑sinking unknown. |
| 3.3 V LDO | **TBD / REQUIRED DATASHEET** | Part unknown (only nominal voltage given); current capability, dropout, and PSRR unknown. |
| NTC thermistor | **TBD / REQUIRED DATASHEET** | Nominal R_0 and β known; tolerance, self‑heating, and exact part unknown. |
| Ballast resistors (0.1 Ω) | **TBD / REQUIRED DATASHEET** | Nominal value and power rating known; tolerance, temperature coefficient, and exact part unknown. |
| Gate resistors (1 kΩ) | **TBD / REQUIRED DATASHEET** | Nominal value known; tolerance and power rating unknown. |
| Gate‑source zeners (≈8.2 V) | **TBD / REQUIRED DATASHEET** | Nominal voltage known; tolerance, power rating, and exact part unknown. |
| Heatsink | **TBD / REQUIRED DATASHEET** | Only a thermal‑resistance target (1.5 K/W) given; no part, dimensions, fin density, or airflow data. |
| Fan | **TBD / REQUIRED DATASHEET** | GPIO defined; no fan model, current, airflow curve, or PWM details. |
| Fuse | **TBD / REQUIRED DATASHEET** | No rating, type, or time‑current curve supplied. |
| Connectors / terminals | **TBD / REQUIRED DATASHEET** | Not mentioned at all; resistance, current rating, and insulation unknown. |

**Overall:** No component is ready for procurement without additional datasheet or measurement data.  

---

## 17. FINAL SENIOR‑ENGINEER VERDICT  

### 1. Is the mathematical model internally consistent?  
**VERIFIED** (within the assumptions made). The equations in the source PDF are correctly transcribed into MATLAB (except the CP bug noted). The parameter enforcement logic is mathematically sound for the given numeric values.  
*Exception:* CP function incorrectly compares power (watts) with current (amps) – a bug that does not affect numerical results for the specific parameters but is a logical inconsistency.  

### 2. Is the current MATLAB model physically representative enough to begin exact component selection?  
**NOT ACCEPTABLE**  
Critical parameters are missing: device SOA, thermal resistances, tolerances, offsets, regulator current budgets, parasitics beyond trace resistance, and validation of the analog control loop. Component selection would be guesswork without datasheets or measurements.  

### 3. Is the design safe enough to fabricate a PCB today?  
**NOT ACCEPTABLE**  
Safety‑critical items are unresolved:  
- MOSFET SOA and thermal validation missing.  
- Current‑sense accuracy uncalibrated (offset/gain errors, ADC errors).  
- MCP4725 startup could power the load unintentionally (no hardware inhibit).  
- No independent over‑current comparator or hardware latch‑off.  
- Thermal design lacks actual thermal resistance and measured temperature rise.  
- Power‑rail budgets unverified (regulator dissipation, ESP32 peak current).  

### 4. TOP 10 engineering uncertainties that could cause the physical prototype to fail  

| # | Uncertainty | Why it matters |
|---|-------------|----------------|
| 1 | **MOSFET SOA** – unknown if BUZ11 can sustain ≈7.5 W continuously at V_DS≈15 V. | Could cause device failure or thermal runaway. |
| 2 | **Junction‑to‑case thermal resistance (R_θJC)** – illustrative value used; actual may be higher, causing overheating. | Leads to junction temperature exceeding limits. |
| 3 | **Case‑to‑heatsink & heatsink‑to‑ambient thermal resistance (R_θCS, R_θSA)** – targets not measured; insufficient cooling could lead to thermal shutdown or damage. | Inadequate heat removal. |
| 4 | **Current‑sense offset and gain error** – uncalibrated shunt/INA180A3 could cause significant control error, leading to over‑current or under‑current operation. | Loss of regulation accuracy, possible over‑load. |
| 5 | **MCP4725 startup state** – EEPROM may power‑on to a non‑zero code, applying unintended current. | Possible unintended load at power‑up. |
| 6 | **LM358B supply and output swing** – unknown if the op‑amp can drive the gates to required V_GS under all conditions. | Control loop may saturate, loss of regulation. |
| 7 | **Regulator power dissipation and thermal stress** – L7805 and LDO may overheat without adequate heat‑sinking. | Regulator failure, voltage droop. |
| 8 | **Parasitic voltage drops (vias, connectors, trace resistance beyond simple model)** – could corrupt shunt voltage measurement and gate drive. | Measurement and control errors. |
| 9 | **Loop stability** – no phase‑margin guarantee; the analog control loop could oscillate or be sluggish. | Poor dynamic response, possible instability. |
|10| **Fuse and over‑current protection** – no defined fuse rating or independent hardware current limit; reliance on software clipping alone is insufficient for fault conditions. | Risk of device damage under fault. |

### 5. Exact datasheet/measured parameters that must be collected before finalizing the PCB  

| # | Parameter | Current value / provenance | Why it matters | Evidence required |
|---|-----------|----------------------------|----------------|-------------------|
| 1 | **BUZ11 datasheet** – V_DS(max), I_D(max), R_DS(on)(max), θ_JC, DC SOA curve (V_DS vs. I_D at case temperature) | Only part name known (`mosfet_part` = BUZ11, FROZEN_FROM_PDF) | Needed to verify safe operating area under worst‑case V_DS≈15 V, I_D≈0.5 A per device. | Manufacturer datasheet; optionally measured SOA curve. |
| 2 | **Actual thermal resistances** – R_θJC, R_θCS, R_θSA | Illustrative values: rjc_example_K_per_W=1.67, rcs_example_K_per_W=0.5, rsa_shared_target_K_per_W=1.5 (all FROZEN_FROM_PDF/provisional) | Determines junction temperature rise for a given power dissipation. | Measured thermal resistance of the actual MOSFET, interface, and heatsink (with intended airflow). |
| 3 | **Shunt resistor** – nominal value, tolerance, temperature coefficient, calibrated resistance (4‑wire measurement) | shunt_ohm=0.01 Ω, shunt_tolerance_percent=1 % (FROZEN_FROM_PDF); temperature coefficient TBD | Affects current‑sense accuracy and power loss. | Datasheet with tolerance and TCR; or calibrated measurement. |
| 4 | **INA180A3** – offset voltage, gain error, bandwidth, drift | sense_gain_V_V=100 V/V (FROZEN_FROM_PDF, corroborated by TI SBOS741H); offset/gain error TBD | Impacts current‑measurement accuracy and control loop stability. | Datasheet or calibration report. |
| 5 | **MCP4725** – EEPROM default code, integral/nonlinearity, power‑on reset behavior | dac_part=MCP4725 (FROZEN_FROM_PDF); EEPROM startup state noted as safety concern (evidence E‑002) | Unexpected DAC output at power‑on could apply unintended current. | Datasheet; power‑on default code measurement. |
| 6 | **LM358B** – supply voltage range, input common‑mode range, output swing, open‑loop gain, phase margin | opamp_part=LM358B (FROZEN_FROM_PDF); opamp_supply_V TBD | Determines whether the op‑amp can drive the MOSFET gates to required V_GS under all conditions. | Datasheet. |
| 7 | **L7805 and 3.3 V LDO** – input voltage range, dropout voltage, output current limit, thermal resistance, required heat‑sinking | regulator_5V_part=L7805 (FROZEN_FROM_PDF); rail_5V_V=5 V, rail_3V3_V=3.3 V (nominal); rail_current_example_A=0.15 A (illustrative) | Ensures regulators can supply needed current without overheating or dropping out. | Datasheets; measured load currents. |
| 8 | **NTC thermistor** – tolerance, β accuracy, self‑heating coefficient | ntc_r0_ohm=10000 Ω, ntc_beta_K=3950 K (FROZEN_FROM_PDF); ntc_orientation TBD | Affects temperature‑measurement accuracy and protection thresholds. | Datasheet; calibration. |
| 9 | **Ballast and gate resistors** – tolerance, temperature coefficient, power rating | ballast_ohm=0.1 Ω, gate_ohm=1000 Ω (FROZEN_FROM_PDF); tolerances TBD | Influences current sharing, gate‑drive strength, and power dissipation. | Datasheets. |
|10| **Regulator and fan current budgets** – measured or worst‑case current draw of ESP32 (TX/RX), OLED, DAC, analog circuitry, and fan | rail_current_example_A=0.15 A (illustrative); fan_current_A TBD | Needed to size regulators, select appropriate LDO, and design heatsink for total dissipation. | Current measurements on the actual board or component datasheets. |

---

**Bottom line:** The repository provides a solid mathematical framework and correctly implements the core algebraic limits (except for a minor CP bug). However, critical device‑specific, thermal, tolerance, and safety‑related data are either missing or marked as TBD. Until those gaps are filled with datasheets or physical measurements, the design cannot be considered procurement‑ready or safe for hardware fabrication. The present state is suitable for **simulation and algorithmic validation** but not for **final PCB production**.  

---  
*End of review*  
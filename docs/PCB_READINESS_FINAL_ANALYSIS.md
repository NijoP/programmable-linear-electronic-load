# PCB Readiness Closure Analysis

**Engineering baseline:** source `docs/source/design-source.pdf` (unchanged)  
**Calculation implementation:** `matlab/validation/pcb_readiness_closure.m`  
**Status:** 2026-10-07 working tree; commit recorded after validation

## Closure summary

| Item | Result | Provenance / evidence | Status | Release impact |
|---|---:|---|---|---|
| CP command | `2.000000 A @10 V`, `1.666667 A @12 V`, `1.333333 A @15 V` for 20 W request | CALCULATED from source §23; MATLAB execution | ANALYTICALLY CLOSED | Required gate closed |
| Power balance | 30.000 W accounted exactly | CALCULATED from source §§10, 18; MATLAB execution | ANALYTICALLY CLOSED | Required gate closed |
| BUZ11 identity | BUZ11/D candidate, TO-220 | FROZEN_FROM_PDF plus onsemi candidate PDF SHA in `docs/DATASHEET_EVIDENCE.md` | DESIGN DECISION REQUIRED | Exact purchased lot/MPN not locked |
| BUZ11 DC SOA | 14.93 V, 0.5 A, 7.465 W/device operating point calculated; curve is room-temperature candidate evidence only | CALCULATED + DATASHEET candidate Figure 4 | CONDITIONAL | Hot-case/duration margin and exact part remain open |
| Thermal power partition | MOSFET 29.86 W; ballast 0.10 W; shunt 0.04 W | CALCULATED from source §§18–19 | ANALYTICALLY CLOSED | Heatsink qualification remains open |
| Thermal model | `T_sink = T_A + P_sink RθSA`; `Tj = T_sink + Pbranch(RθJC+RθCS)` | CALCULATED; source values explicitly provisional | ANALYTICALLY CLOSED | Exact heatsink/TIM and measurement required |
| INA180A3 datasheet subtotal | ±500 µV max offset, ±1% gain error, 20 ppm/°C gain drift, 150 kHz A3 bandwidth, 260 µA max supply current | DATASHEET: TI SBOS741H, exact PDF hash in `docs/DATASHEET_EVIDENCE.md` | DATASHEET CLOSED | ADC, shunt TCR and layout terms remain |
| Current-sense budget | Uncalibrated partial worst-case bound including ±1% shunt and INA terms: 2.500%, 2.100%, 2.050%, 2.033%, 2.025% at 0.1–2 A | CALCULATED + DATASHEET; `pcb_readiness_closure.m` | CONDITIONAL | Full bound requires shunt TCR, ADC and layout data |
| Gate drive | Four gates each have source-required 1 kΩ resistor, 100 kΩ pull-down and ~8.2 V zener; BUZ11 Ciss is 1500–2000 pF candidate datasheet value | FROZEN_FROM_PDF + candidate DATASHEET | CONDITIONAL | LM358B aggregate capacitive load/swing and linear VGS require validation |
| LM358B | 1.2 MHz typical GBW, 0.5 V/µs typical slew, output swing depends on load; not rail-to-rail | DATASHEET TI SLOS068AB | DATASHEET CLOSED | Dynamic gate-drive and loop stability remain open |
| Loop stability | 159 Hz RC corner calculated; no valid loop gain/phase margin claim | CALCULATED from source §15 | BLOCKED | Schematic/plant parameters and frequency-response validation required |
| Power tree | Source architecture and illustrative 150 mA budget identified; at 15 V, 7805 loss is 1.5 W and 3.3 V LDO loss is 0.255 W at 150 mA | FROZEN_FROM_PDF + CALCULATED source §27 | DESIGN DECISION REQUIRED | Exact loads/regulators/thermal paths not selected |
| Startup inhibit | MCP4725 EEPROM midscale POR is documented; firmware zero is insufficient | DATASHEET E-002 | BLOCKED | Hardware inhibit schematic and reset/brownout proof required |
| Fault strategy | Source requests fuse, pull-downs, zeners, clamps, thermal shutdown, fan, plausibility checks and latch | FROZEN_FROM_PDF source §31 | DESIGN DECISION REQUIRED | Hardware implementation not present |
| Power trace calculation | 2 oz external copper, 2 A, 10 °C rise: IPC-2221 empirical check gives 0.385 mm minimum; 1.0 mm is a stated design target pending stackup/layout | CALCULATED; method and assumptions in `pcb_readiness_closure.m` | ANALYTICALLY CLOSED | Via/connector/fabricator limits remain |
| Source trace example | 100 mm × 5 mm × 70 µm: 4.925 mΩ, 9.85 mV drop, 19.7 mW at 2 A | CALCULATED using source geometry and 2 oz thickness | ANALYTICALLY CLOSED | Not a final routing constraint |
| Kelvin routing | Four-terminal concept required because 20 mV shunt signal is comparable to copper drops | FROZEN_FROM_PDF source §32.1 | DESIGN DECISION REQUIRED | Final geometry/layout review required |
| Exact procurement BOM | Exact candidates are not locked for shunt, ballast, LDO, NTC, fan, heatsink, fuse, connectors or OLED module | Repository BOM inspection | BLOCKED | Do not fabricate until selected and footprint-checked |

## Exact-component decision record

The source explicitly names families or design values, not complete procurement records. The following are **candidates**, not silently substituted final parts:

- `INA180A3IDBVR`, TI SOT-23-5 (DBV): exact package ordering candidate from SBOS741H. Confirm supplier availability and footprint.
- `MCP4725A0T-E/CH`, Microchip SOT-23-6: exact address/package candidate from DS22039D. Confirm address selection and procurement.
- `LM358BIDR`, TI SOIC-8 (D): exact package candidate from SLOS068AB. Confirm that SOIC-8 is compatible with the intended PCB.
- BUZ11/D remains the source-required candidate; manufacturer/ordering suffix and authenticity must be locked before release.
- ESP32-WROOM-32, L7805, 0.01 Ω shunt, 0.1 Ω ballast, 1 kΩ gate resistors, 100 kΩ pull-downs, 8.2 V zeners, 10 kΩ NTC, fan, heatsink, fuse, connectors and SSD1306 display remain incomplete procurement records. No unverified MPN is invented here.

For each incomplete item the release action is: select MPN → obtain current datasheet → verify package/land pattern and ratings → record supplier/availability → update `data/hardware_bom.json` and `data/hardware_requirements.json`.

## Safety and topology decisions still required

1. Add a real hardware inhibit between the DAC/control node and LM358B/MOSFET gate-control path. A digital AND operation on an analog voltage is not acceptable. The implementation must force the control node to a defined OFF level for MCU OFF, reset, boot, brownout and fault, and must be reviewed against the actual LM358B input/output topology.
2. Define the fault latch/reset policy and the independent fault signal path. Software clamps alone are not hardware qualification.
3. Define the actual loop schematic and compensation. The 159 Hz filter corner is not a phase-margin result.
4. Define the heatsink, TIM, mounting, airflow and MOSFET case interface. The PDF's 1.5 K/W, 1.67 K/W and 0.5 K/W values remain design/example values, not purchased hardware data.

## Physical validation still required

- Exact-part receipt, identity and footprint inspection.
- One-device low-power bring-up, then staged four-device testing per source §36.
- Hot-case DC SOA and unequal-current-sharing validation.
- Heatsink/case/TIM/PCB/fan temperature measurements at staged and maximum points.
- End-to-end current calibration and ADC characterization, including shunt TCR/temperature effects and Kelvin parasitics.
- Hardware inhibit behavior during power-up, reset, boot, brownout, DAC communication loss and fault.
- Loop frequency-response/step-response test and stability margin evidence.
- Regulator rail current, dropout and thermal measurements.
- Final PCB layout, via, connector, fuse, antenna keepout and DFM review.

## Robu-only procurement closure

`data/robu_procurement.json` and `docs/ROBU_BOM.md` are the procurement records. The current session exposes no browser-capable navigation, rendered-page or screenshot tool, so browser verification could not be performed. The prior direct-HTTP attempt returned HTTP 403 and is not treated as product evidence. Consequently every unverified listing is marked `ROBU_STATUS = UNCERTAIN`; no stock, price, SKU or product identity is asserted. Prices are `PRICE NOT VISIBLE` and total cost is null. This is a genuine procurement-access blocker, not a substitute component decision.

The three datasheet-supported ordering candidates are recorded as candidates only: `INA180A3IDBVR`, `MCP4725A0T-E/CH` and `LM358BIDR`. They become final selections only after their Robu product pages, exact package and current stock are manually verified.

## Authoritative release gate

`PCB_RELEASE = BLOCKED`

The software arithmetic, source power partition, thermal equations, INA180A3 datasheet subtotal, source trace arithmetic and preliminary trace-width calculation are closed. Release remains blocked by exact procurement records, SOA at applicable temperature/duration, thermal hardware qualification, complete current-sense error budget, gate-drive/loop evidence, hardware inhibit/fault implementation and final PCB/layout verification. This status is evidence-based and is not caused by sub-agent infrastructure.

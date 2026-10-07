# Astra datasheet evidence and qualification boundaries

Manufacturer URLs retrieved 2026-10-06. Hashes identify the exact downloaded documents; upstream URLs can change. Manufacturer PDFs were reviewed from temporary downloads, not vendored. This review does not identify the actual purchased parts or qualify the assembled load.

| Device | Document | Manufacturer URL | SHA-256 |
|---|---|---|---|
| MCP4725 | Microchip DS22039D, 2009, 50 PDF pages | https://ww1.microchip.com/downloads/en/DeviceDoc/22039d.pdf | `746d95dfdaaf0a9da4698e2c0a201ac2736d8589a752ab0dcd903f4a1603077d` |
| INA180 | TI SBOS741H, revised July 2022 | https://www.ti.com/lit/ds/symlink/ina180.pdf | `00e2e06b26d9b821b606e1382e9ccdfa0c38b0ac935b235258490d82d5d07d93` |
| LM358B | TI SLOS068AB, revised October 2024 | https://www.ti.com/lit/ds/symlink/lm358.pdf | `618a685fe56ee7318e0a07cd2f98cd87d0d9549ccd1c828d6d4174875554ca97` |
| BUZ11 candidate only | onsemi BUZ11/D, October 2017 Rev. 3, 7 PDF pages | https://www.onsemi.com/pdf/datasheet/buz11-d.pdf | `21c855de2e0b7dcee8a2ea4e216d56cbe22bce8e03175c939ed050407e88c03e` |

## E-001: MCP4725 transfer — resolved

DS22039D §5.1, equation 5-1, printed/PDF page 19: `Vout = Vref * Dn / 4096`, where `Vref = Vdd`. §4.1 gives code range 0…4095; §5.2 gives LSB = Vdd/4096. This supports the user's explicit 4096 requirement and corrects source PDF §13 eqs. 35/38 without modifying the archived source.

At nominal 3.3 V:

- LSB = 0.0008056640625 V = 0.8056640625 mV.
- Highest digital code 4095 produces 3.2991943359375 V, not exactly 3.3 V.
- `floor(2 * 4096 / 3.3) = 2482` (also the PDF's proposed cap).
- Code 2482 produces 1.999658203125 V; code 2483 produces 2.0004638671875 V.

Nominal flooring avoids rounding above the requested ideal value. It does not guarantee a real 2 A safety limit: supply tolerance, DAC gain/offset, sense gain, shunt error, wiring and calibration remain relevant.

## E-002: Startup/reset DAC hazard — unresolved hardware requirement

DS22039D §§5.4–5.4.1, page 19, states that power-on reset and general-call reset load the EEPROM value into the DAC register. It explicitly describes factory EEPROM defaults as midscale. Table 5-3 on page 21 specifies these defaults. §5.4.2 discusses supply ramp limitations; §5.6 notes commands can be ignored during EEPROM writing.

Consequences for this design:

- A firmware `DAC=0` action after boot is not proof of zero current during startup.
- A pull-down cannot be assumed to disable gates actively driven by an op-amp.
- Hardware inhibit, reset/brownout behavior, safe EEPROM initialization, communication faults and watchdog response require schematic-level design and bench tests.
- Model `enabled=false` is a software intent, not evidence of a physical disconnect.
- Routine setpoint writes should not be modeled as EEPROM writes; safe programming policy remains a firmware/hardware task.

## E-003: INA180A3 nominal gain — corroborated, accuracy not qualified

SBOS741H page 1 lists 100 V/V for A3 devices, corroborating source §§9/12. The datasheet includes supply/common-mode restrictions and nonzero offset/gain errors. This review does not populate a complete error budget: the exact package, operating point, temperature range, ADC transfer and shunt temperature coefficient must be selected first. The numeric identity `Vsense[V] = I[A]` is nominal dimensional scaling, not a statement that volts and amperes are equivalent units.

## E-004: LM358B headroom — qualification blocker

SLOS068AB recommended operating conditions and LM358B electrical characteristics (§§5.3, 5.6) specify input common-mode limits and load-dependent output swing from the rails. LM358B is not a rail-to-rail output amplifier. Do not assume that a 5 V supply can produce the source PDF's illustrative 5 V gate-drive level. Source §27 says the control amplifier uses an input-side electronics rail but leaves the detailed supply/drive arrangement unresolved. Determine the actual supply, startup sequencing, common-mode/output margins, capacitive gate load and compensation before claiming current-loop performance.

## E-005: BUZ11 linear SOA — candidate evidence only

The onsemi candidate datasheet's Figure 4, PDF page 4 / printed page 3, includes a forward-bias SOA plot with a DC curve, labeled at case temperature 25 C. Figure 3 gives transient thermal impedance; Figure 1 gives a case-temperature-dependent power multiplier. The source PDF's approximate Rjc=1.67 C/W agrees numerically with this candidate document, but does not establish the manufacturer's identity for purchased devices.

The approximately 14.93 V, 0.5 A per branch nominal peak point must be checked against the exact purchased-device DC SOA at actual case temperature, duration and unequal sharing. Do not infer a numerical SOA margin from a headline current rating, a different vendor's BUZ11, a pulsed output-characteristic curve, or a room-temperature graph alone. SOA approval and continuous-power approval remain TBD.

## Extracted values used by the closure calculation

The following values were transcribed from the exact PDFs identified above; they are datasheet evidence, not measured hardware values:

- **INA180A3 / SBOS741H:** A3 gain = 100 V/V; maximum input offset = ±500 µV over the stated temperature range; maximum gain error = ±1%; maximum gain drift = 20 ppm/°C; A3 bandwidth = 150 kHz with 10 pF load; maximum INA180 supply current = 260 µA. Candidate ordering MPN `INA180A3IDBVR` is SOT-23-5/DBV.
- **LM358B / SLOS068AB:** typical GBW = 1.2 MHz; typical slew rate = 0.5 V/µs in the B electrical-characteristics table; output swing is load-dependent and is not rail-to-rail. Candidate ordering MPN `LM358BIDR` is SOIC-8/D.
- **MCP4725 / DS22039D:** supply current maximum = 400 µA; offset error maximum = 0.75% FSR; gain error maximum = ±2% FSR; POR/EEPROM behavior as described above. Candidate ordering MPN `MCP4725A0T-E/CH` is SOT-23-6/CH.
- **BUZ11/D:** input capacitance CISS is specified as a range at the stated test condition (1500–2000 pF in the candidate document); this is not a substitute for the exact assembled gate-load measurement. Figure 4 is a 25 °C case-temperature SOA graph and does not qualify hot continuous operation.

These candidate ordering MPNs require procurement and footprint verification before they become final selections.

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

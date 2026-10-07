# PCB Design Requirements — Released Baseline

**Source authority:** `docs/source/design-source.pdf`
**Design release:** PASS means schematic/layout may proceed; it is not hardware qualification.
**Hardware validation:** PENDING.

## Power input

- Accept 10–15 V DC input and 2 A maximum controlled load.
- Use `Phoenix Contact 1729010` two-position input connector candidate, `Littelfuse 0453002.NRL` 3 A input fuse candidate, and `Panasonic EEU-FR1E102` 1000 uF/25 V input bulk capacitor candidate.
- Place fuse and bulk capacitor adjacent to the input connector. Provide reverse-polarity/protection provision in the schematic review.

## Power stage

- Use four parallel BUZ11 TO-220AB devices, each with a 0.1 ohm ballast resistor, 1 kohm gate resistor, 100 kohm gate-source pull-down, and approximately 8.2 V gate-source zener.
- At 15 V / 2 A: 0.5 A/device, 20 mV shunt drop, 50 mV ballast drop, 14.93 V VDS, 7.465 W/device.
- DC SOA design boundary is 0.55 A/device at the design point, conservatively extracted from the selected BUZ11 datasheet graphical curve with 0.05 A extraction uncertainty. Hardware hot-case SOA remains pending.
- Use electrically isolated TO-220 mounting hardware on the common heatsink.

## Current sense

- Use 0.01 ohm, 3 W, 1% Kelvin-capable `WSL3637-0R010-3W-candidate` and INA180A3IDBVR, gain 100 V/V.
- Route shunt sense as a Kelvin pair directly from the resistor element to the INA180 inputs. Do not share high-current copper with sense traces.
- Use the defined 10 kohm/10 nF input filter and provide VIN, shunt, and amplified-sense test points.
- Analytical uncalibrated error includes shunt tolerance and INA180 offset/gain terms. ADC transfer, TCR, layout parasitics, and calibration are hardware-validation items.
- Post-build calibration: apply at least 0, 0.1, 0.5, 1.0, 1.5, and 2.0 A traceable currents; fit offset and gain; store coefficients; verify independent points.

## Analog control

- Use LM358BIDR SOIC-8 and MCP4725A0T-E/CH SOT-23-6.
- Keep analog feedback away from fan, ESP32 antenna, display, and high-current switching paths.
- Preserve the source 159 Hz current filter. The released design crossover target is <=25 Hz; the filter is not itself a stability proof.

## Gate drive and loop

- Use a 7.5–8.2 V design VGS region, 1 kohm per-device gate resistor, and 8.2 V clamp.
- Aggregate candidate Ciss is 6–8 nF; gate-network time constant is 6–8 us. Initial gate current is <=8.2 mA, below the selected LM358B source-current design allowance.
- Use conservative compensation targeting <=25 Hz crossover. Hardware Bode/scope verification remains required.

## Power tree

- Preserve VIN -> 5 V -> 3.3 V architecture.
- Use L7805CV for 5 V and AP2112K-3.3TRG1 for 3.3 V.
- Budget 150 mA on 5 V and 548 mA worst-case on 3.3 V: ESP32 500 mA peak plus 48 mA for MCP4725/INA/NTC/logic/status support; OLED and encoder loads are removed.
- AP2112K current margin is approximately 56 mA. Provide at least 600 mm2 copper for thermal spreading and verify regulator temperature after fabrication.

## MCU and web interface

- Use ESP32-WROOM-32E. Keep the module antenna at the board edge with the manufacturer keepout: no copper, traces, vias, or metal hardware in the antenna region.
- Provide EN, boot strap, reset, I2C pull-ups for MCP4725, local 100 nF and bulk decoupling, and a 3.3 V programming/service UART connector.
- R1 has no OLED, rotary encoder, encoder switch, or ordinary START/STOP buttons. Status indication is provided by the defined status LED and the local web application.
- The ESP32 shall validate web commands and own the supervisory state machine; browser requests shall never directly write a DAC command.
- Implement `/api/status`, `/api/config`, `/api/mode`, `/api/setpoint`, `/api/start`, `/api/stop`, `/api/reset`, `/api/test/status`, `/api/test/data`, and `/ws` as the firmware interface contract.
- Use the defined status LED and emergency-stop panel connector. Verify final vendor drawings before Gerbers.

## Startup safety and fault protection

- Do not rely on DAC power-on value or firmware for power-stage safety.
- Implement: LM358 output -> normally-open ADG884BRMZ analog switch -> 1 kohm gate branches. Use 100 kohm gate pulldowns so an open switch forces all gates off.
- Enable the switch only when `MCU_RUN` and `RESET_OK` are both valid. Use TPS3839K33DBZR reset supervision and SN74LVC1G04DBVR logic with an external default-off bias.
- MCU off, reset, boot, brownout, or fault must open the switch and force `POWER_STAGE_OFF`.
- Provide a latched fault signal in the MCU/reset logic and a hardware test point for the inhibit node. Validate startup and fault timing on the prototype.

## Thermal and fan

- Design for approximately 30 W peak MOSFET dissipation.
- Specify common forced-air heatsink target RthetaSA <=1.5 K/W, interface resistance target RthetaCS <=0.5 K/W, TIM on every device, mechanically retained isolated mounting, and minimum 10 CFM airflow.
- Use a fan-control transistor stage with flyback protection and a fan connector rated for startup current. Keep the fan and its return out of the Kelvin sense path.
- Provide heatsink NTC mounting at the hottest representative location. Thermal calculations are design evidence; measured temperatures are hardware validation.

## PCB copper and current paths

- Use 2 oz copper, external-layer power traces >=1.0 mm preferred and never below the calculated 0.385 mm minimum for the stated 2 A / 10 C rise assumptions.
- Keep the high-current input, MOSFET, shunt, and output loop short and wide. Use parallel via arrays at layer changes; final via count shall be checked against the fabricator's plated-via current/temperature data.
- Place the shunt at the controlled-current return boundary. Route Kelvin sense separately from the power return.
- Define a quiet analog ground region joined to the power ground at the shunt/sense reference point; keep ESP32/fan return currents away from that join.

## Mechanical, connectors, and test points

- Maintain clearance for TO-220 body, heatsink, TIM, fan, and isolated mounting hardware.
- Define connector pin-1 orientation and silkscreen polarity for input, load output, fan, display, and programming connectors.
- Provide labeled test points for VIN, 5 V, 3.3 V, DAC output, current-sense input/output, each gate bus, NTC, inhibit, and fault.
- Before fabrication, complete manufacturer-land-pattern review for DBV, CH, SOIC-8, TO-220, ESP32 module, shunt, terminal blocks, emergency-stop connector, service connector, and regulators. R1 has no display or encoder footprint. This is a design-library review, not a reason to claim hardware validation.

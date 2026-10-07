# PLEL R1 Schematic Prerequisite Verdict

**Date:** 2026-10-07
**EasyEDA modification permitted:** NO

| Gate | Status | Basis |
|---|---|---|
| ESP32_PIN_MAP | PASS | Complete 38-pin U4 map added; GPIO39/SENSOR_VN is pin 5; unused pins classified |
| U8_PIN_MAP | PASS | Correct DBV mapping: 1 NC, 2 A, 3 GND, 4 Y, 5 VCC |
| U9_PIN_MAP | PASS | Exact ten-pin map recorded; functional use is not yet approved |
| U6_PIN_MAP | PASS | Corrected TLV76733PDBVR to fixed 5-pin DBV: SNS, IN, EN, OUT, GND/thermal pad |
| LM358_CONTROL_MAP | FAIL | Repository defines a first-pass 10 kΩ/100 nF filter and <=25 Hz target but no complete feedback/compensation topology or values; BOM has no complete compensation network |
| SHUNT_CONNECTION | FAIL | Four-terminal names exist, but authoritative R1 sources do not define the physical polarity/path from ballast return to RSH1 and INA180 IN+/IN− |
| TEST_POINT_MAP | PASS | TP1–TP10 expanded with explicit nets, purposes, and validation IDs |
| CONNECTION_MATRIX | FAIL | Not created: safety and analog/shunt contracts are unresolved |
| BOM_PIN_PARITY | FAIL | Corrected electrical records are synchronized, but complete matrix parity cannot pass while required electrical topology is missing |
| SAFETY_CHAIN | FAIL | ADG884 is dual SPDT, not a normally-open SPST; one inverter and the current BOM do not implement the required four-condition fail-safe AND |

## Release decision

```text
SCHEMATIC_PREREQUISITES = FAIL
DO_NOT_TOUCH_EASYEDA = TRUE
```

## Exact engineering decisions still required

1. Approve the complete LM358 feedback/compensation schematic, including every component reference, value, and net.
2. Approve RSH1 high-current polarity and the exact Kelvin connections to INA180A3 IN+ and IN−.
3. Replace or redesign the proposed U7/U8/U9 safety logic so `ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT` produces a defined fail-safe gate-off/enable signal using actual parts and pin assignments.
4. Define U9 channel usage if ADG884BRMZ remains selected, including safe control defaults and the second SPDT channel.

The canonical connection matrix must not be generated until these decisions are authoritative.

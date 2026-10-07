# PLEL R1 Schematic Prerequisite Verdict

**Date:** 2026-10-07
**EasyEDA modification permitted:** NO
**EasyEDA state:** Schematic1 / P1 remains untouched

## Gate status

| Gate | Status | Exact blocker or basis |
|---|---|---|
| ESP32_PIN_MAP | PASS | Complete 38-pin U4 map; GPIO39/SENSOR_VN is pin 5; unused pins classified |
| U8_PIN_MAP | PASS | Correct DBV mapping: 1 NC, 2 A, 3 GND, 4 Y, 5 VCC |
| U9_PIN_MAP | PASS | Exact ten-pin MSOP map recorded; functional use is not approved |
| U6_PIN_MAP | PASS | TI fixed DBV mapping: 1 IN, 2 GND, 3 EN, 4 DNC, 5 OUT; prior SNS mapping withdrawn |
| ANALOG_CONTROL | FAIL | No authoritative complete LM358 feedback/compensation topology, component references, or values. The source 10 kΩ/100 nF first-pass filter is not a complete loop definition and conflicts with BOM C6 = 10 nF without an approved decision. |
| SHUNT_CONNECTION | FAIL | Sources define a four-terminal shunt concept but not the authoritative high-current polarity/path or exact INA180 IN+/IN− Kelvin polarity. |
| TEST_POINTS | PASS | TP1–TP10 have explicit nets, purposes, and validation IDs. |
| CONNECTION_MATRIX | FAIL | Not created because analog, shunt, safety, and programming contracts remain unresolved. |
| BOM_PIN_PARITY | FAIL | Component pin corrections are synchronized, but complete electrical parity cannot pass without a complete canonical matrix and J_PROGRAM/support-passive decision. |
| SAFETY_CHAIN | FAIL | ADG884 is dual SPDT, not a normally-open SPST. The current U7/U8/U9 BOM has no complete four-condition fail-safe logic implementation or exact channel/default assignments. |
| ESP32_FIRMWARE_INTERFACE | FAIL | Current J2 is only 1x2 TX/RX; EN/GPIO0/GND/3V3 service and recovery contract is not represented. CP2102 adapter/power policy is unresolved. |
| PROGRAMMING_HEADER | FAIL | Required six-pin J_PROGRAM is not in the authoritative BOM or pin map. |
| ESP32_SUPPORT_PASSIVES | FAIL | Existing C4/C8–C12 are not allocated to an authoritative ESP32 support network; required EN/GPIO0 support components and values are absent. |
| BOOT_RESET_NETWORK | FAIL | No authoritative EN pull-up/reset network or GPIO0 boot/manual-BOOT network exists in the BOM. |
| POWER_DOMAIN_SAFETY | FAIL | Exact CP2102 adapter and 3V3/5V power behavior are undocumented; back-power prevention is not defined. |

## Release decision

```text
BLOCKERS_RESOLVED = NO
SCHEMATIC_PREREQUISITES = FAIL
DO_NOT_TOUCH_EASYEDA = TRUE
CONNECTION_MATRIX_CREATED = FALSE
```

## Required engineering decisions before matrix creation

1. Approve the complete LM358 channel-A feedback and gate-control schematic, including every resistor/capacitor reference, value, and net; explicitly terminate or use channel B.
2. Approve RSH1 current direction, `LOAD_RETURN`/`POWER_RETURN` terminal order, and exact `SENSE+`/`SENSE-` connections to INA180 IN+/IN−.
3. Replace or redesign the U7/U8/U9 safety logic so `ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT` produces a defined fail-safe gate-off/enable signal. If ADG884 remains, define both SPDT channels, controls, throws, defaults, and safe output behavior.
4. Add and approve the six-pin `J_PROGRAM` connector and exact pin map.
5. Approve manufacturer-backed EN/reset and GPIO0/BOOT support networks with exact values.
6. Approve the CP2102 adapter voltage/power contract, including prohibition of unsafe 5 V injection and prevention of unintended board back-powering.

The canonical `eda/connections/PLEL_CONNECTION_MATRIX.csv` must not be created until all decisions above are authoritative.

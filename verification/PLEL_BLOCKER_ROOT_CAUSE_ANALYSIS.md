# PLEL R1 Blocker Root-Cause Analysis

**Status:** BLOCKED — no EasyEDA schematic modification permitted
**Date:** 2026-10-07
**Authority:** current R1 repository artifacts, manufacturer datasheet evidence, and executed read-only research

## Executive finding

The prerequisite verdict cannot become `PASS` by drawing the current conceptual design. Several failures are missing electrical decisions, not documentation gaps. The current BOM, pin map, and handoff do not define a complete closed-loop analog controller, signed Kelvin measurement, fail-safe hardware enable, or a complete ESP32 programming/power interface. Therefore the connection matrix and EasyEDA schematic must remain blocked until the root causes below are closed.

## Blocker table

| Gate | Root cause | Evidence | Required closure |
|---|---|---|---|
| `ANALOG_CONTROL` | LM358 loop feedback and compensation are absent; gate plant and output headroom are not closed. | `eda/PLEL_R1_SCHEMATIC_HANDOFF.md`, `data/parameters.json`, `verification/PLEL_SCHEMATIC_PREREQUISITE_VERDICT.md`; LM358B GBW/slew/output limitations in `docs/DATASHEET_EVIDENCE.md`. | Approve an exact feedback topology, R/C values, supply, gate-drive headroom, plant assumptions, crossover and phase-margin verification. |
| `CURRENT_FILTER` | Source requirement says 10 kΩ/100 nF first-pass filtering while BOM has C6=10 nF and no dedicated filter resistor. | `docs/source/design-source.txt`, `data/PLEL_R1_MASTER_BOM.json`, `data/pcb_design_bom.json`. | Decide exact placement and values; reconcile BOM, MATLAB, handoff, and matrix. |
| `SHUNT_CONNECTION` | High-current direction and INA180 IN+/IN− Kelvin polarity are not authoritative. | `eda/parts/PLEL_R1_PIN_MAP.json`, `docs/PCB_DESIGN_REQUIREMENTS.md`, prerequisite verdict. | Define POWER_RETURN/LOAD_RETURN direction, SENSE+/SENSE−, INA180 polarity, and positive-current transfer equation. |
| `SAFETY_CHAIN` | Required four-input AND is not implemented. ESTOP_OK and FAULT do not reach hardware logic; one inverter and an ADG884 cannot implement the required function. | `docs/EMERGENCY_STOP_R1.md`, `verification/PLEL_SAFETY_CHAIN_REVIEW.md`, pin map, executed safety research. | Select exact logic IC topology and pins; define defaults and prove every unsafe state forces gate off. |
| `ADG884_USAGE` | ADG884 is a dual SPDT analog switch, not a normally-open SPST or AND gate. | ADG884 manufacturer mapping/evidence and safety review. | Either document a valid switch configuration including both throws, or replace it with a suitable enable element. |
| `ESP32_FIRMWARE_INTERFACE` | J2 is only TX/RX and cannot support deterministic programming/reset. | `verification/PLEL_ESP32_FIRMWARE_INTERFACE_REVIEW.md`, BOM, `docs/ESP32_GPIO_MAP_R1.md`. | Add the required six-pin J_PROGRAM: GND, 3V3, ESP_TX, ESP_RX, EN, GPIO0. |
| `BOOT_RESET_NETWORK` | EN reset and GPIO0 manual boot bias/control are absent or incomplete; strap defaults are not fully documented. | ESP32 interface review and GPIO map. | Add exact pull-ups/pull-downs, reset capacitor/button policy, BOOT control, and strap treatment. |
| `ESP32_SUPPORT_PASSIVES` | Generic capacitors are not allocated to module, regulator, and analog rails. | BOM C4/C8–C12 allocation and interface review. | Allocate every capacitor by reference, value, voltage, and rail; verify against Espressif guidance. |
| `POWER_DOMAIN_SAFETY` | CP2102 adapter variant and its 3V3/5V behavior are unspecified. | Firmware interface review; BOM and handoff. | Define signal-only policy, connector 3V3 policy, 5V exclusion, and back-power prevention. |
| `CONNECTION_MATRIX` | A deterministic matrix cannot be generated while the above polarity/topology decisions remain open. | `eda/connections/PLEL_CONNECTION_MATRIX.csv` is intentionally withheld. | Generate only after topology is frozen; every matrix net must have source, destination, pin, and electrical role. |
| `BOM_PIN_PARITY` | New logic, filter, programming, and support components are not reflected consistently across BOM, pin map, PCB BOM, MATLAB, and handoff. | Existing parity verdict and source files. | Update all authoritative artifacts together, then run automated parity checks. |

## Safety-specific root cause

The required condition is:

```text
POWER_STAGE_ENABLE = ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT
```

Current signals are not equivalent to this equation. `RESET_OK` is available from the supervisor, but `ESTOP_OK` and `FAULT` are routed to monitoring/ESP32 functions rather than a complete hardware gate. `MCU_RUN` has a defined pull-down, while the emergency-stop loop lacks a fully specified safe bias. Consequently, startup, unplugged-loop, reset, firmware fault, and supervisor-fault behavior cannot be proven safe from the current netlist.

## Analog-specific root cause

The analog research confirms four separate unresolved questions:

1. Can the LM358B output, on its defined supply and with the actual gate network, reach the BUZ11 operating point required for 2 A?
2. What exact feedback network stabilizes the MOSFET/gate-capacitance plant?
3. Is the required current filter 10 kΩ/100 nF, 10 kΩ/10 nF, or another topology, and where is it placed?
4. Which shunt terminal is positive in the defined current direction, and which INA180 input receives it?

Until these are answered with calculations and MATLAB results, a drawn feedback wire would be an unverified assumption.

## Runtime research limitation

The NVIDIA runtime now accepts the exact live registry references. The first successful direct smoke execution used `nvidia/nvidia/nemotron-3.5-lightning-30b-a3b` and returned the repository's 15 V / 2 A limits. Earlier parallel research panes exited before result capture because the parent process still held the old Windows launcher. The launch source has since been corrected for PowerShell and Windows absolute paths. This runtime issue is separate from the electrical blockers and does not authorize schematic changes.

## Release rule

Do not modify EasyEDA `Schematic1 / P1`, and do not declare `BLOCKERS_RESOLVED = YES`, until every gate is backed by an exact component/pin/value decision and the corresponding parity and MATLAB checks pass.

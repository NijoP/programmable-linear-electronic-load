# PLEL R1 Safety-Chain Review

**Status:** BLOCKED — not released for schematic generation
**Date:** 2026-10-07

## Required safety function

`ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT` must enable the analog gate-control path. Any false/unsafe condition must force all four BUZ11 gates to their source/off state without Wi-Fi, browser, HTTP, JavaScript, or normal firmware execution.

## Signal review

| Signal | Source | Intended destination | Required logic | Safe state | Failure state |
|---|---|---|---|---|---|
| `ESTOP_OK` | SW1/J3 normally-closed loop | Hardware inhibit logic | Must be true only while the loop is closed | Open loop disables gate path | Open wire/contact must disable |
| `MCU_RUN` | U4 GPIO25 with R10 default-low bias | Hardware inhibit logic | Must be true only after firmware authorization | Low disables gate path | MCU absent/reset/boot defaults low |
| `RESET_OK` | U7 TPS3839 supervisor output | Hardware inhibit logic | Must be true only while 3V3 is valid | Supervisor unsafe state disables | Brownout/reset disables |
| `FAULT` | U4 GPIO27 / fault source with R11 bias | Hardware inhibit logic | Fault asserted must disable | Fault asserted disables | Open/invalid fault signal must be fail-safe |
| `POWER_STAGE_ENABLE` | Missing complete hardware logic definition | U9 control input(s) | Four-input AND with active-low fault | Low/disabled | Must never default enabled |
| `GATE_BUS` | U2 LM358 output through inhibit element | RG1–RG4 | Passed only when enable is valid; otherwise defined low/high impedance with pull-downs | All gates pulled to source/off | Active LM358 drive must not defeat inhibit |

## ADG884 architecture issue

The corrected ADG884BRMZ pin map is:

```text
1 VDD, 2 S1A, 3 D1, 4 IN1, 5 S1B,
6 GND, 7 S2B, 8 IN2, 9 D2, 10 S2A
```

ADG884 is a dual SPDT analog switch. It does not provide a normally-open SPST enable and it does not implement a four-input AND function. The current BOM provides only one inverter (`U8`) and no complete four-input hardware AND/fail-safe gate-enable network.

A possible single-channel selection such as `S1A=LM358_OUT`, `S1B=GND`, `D1=GATE_BUS`, `IN1=POWER_STAGE_ENABLE` would require a separately defined, verified `POWER_STAGE_ENABLE` logic source and would force the safe output low rather than provide the documented open-switch behavior. The second SPDT channel and all control defaults would also require an explicit engineering decision.

Therefore the existing proposed safety topology is electrically incomplete. No U9 channel assignment has been placed in the connection matrix.

## Required engineering decision

Select and document a real fail-safe hardware implementation for the four conditions, including exact logic IC(s), truth table, default biasing, U9 usage or replacement, and the defined gate-off voltage path. Until that decision is made, `SAFETY_CHAIN = FAIL`.

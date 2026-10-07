# PLEL R1 Emergency STOP

## Requirement

The emergency STOP shall force `POWER_STAGE_OFF` without Wi-Fi, browser,
HTTP, JavaScript, or normal ESP32 execution.

## Implemented design requirement

Use a normally-closed, latching emergency-stop contact in the hardware enable
chain. The contact permits `ESTOP_OK` only while released. The gate-control path
is enabled only when all conditions are true:

```text
ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT
```

`MCU_RUN` is GPIO25 with a default-low external bias. `RESET_OK` is derived from
the 3.3 V supervisor. `FAULT` is an independent fault input/latch. The logic
controls the ADG884 gate-control switch. When the switch is open, each BUZ11
gate is held at its source by its 100 kΩ pull-down, regardless of the MCP4725,
LM358B, web server, or software state.

## Truth table

| E-stop | MCU run | Reset OK | Fault | Result |
|---|---:|---:|---:|---|
| released | 1 | 1 | 0 | Gate path may enable |
| pressed/open | X | X | X | POWER_STAGE_OFF |
| released | 0 | X | X | POWER_STAGE_OFF |
| released | X | 0 | X | POWER_STAGE_OFF |
| released | X | X | 1 | POWER_STAGE_OFF |
| wire/contact open | X | X | X | POWER_STAGE_OFF |
| MCU unpowered | 0/default | X | X | POWER_STAGE_OFF |

The web `POST /api/stop` command is a normal control command only. It is not
the emergency safety mechanism. Communication loss causes a software
supervisory safe state, while the physical E-stop remains independent and
dominant.

## Validation after fabrication

Exercise E-stop press/release, contact/open-wire faults, MCU off/reset/boot,
brownout, web disconnect, and latched fault conditions while recording the
inhibit node, gate voltage, and branch current. No such measurement is claimed
by this design release.

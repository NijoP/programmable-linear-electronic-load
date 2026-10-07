# PLEL R1 Emergency STOP Result

`SW_ESTOP` is a normally-closed, latching physical control in the hardware
enable chain. The ADG884 gate-control switch is enabled only when:

```text
ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT
```

Any open E-stop contact, MCU off/reset/boot, brownout, fault, or inactive web
run authorization opens the gate-control switch. The 100 kΩ gate pulldowns
then force all BUZ11 gates to their sources. The browser STOP endpoint is not
the safety mechanism.

See `docs/EMERGENCY_STOP_R1.md`. Hardware timing and fault-response tests are
pending fabrication.

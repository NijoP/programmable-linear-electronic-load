# PLEL R1 PCB Design Release Summary

**Product:** PLEL R1 web-controlled programmable linear DC electronic load
**Source:** `docs/source/design-source.pdf`
**PCB_DESIGN_RELEASE:** `PASS`
**HARDWARE_VALIDATION:** `PENDING`
**HARDWARE_VALIDATION_SIMULATION:** `COMPLETE`

## R1 release closures

- Product interface: ESP32-WROOM-32E local Wi-Fi web application; no cloud.
- Removed from active R1 BOM: OLED, rotary encoder, encoder switch, ordinary START/STOP buttons.
- Retained physical safety control: normally-closed latching emergency STOP.
- Web contract: documented HTTP endpoints plus `/ws`; browser cannot bypass validation or hardware safety.
- GPIO map: deterministic R1 assignment in `docs/ESP32_GPIO_MAP_R1.md`.
- Command laws: existing CC/CP/CR functions remain authoritative and are exercised through `plel_r1_validate_command`.
- Power tree: 150 mA 5 V design budget; 548 mA 3.3 V worst-case budget; 52 mA AP2112K current margin.
- Communication-loss design target: 2 s supervisory timeout; independent emergency STOP remains dominant.
- Operating-envelope results and engineering plots are generated under `results/`.

## Existing electrical closures retained

At 15 V / 2 A / four devices: 0.5 A/device, 20 mV shunt drop, 50 mV ballast
drop, 14.93 V VDS, 7.465 W/device, 29.86 W MOSFET total, 0.10 W ballast,
0.04 W shunt, and 30.00 W total power.

## Hardware validation retained

Actual current sharing, hot-case SOA, assembled thermal performance, current
sense/ADC calibration, loaded gate waveform, physical loop response, startup,
brownout, fault response, Wi-Fi behavior, regulator temperature, and final DFM
remain `HARDWARE_VALIDATION = PENDING`. No measured hardware result is claimed.

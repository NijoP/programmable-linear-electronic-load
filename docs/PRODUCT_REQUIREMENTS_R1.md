# PLEL R1 Product Requirements

## Product

PLEL R1 is a programmable linear DC electronic load for 10–15 V sources,
limited to 2 A and 30 W peak, with an initial recommended continuous design
target of approximately 24 W. The ESP32-WROOM-32E hosts a local web
application over Wi-Fi. V1 has no cloud dependency.

## Operating modes

CC, CP, CR, and Battery Discharge/Test are required. Existing validated
command laws remain authoritative:

- CC: `min(ISET, 2 A, 30 W/VIN)`
- CP: `min(2 A, 30 W/VIN, PSET/VIN)`
- CR: `min(2 A, 30 W/VIN, VIN/RSET)`

## User workflow

Connect the source, power the instrument, join the local Wi-Fi network, open
the ESP32 web application, select a mode and setpoint, review limits, press
START, observe voltage/current/power/temperature, then stop and optionally
retrieve test data. An emergency STOP is the only physical user safety control.
There is no OLED, rotary encoder, encoder switch, or ordinary START/STOP button
in the R1 active BOM.

## Web interface

The local browser interface supports phone, laptop, and tablet clients. Required
HTTP resources are documented in `docs/WEB_INTERFACE_ARCHITECTURE_R1.md`; live
measurements use `/ws`. Browser requests are validated by the ESP32 command
validator and supervisory state machine before the MCP4725 command is updated.
The browser never directly controls an analog safety node.

## Safety and faults

Emergency STOP is a normally-closed hardware path that opens the gate-control
inhibit independently of Wi-Fi, HTTP, JavaScript, or normal firmware execution.
MCU off/reset/boot/brownout, fault, and communication timeout must result in a
safe disabled state. Communication timeout is supervisory safety; it is not a
substitute for emergency STOP.

## Data and measurements

The ESP32 reports VIN, load current, calculated power, NTC temperature, mode,
setpoint, limit state, fault state, and elapsed test data. Calibration and
assembled-board accuracy remain hardware validation requirements.

## Pre-fabrication versus hardware validation

Pre-fabrication requirements include the electrical model, power stage, SOA
design evidence, thermal targets, current-sense chain, gate drive, loop-design
region, power tree, GPIO map, antenna keepout, emergency inhibit, connectors,
programming access, and PCB routing.

Post-fabrication validation includes current sharing, hot-case SOA, thermal
performance, ADC calibration, loaded gate waveform, physical loop response,
startup/brownout/fault transients, regulator temperature, Wi-Fi behavior, and
final DFM inspection. These remain `HARDWARE_VALIDATION = PENDING`.

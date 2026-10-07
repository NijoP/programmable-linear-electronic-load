# PLEL R1 ESP32 Firmware / Programming Interface Review

**Date:** 2026-10-07
**Status:** BLOCKED — not released for schematic generation

## Required interface

The requested external adapter is a CP2102 6-pin USB-to-TTL UART adapter and the required dedicated PCB header is:

| J_PROGRAM pin | Signal |
|---:|---|
| 1 | GND |
| 2 | 3V3 |
| 3 | ESP_TX / U4 GPIO1 / U0TXD |
| 4 | ESP_RX / U4 GPIO3 / U0RXD |
| 5 | EN |
| 6 | GPIO0 |

This interface is not yet represented in the authoritative BOM. The current BOM has `J2` as a 1x2 connector containing only TX0 and RX0, so it cannot satisfy the required recovery/programming contract.

## Findings

### UART routing

The ESP32 pin map correctly identifies:

- U4 pin 35 / GPIO1 / U0TXD → `ESP_TX`
- U4 pin 34 / GPIO3 / U0RXD → `ESP_RX`

The current two-pin J2 does not provide GND, 3V3, EN, or GPIO0. A new authoritative six-position `J_PROGRAM` record, including an exact connector MPN/package or an explicitly approved generic footprint, is required.

### EN/reset network

The current BOM contains no explicit EN pull-up resistor, EN reset capacitor, or reset pushbutton/network. The repository only states that EN/reset circuitry is required. No values or exact topology are authoritative.

`BOOT_RESET_NETWORK = FAIL` until the ESP32 hardware-design requirement is selected and recorded with exact values and references.

### GPIO0/BOOT network

The current BOM contains no explicit GPIO0 pull-up, boot switch, or other manual BOOT network. GPIO0 is mapped to U4 pin 25, but its required strap behavior is not implemented in the BOM.

`BOOT_RESET_NETWORK = FAIL`.

### Decoupling and support passives

The current BOM contains:

- C4: 10 uF on 3V3
- C8–C12: five generic 100 nF local bypass capacitors

The BOM does not assign C8–C12 to exact ESP32/safety/analog locations, and it does not define the complete ESP32 EN/GPIO0 support network. The manufacturer hardware-design requirement and the exact placement/value allocation must be recorded before this gate can pass.

`ESP32_SUPPORT_PASSIVES = FAIL`.

### CP2102 power-domain safety

The selected CP2102 adapter MPN is not documented. Therefore the following are unresolved:

- whether its 3V3 pin is a regulated output or reference/IO-level output;
- whether it is allowed to power the ESP32;
- whether its 5V pin can be present at the header;
- how back-powering of the PLEL 3V3 rail is prevented;
- whether the adapter's GND/IO voltage is compatible with the selected ESP32 supply;
- whether DTR/RTS are present (they must not be assumed).

The safe baseline must be an explicit policy that CP2102 3V3 is reference/logic only unless an isolated power-path decision is approved. No such decision is currently recorded.

`POWER_DOMAIN_SAFETY = FAIL`.

### Recovery procedure

A complete engineering procedure is not currently recorded for:

1. powering PLEL from its controlled 3.3 V rail;
2. connecting adapter GND/TX/RX;
3. manually holding GPIO0 low;
4. asserting/releasing EN;
5. entering the ROM bootloader;
6. flashing over UART0;
7. releasing GPIO0 and resetting into normal boot;
8. ensuring the adapter does not power the board or any unsafe load path.

`ESP32_FIRMWARE_INTERFACE = FAIL` and `PROGRAMMING_HEADER = FAIL`.

## Required engineering decisions

1. Select and document the exact six-pin `J_PROGRAM` connector/footprint.
2. Approve exact EN pull-up/reset components and values from the ESP32 manufacturer hardware-design guidance.
3. Approve exact GPIO0 boot-strap/manual BOOT components and values.
4. Allocate the existing C4/C8–C12 capacitors to explicit rails/devices and add any missing manufacturer-required ESP32 capacitance.
5. Identify the exact CP2102 adapter or explicitly define the adapter-independent voltage/power contract.
6. Prohibit CP2102 5 V from reaching ESP32 3V3 and define whether CP2102 3V3 is reference-only or permitted to power the module.
7. Record the manual UART flashing/recovery procedure.

No BOM or connection-matrix entries were invented for these unresolved items.

# PLEL R1 Product Summary

PLEL R1 is a 10–15 V, 2 A, 30 W peak programmable linear DC electronic load
controlled by a local ESP32-hosted web application. CC, CP, CR, and Battery
Discharge/Test are supported. R1 removes the OLED, rotary encoder, encoder
switch, and ordinary START/STOP buttons. A normally-closed physical emergency
STOP remains.

The browser is never the direct load-control or safety path. ESP32 command
validation and the supervisory state machine bound requests before MCP4725 /
LM358B control. Wi-Fi loss produces a supervisory safe-off timeout; the
hardware emergency STOP remains independent.

The electrical power stage remains four BUZ11 devices, 0.01 ohm shunt,
INA180A3, MCP4725, LM358B, 10 kΩ NTC, and VIN → 5 V → 3.3 V power tree.

See `docs/PRODUCT_REQUIREMENTS_R1.md`, `docs/WEB_INTERFACE_ARCHITECTURE_R1.md`,
`docs/ESP32_GPIO_MAP_R1.md`, and `docs/EMERGENCY_STOP_R1.md`.

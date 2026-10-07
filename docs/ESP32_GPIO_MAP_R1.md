# ESP32-WROOM-32E GPIO Map — PLEL R1

| Function | GPIO/pin | Direction/constraint | Provenance |
|---|---:|---|---|
| I2C SDA: MCP4725 | 21 | Bidirectional I2C | FROZEN_FROM_PDF / R1 retained |
| I2C SCL: MCP4725 | 22 | Output I2C | FROZEN_FROM_PDF / R1 retained |
| Current ADC | 35 | Input-only ADC | FROZEN_FROM_PDF |
| VIN ADC | 34 | Input-only ADC | FROZEN_FROM_PDF |
| NTC ADC | 39 | Input-only ADC | FROZEN_FROM_PDF |
| Fan control | 26 | Output; boot-safe external bias | FROZEN_FROM_PDF |
| Fault input | 27 | Input with defined pull/bias | FROZEN_FROM_PDF |
| Web run enable | 25 | Output to hardware enable logic; default low | R1 DESIGN_TARGET |
| Emergency STOP monitor | 33 | Input-only safety status monitor; NC contact dominates hardware path | R1 DESIGN_TARGET |
| Service UART TX | 1 | UART0 TX/programming | FROZEN_FROM_PDF |
| Service UART RX | 3 | UART0 RX/programming | FROZEN_FROM_PDF |
| Boot strap | 0 | Must retain required boot strap network | FROZEN_FROM_PDF |
| Reset | EN | Dedicated module enable/reset | FROZEN_FROM_PDF |

GPIO18, GPIO19, and GPIO23 are freed from the R0 encoder and encoder-switch
functions. GPIO25 is no longer START/STOP; it is a default-low supervisory run
enable. There is no OLED bus device in R1, although I2C remains for MCP4725
and future service expansion. ADC pins remain input-only and are not assigned to
Wi-Fi or digital output functions.

The final schematic must verify ESP32 strap levels, GPIO boot behavior, EN
reset behavior, ADC attenuation/range, UART access, antenna keepout, and
external safe biasing. These are pre-fabrication design checks; electrical
behavior on the assembled module remains hardware validation.

# PLEL R1 Power Tree Result

The R1 power tree is VIN → L7805CV 5 V → AP2112K-3.3 3.3 V.

## Design budget

- 5 V rail design budget: `150 mA`
- 3.3 V rail worst-case budget: `548 mA`
  - ESP32 RF/peak design allowance: 500 mA
  - status/support electronics: 48 mA
- AP2112K nominal current rating: `600 mA`
- Calculated current margin: `52 mA`
- 5 V regulator illustrative dissipation at 15 V: `(15−5)*0.15 = 1.5 W`
- 3.3 V LDO illustrative dissipation: `(5−3.3)*0.548 = 0.932 W`

The OLED and encoder loads are zero in R1. Regulator copper spreading and
post-fabrication rail-current/temperature measurements remain required.

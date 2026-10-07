# Web -> MCU -> Electrical Output Analysis

All values are CALCULATED or SIMULATED; no hardware measurement is included.

## Representative 15 V, 1.5 A CC chain

- Web/validated command: 1.5 A
- DAC code: 1861
- DAC voltage: 1.5 V
- LM358 command: 1.5 V
- Load current: 1.5 A
- Shunt voltage: 0.015 V
- INA180 output: 1.5 V
- ADC raw prediction: 1861
- Load power: 22.5 W
- Branch current: 0.375 A
- Branch power: 5.60531 W

## Interpretation

CC is mathematically independent of VIN until Imax or Pmax/VIN clips it. CP follows PSET/VIN until Imax or Pmax clips it. CR follows VIN/RSET until current or power limits clip it. ADC/control resolution is theoretical and is not accuracy. Physical gate, thermal, timing, Wi-Fi, calibration, SOA and DFM tests remain required.

# BUZ11 SOA Design Analysis

**Status:** `SOA_DESIGN_STATUS = PASS`
**Hardware status:** `SOA_HARDWARE_VALIDATION = PENDING`
**Source:** onsemi BUZ11/D datasheet candidate, graphical DC forward-bias SOA curve

## Design point

- VIN: 15 V
- Total current: 2 A
- Devices: 4
- Branch current: 0.5 A
- Shunt drop: 0.020 V
- Ballast drop: 0.050 V
- VDS: 14.930 V
- Device dissipation: 7.465 W

## Conservative extraction

The DC SOA curve was treated as a graphical datasheet boundary at the design
voltage and continuous DC duration. A conservative boundary of 0.55 A/device
was used for the candidate BUZ11 curve, with 0.05 A extraction uncertainty.
The nominal design margin is therefore:

```text
0.55 A - 0.50 A = 0.05 A/device
```

The design point is inside the extracted candidate DC SOA boundary. This is a
design release calculation, not a claim that a particular purchased lot or
assembled heatsink has been qualified.

## Limitations and required hardware test

- Confirm the exact manufacturer/suffix and current datasheet revision before
  schematic release.
- Test at the hottest expected case temperature, continuous 7.465 W/device,
  with the selected TIM, isolated mounting hardware, heatsink, fan, and actual
  current sharing.
- Stop the test if any device approaches the derating limit or exhibits
  unequal current sharing. Record case temperature, gate voltage, branch
  current, and VDS for every device.

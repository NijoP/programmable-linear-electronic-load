# PCB Open Items

Open means evidence is still required; it is not a claim that the item is impossible.

| Item | Classification | Required evidence | Release impact |
|---|---|---|---|
| Exact BUZ11/D procurement identity | DESIGN DECISION REQUIRED | Supplier, exact ordering suffix/lot, package drawing | BLOCKED |
| BUZ11 DC SOA | PHYSICAL VALIDATION REQUIRED | Exact-device DC SOA at case temperature/duration plus unequal-sharing margin | BLOCKED |
| Shunt, ballast, gate parts and zeners | DESIGN DECISION REQUIRED | Exact MPN, package, ratings, footprints and availability | BLOCKED |
| 3.3 V LDO, fan, heatsink, fuse, connectors, OLED | DESIGN DECISION REQUIRED | Exact MPN and current/thermal/mechanical datasheet data | BLOCKED |
| Thermal assembly | PHYSICAL VALIDATION REQUIRED | RθSA at defined airflow, TIM/interface, case/junction temperature | BLOCKED |
| Current-sense full error budget | MEASUREMENT REQUIRED | Shunt TCR, ADC transfer/attenuation, Kelvin parasitic and calibration result | BLOCKED |
| Gate drive | PHYSICAL VALIDATION REQUIRED | Required operating VGS, aggregate gate load, LM358B output swing/current and transient response | BLOCKED |
| Loop stability | PHYSICAL VALIDATION REQUIRED | Complete schematic/compensation plus frequency response or validated model | BLOCKED |
| Startup inhibit | DESIGN DECISION REQUIRED | Implemented schematic forcing gate-control OFF for OFF/reset/boot/brownout/fault | BLOCKED |
| Fault strategy | DESIGN DECISION REQUIRED | Hardware fault path, latch/reset policy and test matrix | BLOCKED |
| PCB stackup/routing | DESIGN DECISION REQUIRED | Fabricator stackup, trace/via calculations, Kelvin layout, connector/fuse/antenna review | BLOCKED |
| Regulator power tree | MEASUREMENT REQUIRED | Worst-case rail currents, dropout and regulator temperatures | BLOCKED |

## Closed analytically in this campaign

- CP arithmetic and MATLAB implementation.
- 15 V / 2 A power balance.
- Thermal power partition and governing equations.
- Source trace example and preliminary external-layer width calculation.
- INA180A3 datasheet subtotal and partial uncalibrated error bound.

## Physical test sequence

1. Control electronics only, with MOSFETs removed.
2. Current-sense calibration using a reference current.
3. One MOSFET at 10 V/0.2 A.
4. Four MOSFET staged points: 10 V/0.5 A, 12 V/1 A, 15 V/1.5 A, then 15 V/2 A.
5. Temperature, sharing, SOA-duration, startup-inhibit, fault and loop-response tests.

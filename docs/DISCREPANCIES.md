# Discrepancies, ambiguities and engineering decisions

The archived PDF is preserved unchanged. Source references below use section numbers and **physical PDF pages** (cover=1), not section numbers masquerading as pages. Decisions are software/engineering policies unless explicitly supported by source evidence.

## D-001 — MCP4725 denominator and command cap: resolved

Source §13, physical page 12, eq. 35 uses `3.3/4095` and eq. 38 uses `4095*2/3.3`. Microchip DS22039D §5.1 eq. 5-1, page 19, gives `Vout=Vdd*code/4096`; see evidence E-001. The user's explicit requirement agrees with the datasheet.

Implement 4096. Keep the proposed source eq. 39 cap **2482**:

- `2*4096/3.3 = 2482.424242...`, so **floor = 2482**, not 2483.
- Code 2482 gives **1.999658203125 V** at nominal 3.3 V.
- Code 2483 gives **2.0004638671875 V**, above the ideal 2 V request.
- LSB = **0.8056640625 mV**; with nominal 1 V/A sense scaling, **0.8056640625 mA/LSB**.
- 4096 is the transfer denominator/code count, **not a representable code or safe clamp value**. Codes are 0…4095.

Flooring a request and applying code cap 2482 is a nominal no-overshoot policy; real current protection still requires tolerances, calibration and hardware review.

## D-002 — Thermal targets versus actual properties: unresolved qualification

Source §19, physical pages 15–16, explicitly assumes Rjc≈1.67 K/W, Rcs=0.5 K/W and ambient=35 C. The sink target <=1.5 K/W is not a purchased heatsink specification. Store these separately from null actual properties. A shared sink heats from **total** bank power; junction-to-case/interface rise uses **each branch's** power. Do not apply the total per-device resistance independently to each MOSFET while ignoring other devices heating the same sink.

## D-003 — Power boundary and battery metering: unresolved topology

Source §18 power balance excludes the input-powered regulators (§27), fan and other auxiliaries. Whether they flow through the shunt is unspecified. Nominal models must report controlled-branch power separately; battery charge/energy must declare the current measurement boundary. A 15 V source rated exactly 2 A may not support 2 A controlled current plus auxiliary current.

## D-004 — Default off versus DAC EEPROM startup: unresolved hardware safety

Source §§7.3/31/37 require default off. The MCP4725 can restore nonzero EEPROM settings, including factory midscale, before firmware writes zero (E-002). Gate pull-downs do not prove off with active op-amp drive. Schematic-level inhibit, supply sequencing, brownout/reset tests and EEPROM handling remain required.

## D-005 — NTC divider orientation: unresolved

Source §26 physical page 19 gives an equal-resistance 25 C example (1.65 V). It does not establish upper/lower NTC placement. Models must take explicit orientation. NTC nominal beta is not a calibrated temperature transfer; placement and lag require measurement.

## D-006 — Thermal derating law and hysteresis: unspecified

Source §26 physical page 20 proposes 60/75/85 C thresholds but no derating law or hysteresis. Keep both TBD. Proposed conservative software baseline: disable at 75 C when no explicit derating policy is supplied; latch overtemperature at/above 85 C. This is **not** a claimed PDF derating equation. Fan PWM and reset rules are not invented source parameters.

## D-007 — Trace example versus fabrication preference

Source §9 prefers 2 oz copper if affordable; §33 uses a 35 um trace purely for illustration. Keep actual copper thickness TBD. The example's resistance does not establish connector/via ampacity or board temperature rise.

## D-008 — Analog-loop headroom/stability: unresolved

Source §20's assumed 5 V drive does not mean a 5 V-powered LM358B can drive to its positive rail. Source §27 does not fully specify the amplifier supply. RC corners in §§14.1/15 are not closed-loop bandwidths or phase margins. BUZ11 nonlinear parameters, exact compensation, loop transfer and device/temperature SOA remain qualification tasks.

## Rejected first implementation (Astra review)

The initial generated draft contained a 4096 code cap, incorrect DAC arithmetic, inaccurate source-page references, missing NTC/PCB/rail/TBD inputs, a broken MATLAB bootstrap/loader/test, a hash check that only printed the hash, and ignore rules excluding the registry. These were implementation defects, not source discrepancies. They must be corrected before accepting milestone 1. Test generation is not test execution, and an unexecuted test must never be described as guaranteed to pass.

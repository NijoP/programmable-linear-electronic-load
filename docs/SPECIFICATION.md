# Traceable engineering specification

> **PLEL R1 revision note:** The source PDF remains authoritative for the
> electrical baseline, but its OLED/encoder/button interface is superseded for
> the R1 product by the controlled local web architecture documented in
> `docs/PRODUCT_REQUIREMENTS_R1.md`. The source requirement is retained here
> for traceability and is not an active R1 PCB population requirement.

Primary authority: [`source/design-source.pdf`](source/design-source.pdf), September 2026, Goutham Haridas and Afnan Muhammad. This is a **first-pass prototype design**. Physical PDF page numbering is 1-based (cover=1); printed page number = physical page minus 1. Requirements are not evidence of assembly qualification.

## Frozen product targets

Source §9 Table 1, physical page 10:

| Parameter | Source target |
|---|---|
| Input | 10–15 V DC |
| Maximum controlled current | 2 A |
| Peak electrical loading | 30 W; allowable duration TBD |
| Initial continuous loading | 24 W recommended; not qualified |
| CC range | 0.1–2 A |
| CP setpoint range | Approximately 5–30 W, subject to simultaneous limits |
| CR useful range | Approximately 5–150 ohm, subject to simultaneous limits |
| Power stage | 4 × BUZ11 candidate MOSFETs in linear operation |
| Current shunt | 0.01 ohm, 3 W, 1% |
| Current amplifier | INA180A3, nominal gain 100 V/V (§12, page 11) |
| Reference | MCP4725 12-bit DAC |
| Analog loop | LM358B |
| MCU | ESP32-WROOM-32, directly soldered to PCB |
| R1 user interface | ESP32-WROOM-32E local Wi-Fi web application; emergency STOP only; source OLED/encoder/buttons superseded for R1 |
| Temperature | 10 kohm NTC at 25 C, beta approximately 3950 K (§26, page 19) |
| PCB | Two-layer FR-4, approximately 100 × 100 mm; 2 oz copper preferred if affordable |

Control electronics use linear regulators; the main load is not a DC-DC converter. Solar conversion, IoT/cloud, AC-DC/inverter operation and circuit-breaker/e-fuse functionality are excluded (§4). All-inclusive budget ceiling approximately INR 10,000 (§40, page 29); procurement prices/stock are not frozen.

## Equations and implementation boundaries

| Model | Required relationship | Source |
|---|---|---|
| Shunt | Vsh=I Rsh; Psh=I²Rsh | §11, pp.10–11, eqs.21–24 |
| Current sensing | Vsense=100 Vsh; nominal gain×Rsh=1 V/A | §12, p.11, eqs.25–33 |
| DAC | Vout=Vdd code/4096; LSB=3.3/4096; codes0…4095; proposed load cap2482 | Corrected §13 via D-001 and E-001 |
| Divider | Vadc=Vin R2/(R1+R2), R1=33 kohm, R2=7.5 kohm | §14, p.12, eqs.40–44 |
| Voltage filter | Rth=R1 R2/(R1+R2); fc=1/(2 pi Rth Cadc), Cadc=47 nF | §14.1, p.13, eqs.47–49 |
| Current filter | fc=1/(2 pi Rf Cf), Rf=10 kohm, Cf=100 nF | §15, p.13, eqs.50–52 |
| Ideal branch sharing | Ibranch=I/4 | §16, p.14, eq.54; real sharing must be measured |
| Ballast | Rballast=0.1 ohm; Vballast=Ibranch Rballast; Pballast=Ibranch²Rballast | §17, p.14, eqs.57–59 |
| MOSFET power | Pbank=Vin I−Psh−sum(Pballast); Pequal=Pbank/4 | §18, p.15, eqs.60–64; excludes auxiliaries/wiring |
| Analog loop | Ve=Vset−Vsense; nominal equilibrium I=Vset/(gain Rsh) | §21, pp.16–17, eqs.78–84 |
| CC | Icmd=Iset before separate safety limits | §22, p.17, eq.85 |
| CP | Ireq=Pset/Vin; Icmd=min(Imax,Pmax/Vin,Pset/Vin) | §23, p.18 |
| CR | Ireq=Vin/Rset; Icmd=min(Imax,Pmax/Vin,Vin/Rset) | §24, pp.18–19 |
| Shared thermal network | Tsink=Ta+Pbank Rsa; Tj,k=Tsink+Pk(Rjc,k+Rcs,k) | §19, pp.15–16; explicit algebra of the described network, assumed resistances only |
| NTC beta | R(T)=R0 exp[B(1/T−1/T0)], T/T0 in kelvin | §26, p.19, eq.109 |
| Regulator loss | P=(Vin−Vout) Irail, ignoring quiescent current in source example | §27, p.20, eqs.116–117 |
| Battery charge | Q=integral I dt; source sample sum I[k] dt | §30, p.22, eqs.119–120 |
| Battery energy | E=integral Vin I dt; source sample sum Vin[k] I[k] dt | §30, p.22, eqs.121–122 |
| Copper | R=rho L/(width thickness); Vdrop=IR; P=I²R | §33, p.24, eqs.125–129 |

Use seconds for integration and divide coulombs/joules by 3600 to obtain Ah/Wh. Nonuniform sampling requires explicit interval durations or timestamps; method and current measurement boundary must be documented. No battery chemistry cutoff is supplied.

For CC preserve the requested `Iset`; apply the same independent current/power envelope as other modes. Reject nonfinite/invalid values and fail disabled outside the specified voltage range before division. Do not interpret a clipped current as achieved CP/CR regulation. Nominal 24 W mode and explicitly selected 30 W analytical exploration are distinct; neither authorizes unqualified hardware operation.

## Protection and firmware requirements

Source §26, physical page20, proposes:
- T<60 C: normal cooling.
- 60<=T<75 C: high fan.
- 75<=T<85 C: derating (law unspecified).
- T>=85 C: shutdown.

Source §31, pp.22–23, calls for fuse, gate pull-downs/zeners, current/power clamp, temperature shutdown, fan, sensor plausibility and fault latch. Independent analog overcurrent comparator is a **future revision**, not already implemented hardware. Missing hysteresis, derating, fault-reset rules and startup inhibit are tracked as TBD.

Source §37, p.27, proposes POWER_ON → SELF_TEST → STANDBY/SETTING → ACTIVE, with FAULT and RESET. POWER_ON/SELF_TEST/FAULT must command zero. This defines a future software model, not deployed ESP32 firmware or proof of electrical off-state.

## Required physical verification

Source §35 Table3 and §§36/44 require staged bring-up, zero/gain calibration, actual branch-current measurement, MOSFET SOA review, thermal characterization and loop stability measurements. Begin with control electronics only, then current sensing, then one MOSFET at 10 V/0.2 A, then gradual four-device loading (§36). Do not proceed to high-power hardware tests solely because software tests pass.

**Milestone 1 scope:** source/registry/architecture/bootstrap/tests. Circuit models, simulations, plots, embedded firmware, schematic and PCB layout are not yet delivered. See `IMPLEMENTATION_PLAN.md` for the staged implementation.

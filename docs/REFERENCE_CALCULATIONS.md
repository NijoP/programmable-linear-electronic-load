# Astra analytical reference calculations

These are **calculated reference cases**, not measurements or executed MATLAB model results. They use unrounded source inputs. The PDF's rounded displayed outputs are preserved by citation rather than promoted into independent registry parameters. All thermal/sharing cases are expressly ideal/illustrative.

| Case | Calculation | Unrounded/reference result | Source |
|---|---|---|---|
| Peak target | 15 V × 2 A | 30 W | §10 eq.20, physical p.10 |
| Shunt at 2 A | 2 × 0.01 | 0.02 V | §11 eq.22, p.11 |
| Shunt loss | 2² × 0.01 | 0.04 W | §11 eq.23, p.11 |
| Shunt nominal rating ratio | 3/0.04 | 75 | §11 eq.24, p.11; not transient qualification |
| Sense output | 100 × 0.02 | 2 V | §12, p.11 |
| DAC step | 3.3/4096 | 0.0008056640625 V | Corrected §13; E-001 |
| Nominal code cap output | 2482 × 3.3/4096 | 1.999658203125 V | D-001 |
| Divider ratio | 7500/(33000+7500) | 0.185185185185… | §14 eq.43, p.12 |
| Divider at 15 V | 15 × ratio | 2.777777777777… V | §14 eq.44, p.12 |
| Divider current | 15/40500 | 0.000370370370… A | §14 eq.45, p.13 |
| Divider power | 15²/40500 | 0.005555555555… W | §14 eq.46, p.13 |
| Divider Thevenin | 33000 × 7500/40500 | 6111.111111… ohm | §14.1 eq.47, p.13 |
| Voltage-filter corner | 1/(2 pi Rth × 47e-9) | 554.117790261918 Hz | §14.1 eq.49, p.13 |
| Current-filter corner | 1/(2 pi × 10000 × 100e-9) | 159.154943091895 Hz | §15 eq.52, p.13 |
| Ideal branch current | 2/4 | 0.5 A | §16 eq.54, p.14 |
| Per-branch ballast drop/loss | 0.5 × 0.1; 0.5² × 0.1 | 0.05 V; 0.025 W | §17, p.14 |
| Bank dissipation | 30−0.04−4 × 0.025 | 29.86 W | §18 eq.63, p.15 |
| Per-device dissipation | 29.86/4 | 7.465 W (PDF rounds to 7.47) | §18 eq.64, p.15 |
| Per-device Vds | 15−0.02−0.05 | 14.93 V | Algebra of §§11/17/18 power path |
| Shared sink (illustrative) | 35+29.86 × 1.5 | 79.79 C | §19 described thermal network |
| Each junction (illustrative) | 79.79+7.465 × (1.67+0.5) | 95.98905 C | §19 assumptions, pp.15–16 |
| CC at 15 V / 1.5 A | 15 × 1.5 | 22.5 W | §22 eq.88, p.17 |
| CC at 12 V / 1.5 A | 12 × 1.5 | 18 W | §22 eq.89, p.17 |
| CP 20 W at 15/12/10 V | 20/Vin | 1.333333… / 1.666666… / 2 A | §23, p.18 |
| CR 15 ohm at 15/12 V | Vin/15 | 1 / 0.8 A | §24/§42.3, pp.19/31 |
| NTC at reference | R0 exp[B(1/T0−1/T0)] | 10000 ohm at 25 C | §26 eq.109, p.19 |
| Equal NTC divider | 3.3 × 10000/(10000+10000) | 1.65 V | §26 eq.108, p.19 |
| 7805 example loss | (15−5) × 0.15 | 1.5 W | §27 eq.116, p.20 |
| 3.3 V LDO example loss | (5−3.3) × 0.15 | 0.255 W | §27 eq.117, p.20 |
| Copper example resistance | 1.724e-8 × 0.1/(0.005 × 35e-6) | 0.009851428571… ohm | §33, p.24 |
| Copper at 2 A | 2R; 2²R | 0.019702857142… V; 0.039405714285… W | §33 eqs.128–129, p.24 |

No filter-corner result establishes phase margin. No thermal result establishes actual cooling or SOA. Neither ideal branch sharing nor the 30 W arithmetic proves continuous operation. Auxiliary rail losses are not included in the MOSFET-bank power balance. The two example rail currents are not a complete cascade/fan/ESP32 power budget.

Future tests must cover not only these nominal points but zero/off behavior, simultaneous constraints, thermal threshold boundaries, invalid inputs, unknown calibration and quantization limits.

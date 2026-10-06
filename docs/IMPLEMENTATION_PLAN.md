# Astra engineering implementation plan

## Authority and scope

Primary source: `docs/source/design-source.pdf`, 34 physical pages (cover then printed pages 1–33), September 2026, Goutham Haridas and Afnan Muhammad. Text extraction is a search aid; missing mathematical glyphs and mangled tables must be resolved against the PDF. No Firstmate or MATLAB MCP integration. Initial deliverable is an engineering software foundation, not fabricated PCB files, qualified hardware, or deployable embedded firmware.

Astra owns planning, engineering decisions, source/datasheet review, verification, integration, commits and pushes. NVIDIA Nemotron implements bounded tasks. Each milestone follows plan → implement → Astra review/correction → tests → commit → push. Report unavailable runtime checks honestly.

## Milestones

1. **Source and architecture**: archive and hash PDF; engineering specification, discrepancies, parameter registry with provenance; directory architecture and MATLAB bootstrap; portable registry checks.
2. **Electrical/control foundation**: hardware representation, nominal sensing, divider/RC, DAC transfer, explicit ADC calibration interface, MOSFET branch/power balance, regulator losses, CC/CP/CR commands and safety limits; analytical reference cases and MATLAB tests.
3. **Supervisory models**: steady-state shared-heatsink model, NTC forward/inverse, thermal policy, latched state machine, battery integration, copper parasitics; fail-closed missing values; MATLAB tests.
4. **Reproducibility and validation**: static operating-point simulation and explicit-parameter illustrative dynamics only, sweeps, plots, deterministic demo, automated test/CI entrypoints, validation/measurement schemas, final engineering review.

The user's detailed subsystem order is preserved inside these milestones. Do not claim physical validation from analytical checks.

## Software architecture

- `data/parameters.json`: authoritative non-derived parameter registry. Every entry has unique ID, value (null when TBD), unit, classification, source section/physical page or datasheet evidence, context (specification/nominal/provisional/illustrative/unknown), and notes. Allowed classifications: FROZEN_FROM_PDF, DATASHEET, MEASURED, CALIBRATED, TBD. Frozen provenance does NOT mean physically qualified. Derived quantities are function outputs, not invented source parameters.
- `matlab/project/`: explicit startup/bootstrap and strict registry loading; no machine-local absolute paths or toolbox dependency for core models. A genuine MATLAB project can be created later using MATLAB APIs; do not fake a `.prj` file.
- `matlab/{hardware,electrical,control,thermal,power,sensors,protection,firmware,battery,simulation,validation,analysis,plotting,main}/`: deterministic functions prefixed `plel_`; explicit arguments/outputs in SI units (temperature suffix `_C` or `_K`). No globals, hidden environment inputs, or fabricated calibration defaults.
- `tests/`: native MATLAB assertion suite plus Python standard-library source/registry checks. Python arithmetic checks are NOT execution of MATLAB functions.
- `measurements/`: empty templates with units, instrument/calibration metadata and DUT identification; never synthetic data presented as measured.
- `results/`: generated artifacts ignored except documentation; deterministic demos record model scope and provenance.

## Engineering decisions and constraints

1. **DAC discrepancy D-001**: PDF §13 eqs. 35/38 use 4095 denominator; user explicitly requires 4096. MCP4725 datasheet DS22039D §5.1, equation 5-1 confirms Vout = Vdd × code / 4096, code 0…4095. Implement 4096, archive the original discrepancy. Use floor for non-overshooting nominal commands and PDF cap 2482; code 2482 gives 1.999658203125 V at nominal 3.3 V. This is not an absolute current safety guarantee without tolerances/calibration.
2. **Power envelope**: 30 W is a peak *target*, with permitted duration TBD. 24 W is an initial continuous *target*, not a qualified rating. Nominal simulation defaults to the 24 W envelope; 30 W analytical exploration is explicitly selected and never hardware-authorized. CC request equals Iset; apply independent current/power/voltage/thermal safety limits afterward. CP/CR preserve PDF minimum equations. Invalid/nonfinite inputs and outside 10–15 V must not produce enabled load commands. Do not silently enforce 0.1 A by increasing low requests.
3. **Model boundary**: PDF power balance covers the controlled shunt/MOSFET branch. Input-powered regulators, fan, divider and other auxiliaries may add source current. Total source measurement/shunt topology is unresolved; battery capacity must identify the current measurement boundary.
4. **MOSFET model**: equal sharing is explicitly an ideal case; accept explicit branch fractions for unequal-sharing calculations. Bank loss = Vin I − I²Rsh − sum(Ibranch²Rballast), excluding unmodeled wiring/auxiliaries. Per-device Vds includes common shunt and own ballast drop. No arbitrary Vth/gm or SOA margin. Exact BUZ11 manufacturer and DC SOA at temperature TBD.
5. **Thermal**: shared sink temperature = ambient + total bank power × Rsa; each junction = sink + branch power × (Rjc + Rcs). PDF 1.67 C/W, 0.5 C/W, 35 C ambient, 100 C junction target, and 1.5 C/W sink target are preliminary/illustrative, not measured. Actual thermal resistance/capacitance, airflow and NTC placement TBD. No credible dynamic thermal model without explicit capacitances.
6. **NTC**: preserve beta equation in kelvin; nominal R0=10 kohm at 25 C, beta≈3950 K, reference resistor 10 kohm. Divider orientation is unspecified: require explicit orientation, not a fabricated physical wiring assignment. Suggested 60/75/85 C thresholds are provisional; derating law/hysteresis remain TBD. At/above 75 C, safe baseline is disable until an explicitly supplied derating policy exists; at/above 85 C latch a fault.
7. **ADC/loop**: ESP32 ADC attenuation, effective calibrated transfer and accuracy TBD. No default ideal 3.3 V ADC masquerading as hardware behavior. RC corners do not establish closed-loop bandwidth or stability. LM358B supply/headroom, exact compensation/gate dynamics and stability remain unresolved.
8. **Startup safety**: MCP4725 restores stored DAC settings at startup (datasheet). Software zero and gate pulldowns alone are not proven hardware disable while op-amp drives. Startup/reset/brownout inhibit circuit and safe EEPROM policy must be qualified. State-machine models default off and latch faults but are not independent hardware protection.
9. **Battery/PCB**: integrate current and Vin×I with explicit timestamps or interval durations, convert seconds to Ah/Wh via 3600. Battery chemistry/cutoff is caller-supplied, constrained by hardware voltage range. Copper example 35 um is illustrative, not the preferred 2 oz fabrication requirement. Routing geometry, resistivity temperature dependence and thermal ampacity remain separate qualification tasks.

## Acceptance gates

Each public numerical function rejects NaN/Inf, complex and dimensionally invalid inputs. Native MATLAB tests cover source reference points, boundaries, quantization, invalid values and safety behavior. Registry checks enforce provenance and null TBD values. Final documentation separates source-faithful nominal mathematics, proposed software policies, datasheet-backed facts, and measurements still required. MATLAB execution requires an installed runtime or CI; static/Python checks must never be reported as native MATLAB test success.

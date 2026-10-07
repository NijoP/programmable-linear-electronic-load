# PCB Requirements and Closure Status

Primary requirements are frozen by `docs/source/design-source.pdf`; values below are not replacements for that source.

## Frozen design requirements

| Requirement | Value | Provenance | Status |
|---|---:|---|---|
| Input | 10–15 VDC | FROZEN_FROM_PDF §9 | ANALYTICALLY CLOSED |
| Maximum controlled current | 2 A | FROZEN_FROM_PDF §9 | ANALYTICALLY CLOSED |
| Peak load power | 30 W | FROZEN_FROM_PDF §§9–10 | ANALYTICALLY CLOSED; physical qualification open |
| Initial continuous target | 24 W | FROZEN_FROM_PDF §9 | DESIGN TARGET |
| MOSFET bank | 4 × BUZ11 candidate | FROZEN_FROM_PDF §9 | DESIGN DECISION REQUIRED |
| Shunt | 0.01 Ω, 3 W, 1% | FROZEN_FROM_PDF §9/§11 | Exact MPN TBD |
| Sense gain | 100 V/V INA180A3 | FROZEN_FROM_PDF §12; DATASHEET corroboration | DATASHEET CLOSED nominally |
| Ballast | 0.1 Ω/device, 3 W example | FROZEN_FROM_PDF §17 | Exact MPN TBD |
| Gate network | 1 kΩ, 100 kΩ, approximately 8.2 V zener/device | FROZEN_FROM_PDF §20 | Exact MPN TBD |
| Electronics rails | VIN → 5 V → 3.3 V | FROZEN_FROM_PDF §27 | Architecture closed; parts/thermal open |
| PCB | 2-layer FR-4; preferred 2 oz copper | FROZEN_FROM_PDF §§9/32 | Stackup TBD |

## Derived routing constraints

- At 2 A, 2 oz external copper and 10 °C allowed rise, the IPC-2221 empirical check in `matlab/validation/pcb_readiness_closure.m` gives **0.385 mm minimum width** under its stated assumptions. This is CALCULATED, not a universal fabricator rule.
- Use **1.0 mm minimum design target** for the main 2 A external-layer path until the actual stackup, length and voltage-drop budget are reviewed. This is a DESIGN_TARGET, not a source requirement.
- The source's 100 mm × 5 mm × 35 µm example is illustrative. For 2 oz copper the same geometry calculates to 4.925 mΩ, 9.85 mV and 19.7 mW at 2 A.
- Main current paths must avoid neck-downs; final via diameter/count requires the selected PCB fabricator's finished-hole and current/thermal data (TBD).
- Shunt sensing must use a four-terminal/Kelvin topology. Final sense geometry and allowable parasitic resistance are DESIGN DECISIONS tied to the error budget.
- Connector current rating, fuse rating, creepage/clearance and ESP32 antenna keepout must be verified against selected component and module drawings (TBD).

## Safety requirements

- Gate control must have a defined hardware OFF state during MCU OFF, reset, boot, brownout and fault. A digital AND description is not a valid analog implementation.
- A fault latch/reset policy and independent fault path must be defined before fabrication.
- MOSFET-to-heatsink interface, TIM, mounting and airflow must be documented separately from PCB thermal copper.
- No continuous-power or SOA claim may be made from MATLAB results alone.

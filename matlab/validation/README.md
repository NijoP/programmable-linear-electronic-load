# Validation and Reports

This module implements the validation infrastructure, analysis, and engineering reporting for the programmable linear DC electronic load.

## Conventions

- All functions use the `plel_` prefix.
- Validation compares simulation results against source specification reference cases.
- Plots use supplied data or simulation records; no hidden recomputation.
- Engineering reports summarize provenance, not physical qualification.
- All TBD parameters are explicitly noted as unresolved.

## Available Functions

| Function | Description |
|---|---|
| `plel_validate_cc(Iset, Vin, Imax, Pmax)` | Validate CC mode against source reference cases |
| `plel_validate_cp(Pset, Vin, Imax, Pmax)` | Validate CP mode against source reference cases |
| `plel_validate_cr(Vin, Rset, Imax, Pmax)` | Validate CR mode against source reference cases |
| `plel_engineering_report()` | Generate structured provenance report |

## Key Reference Cases (from source specification)

| Case | Expected | Source |
|---|---|---|
| 2 A through 0.01 ohm shunt → 20 mV | Vsh = 20 mV | §11, p.11 |
| INA180A3 gain 100 V/V → 2 A → ~2 V sense | Vsense ≈ 2 V | §12, p.11 |
| 15 V at 1.5 A → 22.5 W | P = Vin × I | §22, p.17 |
| 15 V, 20 W CP → ~1.333 A | I = P/Vin | §23, p.18 |
| 12 V, 20 W CP → ~1.667 A | I = P/Vin | §23, p.18 |
| 15 V, 15 ohm CR → 1 A | I = Vin/Rset | §24, p.18-19 |
| 12 V, 15 ohm CR → 0.8 A | I = Vin/Rset | §24, p.19 |

## Error Handling

- Nonfinite or non-scalar inputs → error
- Undefined/unknown parameters → error (no silent defaults)
- Reference case comparisons are validation aids only, not certification

## MATLAB API

```matlab
result = plel_validate_cc(1.5, 15, 2, 30); % returns struct with pass/fail
report = plel_engineering_report(); % returns provenance summary string
```
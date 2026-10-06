# Power Stage Models

This module implements the four-BUZ11 MOSFET power stage with current sharing and power dissipation.

## Conventions

- All functions use the `plel_` prefix.
- Functions operate on per-branch or bank-total values as documented.
- All quantities use SI units unless otherwise noted.
- Parameters are obtained from the registry (`plel_parameter`) for provenance tracking.
- Equal sharing is the ideal case; unequal sharing must be measured.

## Available Functions

| Function | Description |
|---|---|
| `plel_mosfet_branch_current(I_total, N_mosfets)` | Compute ideal branch current from total current |
| `plel_mosfet_branch_power(Vin, I_branch, Rsh, Rballast)` | Compute MOSFET branch power dissipation |
| `plel_mosfet_bank_dissipation(Vin, I_total, Rsh, Rballast, N_mosfets)` | Compute total bank and per-device power |
| `plel_current_sharing_ratio(N_mosfets, unequal_fractions)` | Compute current fractions for N devices |

## Parameter Access

- `N_mosfets` = `plel_parameter(entries, 'num_mosfets')` → 4
- `Rballast` = `plel_parameter(entries, 'ballast_ohm')` → 0.1 ohm
- Nominal equal sharing assumes I_branch = I_total / N_mosfets

## Key Equations

| Model | Equation | Source |
|---|---|---|
| Branch current | I_branch = I_total / N | §16, p.14, eq.54 |
| Bank loss | P_bank = Vin×I - I²×Rsh - N×I_branch²×Rballast | §18, p.15, eq.60-63 |
| Per-device dissipation | P_each = P_bank / N (ideal) | §18, p.15, eq.64 |
| Vds per branch | Vds = Vin - I_branch×Rsh - I_branch×Rballast | §§11,17,18 |

## Error Handling

- Nonfinite or non-scalar inputs → error
- Negative values → error
- Undefined N_mosfets → error (check registry)
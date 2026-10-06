# Battery Discharge Models

This module implements battery discharge capacity and energy calculations for the programmable linear DC electronic load.

## Conventions

- All functions use the `plel_` prefix.
- Charge/energy integration uses explicit time grids.
- All quantities use SI units unless otherwise noted.
- Battery cutoff voltage and chemistry are caller-supplied.
- Current measurement boundary must be declared (whether auxiliaries pass through the shunt).

## Available Functions

| Function | Description |
|---|---|
| `plel_battery_charge(I, dt_s, method)` | Compute charge accumulated in Ah |
| `plel_battery_energy(Vin, I, dt_s, method)` | Compute energy accumulated in Wh |
| `plel_integrate_trapezoidal(y, dt)` | Trapezoidal integration helper |
| `plel_default_sample_period()` | Default sample period suggestion |

## Key Equations

| Model | Equation | Source |
|---|---|---|
| Charge (sampled) | `Q = Σ I[k] × Δt[k]` | §30, physical page 22, eq.119 |
| Energy (sampled) | `E = Σ V[k] × I[k] × Δt[k]` | §30, physical page 22, eq.121 |
| Charge (uniform) | `Q = I × t / 3600` | Ah conversion |
| Energy (uniform) | `E = V × I × t / 3600` | Wh conversion |

## Parameter Access

- Default sample period: derived from typical firmware update rates
- Current measurement boundary: caller must declare if auxiliaries pass through shunt

## Error Handling

- Nonfinite or non-scalar inputs → error
- Negative time → error
- Mismatched vector lengths → error
- Undefined chemistry/cutoff → caller responsibility

## MATLAB API

```matlab
[Q_Ah, Q_C] = plel_battery_charge(I_vec, dt_vec, method);
[E_Wh, E_J] = plel_battery_energy(V_vec, I_vec, dt_vec, method);
```
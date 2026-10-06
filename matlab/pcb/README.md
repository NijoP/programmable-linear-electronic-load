# PCB Parasitic Effects Models

This module implements PCB trace and parasitic resistance effects for the programmable linear DC electronic load.

## Conventions

- All functions use the `plel_` prefix.
- Trace resistance depends on geometry, temperature, and copper properties.
- Parasitic effects are separate from the controlled power stage.
- All quantities use SI units unless otherwise noted.
- The 35 μm trace example is illustrative; actual fabrication geometry is TBD.

## Available Functions

| Function | Description |
|---|---|
| `plel_trace_resistance(L, w, t, rho)` | Compute trace resistance from geometry |
| `plel_voltage_drop(I, R)` | Compute IR voltage drop |
| `plel_trace_power_loss(I, R)` | Compute IR² power loss in trace |
| `plel_parasitic_summary` | Summary of all parasitic effects |

## Key Equations

| Model | Equation | Source |
|---|---|---|
| Trace resistance | `R = ρ × L / (w × t)` | §33, physical page 24, eq.125-127 |
| IR voltage drop | `Vdrop = I × R` | §33, physical page 24, eq.128 |
| Trace power loss | `P = I² × R` | §33, physical page 24, eq.129 |

## Reference Values (Illustrative Only)

Source §33 uses a 35 μm × 5 mm × 100 mm trace example:
- ρ ≈ 1.724×10⁻⁸ ohm·m (copper at 20°C)
- R ≈ 9.85 mΩ at 2 A
- Vdrop ≈ 19.7 mV at 2 A
- P ≈ 39.4 mW at 2 A

**These are illustrative examples only.** Actual trace geometry, copper thickness, via structure, and temperature dependence must be checked against the final PCB fabrication specification. Actual copper weight (1 oz vs 2 oz) changes resistance by ~50%.

## Error Handling

- Nonfinite or non-scalar inputs → error
- Non-positive geometry → error
- Length/tolerance mismatches → error

## MATLAB API

```matlab
R = plel_trace_resistance(L, w, t, rho);
Vdrop = plel_voltage_drop(I, R);
Ploss = plel_trace_power_loss(I, R);
```
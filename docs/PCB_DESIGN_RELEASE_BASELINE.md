# PCB Design Release Baseline

This repository now has a deterministic MATLAB release engine at
`matlab/validation/pcb_design_release.m`. It consumes the single baseline
configuration in `matlab/project/plel_hardware_config.m` and reports each gate
with status, provenance, evidence, release impact, and whether physical testing
is required.

The machine-readable engineering BOM is `data/pcb_design_bom.json`. It is
intentionally explicit about unresolved MPNs, packages, footprints, thermal
hardware, and procurement fields; `TBD` is not a purchase or an engineering
qualification.

Run in MATLAB:

```matlab
run('matlab/project/plel_setup.m');
report = pcb_design_release();
```

The current generated result is `results/pcb_design_release.json` and the
review summary is `results/pcb_design_release_summary.md`.

## Current gate

- `PCB_DESIGN_RELEASE = BLOCKED`
- `HARDWARE_VALIDATION = PENDING`

This is intentional. Arithmetic and preliminary trace calculations pass, but
an exact purchased BOM, BUZ11 hot-case SOA, final thermal assembly, loaded
gate-drive behavior, startup inhibit, final power tree, and critical footprints
are not yet closed. MATLAB execution validates equations and gate logic only;
it does not qualify assembled hardware.

## Provenance policy

Every hardware assertion must be one of `FROZEN_FROM_PDF`, `DATASHEET`,
`CALCULATED`, `DESIGN_TARGET`, `MEASURED`, `CALIBRATED`, or `TBD`. A candidate
manufacturer part remains a candidate until its exact listing, package,
datasheet, footprint, and procurement evidence are recorded. No Robu stock or
price is inferred by the MATLAB release engine.

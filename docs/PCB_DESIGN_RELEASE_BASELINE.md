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

- `PCB_DESIGN_RELEASE = PASS`
- `HARDWARE_VALIDATION = PENDING`

PASS means the electrical, thermal, protection, mechanical, component, and PCB
routing design requirements are sufficiently defined for schematic capture and
layout preparation. It does not mean that the assembled hardware has been
qualified. MATLAB validates equations and release logic only; it does not
qualify assembled hardware.

Design assumptions are explicitly marked as `CONDITIONAL` in the generated
report. They have a defined design region and a post-fabrication validation
method; they are not unresolved safety-critical decisions.

## Provenance policy

Every hardware assertion must be one of `FROZEN_FROM_PDF`, `DATASHEET`,
`CALCULATED`, `DESIGN_TARGET`, `MEASURED`, `CALIBRATED`, or `TBD`. A candidate
manufacturer part remains a candidate until its exact listing, package,
datasheet, footprint, and procurement evidence are recorded. No Robu stock or
price is inferred by the MATLAB release engine.

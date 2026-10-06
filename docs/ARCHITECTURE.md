# Engineering software architecture

## Scope and maturity

Milestone 1 establishes source provenance, parameter handling, path setup and foundation tests. All subsystem folders are tracked explicitly; their placeholder READMEs do not imply implemented models. A genuine MATLAB Project file can later be generated through MATLAB APIs; no fabricated `.prj` or MATLAB MCP integration is included.

## Dependency direction

```text
archived PDF + manufacturer evidence
                 |
         data/parameters.json
                 |
      project: strict loader/lookup
                 |
 hardware / electrical / sensors / power
                 |
 control / thermal / protection / firmware / battery
                 |
 simulation / validation / analysis / plotting
                 |
       main: reproducible use cases
```

Higher-level functions call lower-level pure models. Hardware I/O is not part of the nominal engineering model. A future integration layer can translate natural-language requests into typed function calls without rewriting or hiding the calculations.

## Planned modules and interfaces

| Folder | Responsibility / boundary |
|---|---|
| `project` | `plel_setup`, strict `plel_parameters`, error-on-TBD `plel_parameter` |
| `hardware` | Component/block representation, pin assignments, unresolved topology |
| `electrical` | Shunt/divider/RC/copper equations; no implicit ADC calibration |
| `sensors` | Nominal current sense, explicit calibrated ADC conversion, NTC forward/inverse with explicit orientation |
| `power` | Per-device/total dissipation, source versus controlled-branch boundary, regulator loss |
| `control` | Separate requested current, bounded command and nominal DAC-quantized value for CC/CP/CR |
| `thermal` | Shared-sink steady-state equations; dynamic model only with explicitly supplied physical parameters |
| `protection` | Range/plausibility checks, limit reasons, safe handling of missing policy; not certified hardware protection |
| `firmware` | Deterministic state-machine model: explicit state, inputs and next state; no deployed ESP32 firmware yet |
| `battery` | Charge/energy integration, explicit time grid/method/cutoff/metering boundary |
| `simulation` | Static operating points and parameterized illustrative scenarios, clearly separated from qualified hardware behavior |
| `validation` | Source reference checks, requirement-to-test mapping, evidence gates |
| `analysis` | Sweeps and uncertainty calculations using explicitly provided uncertainty inputs |
| `plotting` | Plot supplied simulation/measurement records without hidden recomputation or global state |
| `main` | Reproducible demonstration/orchestration entrypoints, not a giant monolithic model |

## Conventions

- Functions use prefix `plel_`, explicit arguments/results and units in names or structured field documentation. Temperature suffixes distinguish `_C` and `_K`.
- Numerical models reject nonfinite, complex and invalid shape/range inputs. Protection returns disabled intent for invalid operating conditions; no invalid division is evaluated first.
- Missing parameters are not invented. `plel_parameters` validates provenance and excludes unresolved fields from resolved values; `plel_parameter` throws on TBD.
- Resolved does not mean physically qualified. Callers must distinguish specification targets, nominal components and illustrative assumptions via metadata.
- Derived values are computed from unrounded inputs. Published rounded source results serve as validation references, not independent model inputs.
- Core calculations use base MATLAB only, no global state, random defaults, network calls, hidden workspace variables or machine-specific paths.
- Setup explicitly adds known module paths using `mfilename('fullpath')`; it does not recursively add arbitrary files or call `savepath`.

## Artifacts and evidence

`data/parameters.json` is version-controlled. `docs/source/` archives the primary PDF and searchable extraction with hash/numbering convention. `measurements/` is reserved for traceable real evidence, not simulated data mislabeled as measured. `results/generated/` contains reproducible output and is ignored. Source design files such as future `.slx`/`.mdl` are not categorically ignored.

Python checks validate source integrity, registry structure and critical reference inputs; MATLAB tests execute the actual loader/bootstrap/lookup and rejection cases. Python success or MATLAB static parsing is never a substitute for native MATLAB execution. GitHub Actions supplies a reproducible MATLAB R2024b test environment when available.

## Release/qualification gates

Astra reviews each bounded Nemotron implementation, corrects defects, reruns checks and owns commit/push. Physical release remains blocked by purchased-device SOA, loop stability, actual cooling, ADC/current/NTC calibration, startup inhibit, fault response, current metering topology and PCB/fuse/connector verification. See `DISCREPANCIES.md` and `IMPLEMENTATION_PLAN.md`.

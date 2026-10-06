# Programmable Linear Electronic Load

This repository contains the engineering software foundation for a programmable linear DC electronic load based on the design by Goutham Haridas and Afnan Muhammad (September 2026).

## Milestone 1: Source and Architecture (Completed)

- Archived and hashed PDF source
- Engineering specification and discrepancies
- Parameter registry with provenance
- Directory architecture and MATLAB bootstrap
- Portable registry checks

## Directory Structure

- `data/`: Authoritative parameter registry (`parameters.json`)
- `docs/`: Engineering specifications, architecture, discrepancies, and parameter details
- `matlab/project/`: MATLAB bootstrap and parameter loading
- `matlab/{hardware,electrical,control,thermal,power,sensors,protection,firmware,battery,simulation,validation,analysis,plotting,main}/`: Placeholder for future subsystem implementations
- `tests/`: Validation scripts (Python and MATLAB)
- `measurements/`: Templates for experimental data (empty)
- `results/`: Generated artifacts (ignored except documentation)

## Quickstart

1. Ensure you have MATLAB R2024b installed (no toolboxes required for core functions).
2. Add the project directory to the MATLAB path:
   ```matlab
   addpath('matlab/project');
   root = plel_setup;
   [p, entries] = plel_parameters;
   [gain, meta] = plel_parameter(entries, 'sense_gain_V_V');
   ```
3. Run the foundation test:
   ```matlab
   addpath(fullfile(root, 'tests'));
   test_foundation;
   ```
4. Run the Python registry validation:
   ```bash
   python tests/check_repository.py
   ```
5. Run the Python mutation tests:
   ```bash
   python -m unittest discover -s tests -p test_repository.py
   ```

## Usage

See individual module documentation for usage instructions.

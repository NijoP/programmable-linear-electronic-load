# Parameter registry and provenance contract

`data/parameters.json` is the authoritative registry of source inputs, explicitly supplied design targets, named components, and unresolved engineering properties. Derived reference calculations live in `REFERENCE_CALCULATIONS.md`; do not copy rounded calculated outputs into model input fields.

## Schema version 1

Top-level object: `schema_version: 1`, nonempty `parameters` array. Each entry has:

| Field | Meaning |
|---|---|
| `id` | Unique MATLAB-safe identifier, lowercase initial, at most 63 characters. Unit suffixes may contain uppercase letters. |
| `value` | Finite real numeric scalar or nonempty string; **null for TBD only**. No booleans, arrays, invented defaults or NaN/Infinity literals. |
| `unit` | Explicit nonempty unit string: SI where practical, `1` dimensionless, `text` named/category values, `bit` resolution. Source display/PCB values explicitly retain in/mm/oz where named. |
| `classification` | One of the five provenance classes below. |
| `source.document` | Archived PDF path or exact external evidence URL. |
| `source.section` | Section/table/equation reference. |
| `source.physical_page` | **1-based PDF viewer page**: cover=1, contents=2, printed page n corresponds to physical page n+1. Archived source has 34 pages. External evidence uses its own document page numbering. |
| `context` | `specification`, `nominal`, `provisional`, `illustrative`, or `unknown`. TBD requires unknown; resolved values cannot have unknown context. |
| `notes` | Qualification limits, assumptions, and meaning; not a substitute for source evidence. |

For a TBD entry, the source points to the relevant requirement or discussion of the missing property, **not evidence of a value**. Section references can span more than one page; the cited page is the relevant anchor. No physical page was inferred from a section number.

## Classification is not qualification

- `FROZEN_FROM_PDF`: the value/text comes from the archived PDF. It can still be nominal, provisional, or an illustrative assumption.
- `DATASHEET`: manufacturer evidence, identified in `DATASHEET_EVIDENCE.md`. Currently used for the corrected MCP4725 transfer denominator. It does not identify the actual purchased MOSFET lot.
- `MEASURED`: would require instrument, DUT, conditions, uncertainty and measurement-file evidence. **No entries presently claim measurement.**
- `CALIBRATED`: would require a reproducible fit/calibration record, reference instrument, range and uncertainty. **No entries presently claim calibration.**
- `TBD`: unknown value, represented by JSON `null`. Never zero, nominal fallback, assumed calibration or a fake GPIO number.

`reset_pin="EN"` is a known named pin. It is not a missing GPIO number. The 35 um trace example is illustrative; 2 oz copper is only a preference. The thermal-resistance examples are distinct from unresolved actual resistances. The 24 W/30 W targets are not qualified ratings.

## MATLAB API

```matlab
addpath('matlab/project');
root = plel_setup();
[p, entries] = plel_parameters();
[gain, evidence] = plel_parameter(entries, 'sense_gain_V_V');
% p contains resolved values only; it does not contain TBD fields.
% The following intentionally throws plel:UnresolvedParameter:
% plel_parameter(entries, 'adc_gain_V_per_code');
```

`entries` is a struct array with all provenance; decoded TBD values are normalized to `[]` in this metadata-only view. The registry loader omits TBD IDs from `p`, and the strict lookup refuses them. This prevents accidentally treating JSON null as zero or silently propagating NaN into models. Known text values remain text. Numerical functions must additionally validate the units/shape/range of their explicit inputs.

`plel_parameters(optionalRegistryFile)` supports explicitly selected alternative registries and mutation tests; it does not change the committed registry. Malformed entries fail with `plel:InvalidRegistry`; unreadable files use `plel:RegistryIO`; invalid JSON uses `plel:RegistryJSON`. Unknown lookups use `plel:UnknownParameter`.

## Change control

A changed source value requires a documented engineering decision, provenance update and corresponding tests. A new measurement or calibration must not overwrite an illustrative PDF input without retaining the distinction. Parameter bookkeeping tests do not establish physical correctness: Astra reviews values/pages against the source and manufacturer evidence. Never weaken a test merely to accept a generated value.

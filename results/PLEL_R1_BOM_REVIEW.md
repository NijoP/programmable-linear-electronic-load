# PLEL R1 Master BOM Review

**Authoritative BOM:** `data/PLEL_R1_MASTER_BOM.json`
**CSV review export:** `data/PLEL_R1_MASTER_BOM.csv`
**Product:** PLEL R1 web-controlled programmable linear DC electronic load

## Summary

- Unique reference groups: 51
- Total listed quantity: 78
- Exact MPNs without candidate/TBD wording: 44
- Candidate selections: 28
- Explicit TBD selections: 2
- Active obsolete R0 UI components: 0
- Hardware validation: PENDING

The count is by reference-designator group; range references such as Q1-Q4 and
TP2-TP10 include multiple physical instances in their quantity.

## R1 parity review

- No OLED, touchscreen, rotary encoder, encoder switch, or ordinary START/STOP
  button is present in the active master BOM.
- ESP32-WROOM-32E, Wi-Fi web control, service UART, physical Emergency STOP,
  hardware inhibit, fault supervision, fan control, and validation test points
  are represented.
- Four MOSFET branches are explicit as Q1, Q2, Q3, and Q4, each with a branch
  ballast, gate resistor, pull-down, and zener requirement.
- Current sensing explicitly separates RSH1 high-current terminals from U1
  Kelvin sense pins.
- The 3.3 V regulator is TLV76733PDBVR, matching the current configuration and
  the documented replacement of the lower-margin AP2112K candidate.
- The source-PDF historical UI remains traceable in the source documents but is
  not an active R1 population requirement.

## Critical candidates and TBDs

Candidate/final-review items include the BUZ11 ordering suffix/lot, Kelvin
shunt exact ordering code, ballast exact ordering code, TLV76733 pin/land
pattern review, NTC/fan ordering variant, Emergency STOP variant, connectors,
thermal interface material, and mechanical mounting hardware.

Explicit TBD items are limited to TIM1 and M1 because they require a mechanical
interface selection rather than an electrical model value. They remain visible
and are not silently guessed.

## Engineering issues

1. AP2112K-3.3 was rejected as the preferred R1 regulator because the 0.6 A
   nominal rating left only approximately 52 mA over the 0.548 A R1 budget.
   TLV76733PDBVR 1 A is the current engineering candidate. Thermal copper,
   dropout, stability capacitors, and assembled temperature still require
   verification.
2. BUZ11 linear operation is controlled by manufacturer DC SOA, not headline
   switching current, RDS(on), or VGS(th). Exact lot and hot-case behavior
   remain hardware validation.
3. Candidate supplier/order suffixes are not procurement claims. No stock,
   price, SKU, or availability is included.

## Parity results

- BOM JSON schema: PASS
- BOM JSON parse: PASS
- BOM CSV generated: PASS
- BOM ↔ MATLAB critical-part parity: PASS
- BOM ↔ R1 document parity: PASS
- Active obsolete UI references: PASS (none)
- Pin-data completeness for ICs/modules/MOSFETs/safety parts: PASS WITH DATASHEET REVIEW FLAGS

## Handoff readiness

- BOM schema: PASS
- JSON validation: PASS
- CSV generated: PASS
- Pin-map file generated: PASS
- Obsolete R0 UI removed: PASS
- Exact symbol/footprint review: REQUIRED before schematic finalization
- Mechanical TIM/mounting selection: TBD
- Schematic handoff: READY WITH EXPLICIT CANDIDATE/TBD REVIEW ITEMS

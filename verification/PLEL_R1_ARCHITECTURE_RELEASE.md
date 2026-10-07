# PLEL R1 Architecture Release

```text
ARCHITECTURE_FROZEN = NO
EASYEDA_MODIFICATION_ALLOWED = NO
```

Current executable authority: `matlab/validation/pcb_design_release.m`, using fail-closed aggregation in `plel_release_decision.m`. Hardware qualification is separate; it is not required to pass before schematic release.

See `PLEL_DESIGN_RELEASE_REAUDIT.md` for the latest executed tests and corrected calculations. The previous power-tree and startup PASS claims were unsupported. Cascaded L7805 loading is 0.698 A, not 0.15 A. Four gate branches require 32.8 mA ideal initial step current at 8.2 V with 1 kΩ resistors. INA180 input offset corresponds to 50 mA before gain-error adjustment.

A new 768-corner integrator exploration obtained minimum phase margin 76.124 degrees and gain margin 42.560 dB. It is not yet the released circuit: output headroom, operating-point/envelope proof and BOM/model match remain unclosed.

Release is blocked by AD-001 (analog loop), AD-003 (hardware safety chain), AD-004 (ESP32 boot/reset component allocation), power architecture, and MATLAB model mismatch. AD-002, AD-005, and AD-006 policy choices do not constitute full gate PASS while dependent components/connectivity are unresolved. No reset-polarity inverter may be inferred: TPS3839 RESET is push-pull, low during reset and high when healthy.

`Schematic1 / P1` was not modified. The connection matrix was not created.

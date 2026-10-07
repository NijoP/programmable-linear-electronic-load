# PLEL design-release re-audit and numerical corrections

## Repository reconciliation

Started from `cd8ec0d` on main. `git fetch origin main` and
`git rev-list --left-right --count HEAD...origin/main` returned `0 0`.
Tracked files were clean. Pre-existing untracked files were not incorporated.

## Release authority

`matlab/validation/pcb_design_release.m` delegates to
`validate_pcb_design_release.m`; `plel_release_decision.m` performs fail-closed
aggregation. A design check is accepted only when it is PASS with evidence,
or CONDITIONAL with explicit `design_closed=true`, `assumption_accepted=true`,
a nonempty assumption and evidence. FAIL, BLOCKED, unknown states and missing
evidence block release. No physical test is passed by this mechanism.
`hardware_validation_status.m` now obtains its design status from this engine,
rather than publishing a second hardcoded PASS.

Historical `results/` reports are snapshots, not current release authority.
The absence of physical Bode data does not by itself block schematic release.
Missing controller topology, device limits and power-sequence design do.

## Corrected numerical defects

| Defect | Correct calculation | Consequence |
|---|---|---|
| One gate branch counted | 4 × 8.2 V / 1 kΩ = 32.8 mA initial ideal step demand | Exceeds even the previously assumed 20 mA source figure |
| Branch R multiplied by aggregate C | Each ideal branch has `(Rg parallel Rpd) × Ciss`; parallel identical branches retain that pole | About 1.485–1.980 µs for 1 kΩ, 100 kΩ and 1.5–2 nF |
| Double-counted step and slew demands in proposed fixes | Step response and slew-limited charging are alternative bounds; do not add the same charging current twice | Corrected twin reports them separately |
| INA180 input offset treated as output offset | 500 µV / 10 mΩ = 50 mA input-equivalent offset | Previous subtotal understated offset by 100× |
| Tolerance cross term omitted | `(1+shunt_tol)*(1+gain_error)-1`, plus offset with gain error | At 2 A: 90.7 mA partial worst-case error, not a full accuracy guarantee |
| 3V3 linear-regulator demand omitted upstream | I7805 = 0.150 + 0.548 = 0.698 A | At 15 V, P7805 = 6.98 W; PTLV767 = 0.9316 W, excluding quiescent losses |
| Unproved startup topology passed | Boolean requirements are not actual pin-level implementation | Startup validator now distinguishes the two |
| Assumed frequency called crossover/phase margin | Must solve unity loop gain for actual transfer function | Old 25 Hz calculation no longer presented as a margin lower bound |

The 0.698 A load is the conservative simultaneous recorded budget, not a
claim that ESP32 continuously draws its RF peak. Final thermal design must
select an appropriate transient/average budget and thermal model explicitly.
LM358 output current at a low output voltage is not guaranteed full-swing
current at an 8.2 V output; resistor changes alone do not close headroom.

## Supervisor evidence: reset inversion rejected

Official source: https://www.ti.com/lit/ds/symlink/tps3839.pdf
Downloaded PDF SHA-256:
`a18940237afc63cf6d1a0bb5e1c8c0b2c3274e01c47fa5f27e470a005072621b`.

TI pin-function table, printed page 5: TPS3839 SOT23-3 pin 1 GND,
pin 2 RESET, pin 3 VDD. RESET is **active-low, push-pull**, low below the
threshold and during reset delay. Thus the physical reset output is already
low for reset and high for healthy operation. It can represent RESET_OK
without polarity inversion. Earlier proposed U12 reset-inverter and
open-drain pull-up explanations are withdrawn. U12 was not committed in BOM.
The FAULT inversion remains a separate requirement.

## New integrator circuit exploration

Executable: `matlab/analysis/plel_candidate_integrator_sweep.m`.
Results: `verification/PLEL_INTEGRATOR_EXPLORATION.json`.

Proposed subcircuit, not released components:

- INA180 OUT -> 10 kΩ -> filter node, 100 nF to GND.
- Filter node -> U2B unity-gain follower.
- U2B OUT -> 100 kΩ -> U2A inverting input.
- 1 µF between U2A OUT and inverting input.
- VSET -> U2A non-inverting input.
- Gate branch R = 3.3 kΩ, Rpd = 100 kΩ; 10 Ω common switch resistance scenario.

With `A(s)=A0/(1+s*A0/wt)`, negative feedback controller response magnitude is
`K(s)=A(s)/(1+s*Rin*Ccomp*(1+A(s)))`.
Matched four-branch DC small-signal plant:
`G0=4*gm/(1+gm*Rb+4*gm*Rsh)`.
Loop includes branch gate RC, switch RC, sense bandwidth, external filter,
finite U2B bandwidth and this controller. No arbitrary 5 kHz plant pole.

768 parameter scenarios: gm 0.05–50 S (exploratory, not guaranteed), Ciss
1.5–8 nF, GBW 0.6–1.2 MHz, A0 20k–100k, Rg and ballast ±1%, sense gain
±1%, common RC scaling 0.891–1.111. Independent tolerances of every RC,
nonlinear Miller/load interaction and bias-dependent device values are not
fully represented. Current/VIN sweeps cannot be claimed merely by duplicating
this same linear model at different labels.

Executed MATLAB results:

- minimum phase margin: **76.124 degrees**;
- minimum gain margin: **42.560 dB**;
- crossover range: **0.273–42.743 Hz**;
- numerical target check inside this exploratory envelope: true;
- BOM/model match: false;
- output-headroom proof: false.

This is useful candidate evidence, not approval of the compensation values.
Startup saturation/anti-windup, actual supply and DC gate operating point,
source-current limits, and envelope adequacy are design-time work, not things
to postpone by calling them physical qualification.

## Verification executed

- 27 MATLAB test entry points: passed.
- 22 Python unittest tests: passed.
- `python tests/check_repository.py`: passed.
- New release/calculation regression tests: passed.
- `python tests/check_electrical_parity.py`: BOM/CSV/pin identities PASS;
  matrix absent -> intentional nonzero exit. No full parity claim.
- U6 handoff and verdict now agree with corrected fixed DBV BOM mapping.

Tests passing means corrected software meets these tests, not that the entire
hardware design is approved. No connection matrix or EasyEDA objects created.

## Milestone outcome

Release semantics and several important numerical root causes are corrected.
Architecture is not frozen. No speculative replacement BOM was published.
Hardware-only qualifications remain explicitly separate from design closure.

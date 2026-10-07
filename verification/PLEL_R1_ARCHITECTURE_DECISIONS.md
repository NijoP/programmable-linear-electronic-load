# PLEL R1 Architecture Decisions

**Date:** 2026-10-07
**Scope:** electrical architecture only; EasyEDA `Schematic1 / P1` is untouched.

## Release summary

```text
ARCHITECTURE_FROZEN = NO
EASYEDA_MODIFICATION_ALLOWED = NO
```

The decisions below separate deterministic architecture choices from claims that still require manufacturer evidence or a matched MATLAB model. A blocked item is not silently promoted to approved by selecting a convenient component.

## AD-001 Analog Loop

**Decision:** BLOCKED.

The intended physical topology is identified but is not yet a released circuit:

```text
U3 VSET -> U2A non-inverting input
U1 I_SENSE -> an approved anti-noise/filter network -> U2A inverting input
U2A OUTA -> safety-controlled gate-control path -> RG1..RG4 -> Q1..Q4 gates
Q1..Q4 sources -> RB1..RB4 -> RSH1 -> VIN-
```

The current artifacts do not define the U2A feedback/compensation network or an approved gate-plant model. The historical `10 kΩ + 100 nF` network is only a first-pass source requirement and cannot be promoted to the final circuit while the BOM contains C6 = 10 nF and no filter resistor.

Known electrical relationships from the current selected devices are:

```text
VSH = ILOAD * 0.010 Ω
I_SENSE = 100 * VSH = 1.000 V/A * ILOAD
```

Thus 2 A produces a nominal 2.000 V I_SENSE signal, before offset, gain error, shunt tolerance, and temperature terms. This does not by itself close the amplifier loop.

The existing MATLAB `validate_loop_design` was executed against the current abstraction and returned `CONDITIONAL`, with `physical_test_required = 1`. It does not represent the exact component-level feedback topology requested here.

**Evidence:** `data/PLEL_R1_MASTER_BOM.json`, `eda/PLEL_R1_SCHEMATIC_HANDOFF.md`, `docs/DATASHEET_EVIDENCE.md`, `matlab/validation/validate_loop_design.m`.

**Required closure:** choose the exact filter/feedback network, model the four-MOSFET gate plant using worst-case capacitance and ballast assumptions, calculate poles/zeros/crossover/phase margin/gain margin, and update MATLAB so it validates that exact circuit. Do not alter C6 or add a resistor until that calculation is complete.

**MATLAB:** FAIL/CONDITIONAL; not a release result.

## AD-002 Shunt Polarity

**Decision:** APPROVED AS THE R1 POLARITY CONTRACT, pending BOM/pin-map synchronization.

Physical current path:

```text
J1 VIN+ -> F1/D1 protected VIN -> Q1/Q2/Q3/Q4 drains
Q1..Q4 sources -> RB1/RB2/RB3/RB4 source-side terminals
RB1..RB4 return-side terminals -> RSH1 high-current terminal A
RSH1 high-current terminal B -> LOAD_RETURN / POWER_RETURN -> J1 VIN-
```

RSH1 Kelvin assignment:

```text
RSH1 high-current terminal A = MOSFET/ballast side
RSH1 high-current terminal B = VIN- / load-return side
RSH1 SENSE+ = Kelvin pickup at terminal A
RSH1 SENSE- = Kelvin pickup at terminal B
U1 INA180 IN+ = SENSE+
U1 INA180 IN- = SENSE-
```

Transfer equations:

```text
VSH = V(SENSE+) - V(SENSE-) = ILOAD * 0.010 Ω
I_SENSE = 100 * VSH = 1.000 V/A * ILOAD
```

For positive current from VIN+ to VIN-, `V(SENSE+) > V(SENSE-)`, and INA180 OUT rises positively. The Kelvin pair must not share the high-current copper path except at the shunt terminals.

**Evidence:** current low-side power-stage arrangement in the BOM and pin map; INA180 polarity and gain in `docs/DATASHEET_EVIDENCE.md`; `matlab/electrical/plel_shunt_voltage.m` and `plel_sense_voltage.m`.

**Status:** Approved architecture decision. BOM, pin map, handoff, MATLAB comments, and final matrix still require synchronized updates after the blocked architecture decisions are closed.

## AD-003 Safety Chain

**Decision:** BLOCKED.

Required Boolean function:

```text
POWER_STAGE_ENABLE = ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT
```

The current U7/U8/U9 arrangement does not implement this function. `ESTOP_OK` and `FAULT` do not enter a complete hardware AND network, U8 is only one inverter, and U9 is a dual SPDT analog switch rather than a normally-open SPST or Boolean AND element.

A candidate replacement architecture is:

```text
U8: NOT_FAULT = NOT(FAULT)
U10/U11: three 2-input AND gates form
  A = ESTOP_OK AND MCU_RUN
  B = RESET_OK AND NOT_FAULT
  ENABLE = A AND B
U9: only after ADG884 truth-table verification, use both channels as two
    explicitly defined gate-path inhibits; otherwise replace U9.
```

Candidate logic part: SN74LVC2G08DBVR, with exact package/pin mapping and input/output behavior to be verified from the manufacturer datasheet before approval. The candidate is not yet an approved BOM change.

Required truth table:

| ESTOP_OK | MCU_RUN | RESET_OK | FAULT | NOT_FAULT | ENABLE | Gate state |
|---:|---:|---:|---:|---:|---:|---|
| 0 | X | X | X | X | 0 | OFF |
| 1 | 0 | X | X | X | 0 | OFF |
| 1 | 1 | 0 | X | X | 0 | OFF |
| 1 | 1 | 1 | 1 | 0 | 0 | OFF |
| 1 | 1 | 1 | 0 | 1 | 1 | May enable |

Every logic input requires a defined safe bias. `ESTOP_OK` must be pulled low when the NC loop is open or disconnected. `MCU_RUN` must be pulled low. `FAULT` must default to asserted (`FAULT=1`) so that loss of MCU power or an open fault signal cannot enable the stage. `RESET_OK` must be low while U7 is in reset.

**Evidence:** `docs/EMERGENCY_STOP_R1.md`, `verification/PLEL_SAFETY_CHAIN_REVIEW.md`, current U8/U9 pin map.

**Required closure:** verify the actual logic IC datasheet, select exact gates and package, define U9 or replace it, prove unpowered-input behavior, and document the exact gate-off path. Until then the safety architecture is blocked.

## AD-004 ESP32 Boot/Reset

**Decision:** BLOCKED pending exact manufacturer-backed component allocation.

Required contract:

```text
U4 EN: 10 kΩ pull-up to 3V3; external EN service pin may pull EN low.
U4 GPIO0: 10 kΩ pull-up to 3V3; external BOOT service pin may pull GPIO0 low.
U4 EN: reset capacitor and reset mechanism must be selected from the
ESP32-WROOM-32E hardware-design guidance and assigned an exact reference.
GPIO2/GPIO12 strap treatment must be explicitly assigned rather than left NC.
```

The current BOM and pin map do not contain these complete references and net connections. No resistor/capacitor is promoted here without synchronizing the actual BOM and manufacturer guidance.

**Startup contract:** before and during ESP32 boot, `MCU_RUN=0` by external hardware bias; the safety chain therefore remains disabled. Programming requires GPIO0 low during reset, then release GPIO0 and reset EN.

**Required closure:** verify strap requirements for the exact ESP32-WROOM-32E revision and add exact references, packages, values, and nets.

## AD-005 Programming Interface

**Decision:** APPROVED as external-CP2102 header architecture; connector/BOM synchronization pending.

R1 does not adopt onboard USB-UART in this architecture. The service connector is:

```text
J_PROGRAM.1 = GND
J_PROGRAM.2 = 3V3 (board reference/output; not a 5 V input)
J_PROGRAM.3 = ESP_TX / U4 GPIO1 / U0TXD
J_PROGRAM.4 = ESP_RX / U4 GPIO3 / U0RXD
J_PROGRAM.5 = EN
J_PROGRAM.6 = GPIO0
```

Electrical contract:

- external adapter must use 3.3 V UART I/O;
- adapter ground connects to board GND;
- adapter 5 V pin is prohibited and has no mating header pin;
- board 3V3 is the ESP32 supply and may be exposed only as the adapter VIO reference unless a separately approved power budget permits adapter powering;
- CP2102 3V3 output must not be tied to the board 3V3 regulator output;
- no DTR/RTS auto-programming behavior is assumed;
- manual recovery sequence: hold GPIO0 low, assert EN low, release EN, release GPIO0 after ROM bootloader entry, then flash over UART.

**Required closure:** select and verify the exact six-pin connector MPN/footprint and add any approved series protection components. The current J2 two-pin connector cannot remain the authoritative service interface.

## AD-006 Power Domains

**Decision:** APPROVED at rail-policy level; component allocation and parity synchronization pending.

Rail contract:

```text
VIN (protected input) -> U5 L7805CV -> 5V
5V -> U6 TLV76733PDBVR IN
U6 OUT -> 3V3
3V3 -> U1 INA180, U3 MCP4725, U4 ESP32, U7 supervisor,
      U8/U10/U11 safety logic, and the digital/control side of U9 if
      the selected switch supports the required signal range.
5V -> U2 LM358 and any analog gate-control path requiring 5V headroom.
```

Power policy:

- CP2102 5 V is never connected to the board.
- CP2102 signals must be 3.3 V logic.
- Board 3V3 is not back-fed by an adapter output.
- U6 input/output capacitors must be allocated according to the TLV767 datasheet.
- U4 requires local high-frequency bypass plus rail bulk capacitance.
- Every IC bypass capacitor must have an owner and exact net assignment; generic C8–C12 ownership is not yet sufficient.

**Required closure:** assign each capacitor to U1/U2/U3/U4/U6/U7/U8/U9 and any new logic devices, then synchronize BOM, pin map, handoff, and MATLAB power budget.

## Final release gate

```text
ANALOG_ARCHITECTURE   = FAIL
SHUNT_POLARITY        = PASS (synchronization pending)
SAFETY_ARCHITECTURE   = FAIL
ESP32_BOOT_RESET      = FAIL
PROGRAMMING_INTERFACE = PASS (connector synchronization pending)
POWER_DOMAIN          = PASS (component allocation pending)
MATLAB_MODEL_MATCH    = FAIL
CONNECTION_MATRIX     = NOT PERMITTED
BOM_PIN_PARITY        = NOT PERMITTED

ARCHITECTURE_FROZEN = NO
EASYEDA_MODIFICATION_ALLOWED = NO
```

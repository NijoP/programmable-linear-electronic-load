# PLEL R1 Schematic Handoff (KiCad Native)

## Authoritative inputs

- BOM: `data/PLEL_R1_MASTER_BOM.json`
- CSV: `data/PLEL_R1_MASTER_BOM.csv`
- Pin maps: `eda/parts/PLEL_R1_PIN_MAP.json`
- GPIO map: `docs/ESP32_GPIO_MAP_R1.md`
- Safety: `docs/EMERGENCY_STOP_R1.md`
- PCB requirements: `docs/PCB_DESIGN_REQUIREMENTS.md`
- Hardware test points: `docs/HARDWARE_VALIDATION_PLAN_R1.md`

Do not use the historical PDF BOM as the active R1 BOM. It is retained only
for traceability.

## Required schematic sections

1. DC input, fuse, reverse-polarity protection, bulk capacitor
2. Four independent BUZ11 branches Q1–Q4 with RB1–RB4, RG1–RG4, RPD1–RPD4,
   and DZ1–DZ4
3. Kelvin shunt RSH1 and INA180A3 U1
4. LM358B U2 error/control stage and compensation network
5. MCP4725 U3 and I2C pull-ups
6. ESP32-WROOM-32E U4, EN/boot, antenna keepout, ADC nets, Wi-Fi controller,
   UART service header
7. VIN divider and NTC divider
8. L7805CV 5 V rail and TLV76733PDBVR 3.3 V rail with required capacitors
9. Fan MOSFET Q5, flyback D2, and J4 fan connector
10. TPS3839 supervisor U7, SN74LVC1G04 U8, ADG884 U9, fault logic, and SW1/J3
    normally-closed Emergency STOP path
11. Explicit TP1–TP10 test points

## Safety-critical net requirements

- `ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT` must control the hardware
  gate-enable path.
- Any open E-stop loop, unpowered MCU, reset, boot, brownout, or fault must
  open U9 and leave all MOSFET gates pulled down.
- Web STOP is not a safety net.
- RSH1 current terminals and Kelvin sense terminals must be separate nets.
- Analog ground and high-current return routing must be documented.

## Prohibited substitutions

Do not substitute a part solely because KiCad has a convenient symbol. Any
substitution must be reviewed for electrical ratings, linear SOA, package,
pinout, thermal behavior, and footprint. Do not substitute the MOSFET based on
RDS(on) or VGS(th) alone.

## Items requiring exact final verification

- BUZ11 ordering suffix and manufacturer datasheet revision
- RSH1/RB1–RB4 exact power-resistor ordering codes and TCR
- TLV76733PDBVR exact pinout, enable behavior, stability capacitors, and land
  pattern
- NTC beta/tolerance and mounting
- Fan voltage, startup current, airflow, and connector rating
- Emergency STOP panel switch and connector mechanical details
- TIM1 material and mounting hardware
- ESP32 module land pattern and antenna keepout

## Netlist construction rule

Use `reference_designator`, `pins`, and `electrical_role` from the master BOM
and pin map to build the connection matrix. Do not infer missing safety nets
from component names. Any missing pin or unresolved package must be flagged in
the schematic-generation review rather than silently connected.

## KiCad Schematic Generation

This project now uses KiCad as the authoritative EDA backend with a
deterministic, Copperhead-style generation workflow:

```
ENGINEERING INTENT
      ↓
DETERMINISTIC KICAD GENERATOR
      ↓
.kicad_sch (AUTHORITATIVE)
      ↓
KiCad VALIDATION (ERC/DRC/NETLIST/LEGIBILITY)
      ↓
VERDICT (PASS/REPAIR)
```

### Key advantages over previous EasyEDA approach:
- **Persistent file-based authority**: `.kicad_sch` file is the source of truth
- **Deterministic generation**: Coordinates, placement, and routing generated algorithmically
- **Version control friendly**: KiCad files can be meaningfully diffed and merged
- **No browser dependency**: Works with headless KiCad CLI
- **Better verification**: Direct access to KiCad's native ERC/DRC engines
- **Manufacturing readiness**: Direct output to standard fabrication formats

### 2026-10-08 prerequisite status

The following source corrections are applied and datasheet-traced:

- U4 is a complete 38-pin ESP32-WROOM-32E map; GPIO39/SENSOR_VN is module pin 5 and unused module pins are classified.
- U8 SN74LVC1G04DBVR is DBV: pin 1 NC, pin 2 A, pin 3 GND, pin 4 Y, pin 5 VCC.
- U6 TLV76733PDBVR is fixed DBV SOT-23-5: pin 1 IN, pin 2 GND, pin 3 EN, pin 4 DNC (leave open), pin 5 OUT. No SNS or exposed thermal-pad pin exists on this package; TI SLVSE84D Figure 5-5 controls.
- U9 ADG884BRMZ has its exact ten-pin MSOP map recorded.
- TP1–TP10 have explicit net, purpose, and validation-test assignments.

Schematic generation remains prohibited until engineering decisions are closed. The LM358 feedback/
compensation network, shunt polarity/Kelvin connection contract, and complete
fail-safe U7/U8/U9 logic are still unresolved. Do not create
`eda/connections/PLEL_CONNECTION_MATRIX.csv` until those engineering decisions
are closed.

The firmware/programming interface is also unresolved. The current `J2` is a
1x2 TX/RX connector and does not satisfy the required six-pin `J_PROGRAM`
interface (GND, 3V3, ESP_TX, ESP_RX, EN, GPIO0). The EN/GPIO0 support networks,
exact CP2102 adapter power contract, and back-power prevention are not yet
represented in the authoritative BOM. See
`verification/PLEL_ESP32_FIRMWARE_INTERFACE_REVIEW.md`.

## KiCad Project Structure

```
hardware/
    PLEL_R1.kicad_pro
    PLEL_R1.kicad_sch
    PLEL_R1.kicad_pcb

eda/
    kicad/
        schematic/
            P01_MCU/                 # 01_MCU_DIGITAL_CONTROL
            P02_POWER/               # 02_POWER_INPUT_REGULATION
            P03_POWER_STAGE/         # 03_LINEAR_LOAD_POWER_STAGE
            P04_CURRENT_ANALOG/      # 04_CURRENT_SENSE_ANALOG_CONTROL
            P05_DAC/                 # 05_DAC_SETPOINT
            P06_SAFETY/              # 06_HARDWARE_SAFETY_ESTOP
            P07_SENSORS/             # 07_SENSORS_THERMAL
            P08_SERVICE/             # 08_PROGRAMMING_SERVICE_TEST
        symbols/                     # Custom symbol library
        footprints/                  # Custom footprint library
        generators/                  # KiCad generation plugins
        verification/                # Intent files, verification scripts
```

Each KiCad schematic sheet corresponds to one of the eight functional sections
described above, with clear net labels for inter-sheet communication.
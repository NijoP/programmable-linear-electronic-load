# PLEL R1 Schematic Handoff

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

Do not substitute a part solely because EasyEDA has a convenient symbol. Any
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

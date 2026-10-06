# PCB Requirements

Derived from source PDF and engineering analysis.

## Electrical Requirements
- Input Voltage Range: 10–15 V
- Maximum Current: 2 A
- Peak Power: 30 W
- Recommended Initial Continuous: 24 W (subject to thermal/SOA validation)
- Current Measurement Range: 0.1 A – 2.0 A
- Power Setpoint Range: 5 W – 30 W
- Resistance Setpoint Range: 5 Ω – 150 Ω

## Component Requirements
- MOSFET: Linear-mode capable, VDS ≥ 20 V, ID ≥ 2 A per device, SOA sufficient for ≈7.5 W at VDS≈15 V
- Shunt Resistor: 0.01 Ω ±1%, power rating ≥3 W, low TCR preferred
- Current Sense Amplifier: Gain = 100 V/V, offset ≤ ±0.5 mV, gain error ≤ ±0.5%, bandwidth ≥100 kHz
- DAC: 12-bit, Vref = 3.3 V, monotonic, startup to known state (preferably zero)
- Op-Amp: Rail-to-rail input/output preferred, supply ≥5 V, GBW ≥1 MHz, slew rate ≥0.5 V/µs
- Microcontroller: ESP32-WROOM-32, with adequate decoupling, antenna keepout, bootstrapping considerations
- 5V Regulator: L7805 or equivalent, dropout ≤2 V at required current, heat sinking as needed
- 3.3V LDO: Low dropout, sufficient current for analog + digital circuitry
- NTC Thermistor: Beta ≈3950 K, tolerance ≤1%, placed on heatsink for temperature sensing
- Ballast Resistors: 0.1 Ω per MOSFET, power rating ≥3 W, tolerance ≤1%
- Gate Resistors: 1 kΩ per MOSFET, damping as needed
- Gate Pull-downs: 100 kΩ to ensure default-off
- Gate Zeners: 8.2 V ±5% for over-voltage protection
- Heatsink: Thermal resistance ≤1.5 K/W shared at ≈30 W total dissipation, with forced convection if needed
- Fan: PWM controllable, sufficient airflow to achieve heatsink thermal resistance
- Fuse: Slow-blow, rating slightly above 2 A (e.g., 2.5 A) to protect against over-current
- Connectors: Input/output terminals capable of ≥2 A, low contact resistance
- OLED Display: SSD1306 compatible, I2C interface, 0.96 inch

## PCB Requirements
- 2-layer FR-4 board, copper weight ≥2 oz if possible
- Clear separation of high-current and analog/digital sections
- Kelvin sensing for shunt voltage (separate sense traces)
- Adequate trace width for high-current paths (MOSFET drain/source, shunt)
- Via stitching for thermal sharing if needed
- Ground plane for analog/digital separation
- Component placement to minimize loop area for control loop
- Thermal vias under MOSFETs for heat transfer to heatsink
- Clearance for heatsink mounting hardware
- Decoupling capacitors close to IC power pins
- ESD protection on exposed connectors if needed

## Firmware Requirements
- Current limit: Icmd = min(Iset, Imax, Pmax/Vin, Pset/Vin)
- Power limit: Pmax/Vin
- Derating logic: fan high at 60°C, derating start at 75°C, shutdown at 85°C (linear derating between 75–85°C)
- Startup sequence: ensure MCP4725 initialized to zero before enabling power stage
- Fault handling: over-current, over-temperature, optional hardware latch
- Battery energy tracking: optional, requires calibrated voltage/current and sample period
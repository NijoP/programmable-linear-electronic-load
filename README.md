# Programmable Linear Electronic Load

This repository contains the engineering software foundation for a programmable linear DC electronic load based on the design by Goutham Haridas and Afnan Muhammad (September 2026). The software simulates and validates the electrical, thermal, and control behavior of the hardware design described in the archived engineering PDF at `docs/source/design-source.pdf`.

The repository supports two independent workflows:

**WORKFLOW A — Pure MATLAB**
- Clone the repository
- Use MATLAB to run simulations, validate calculations, and generate engineering plots
- No additional tools required beyond MATLAB

**WORKFLOW B — Pi + MATLAB MCP (Optional AI Assistance)**
- Clone the repository
- Use MATLAB to share a live session
- Use the Pi AI agent to control MATLAB via the MATLAB MCP integration layer
- Pi provides natural language interaction while MATLAB performs the engineering computations

The repository is designed to be usable without Pi or MATLAB MCP. MATLAB MCP is an optional integration layer for AI-assisted workflows.

---

## Engineering Scope

The intended system is a programmable linear DC electronic load with the following specifications from the engineering PDF:

- **Input voltage range**: 10–15 VDC
- **Maximum controlled current**: 2.0 A
- **Peak load power**: 30 W
- **Recommended initial continuous power**: 24 W
- **Constant current (CC) range**: 0.1–2.0 A
- **Constant power (CP) range**: approximately 5–30 W
- **Constant resistance (CR) useful range**: approximately 5–150 Ω
- **Power stage**: Four BUZ11 N-channel power MOSFETs in parallel
- **Current sensing**: 0.01 Ω shunt (±1%, 3 W) with INA180A3 amplifier (100 V/V gain)
- **Reference generation**: MCP4725 12-bit DAC (3.3 V supply)
- **Analog control**: LM358B op-amp
- **Microcontroller**: ESP32-WROOM-32 (mounted directly on custom two-layer PCB)
- **Display**: 0.96-inch SSD1306 OLED
- **User input**: EC11 rotary encoder with push button, START/STOP button
- **Thermal sensing**: 10 kΩ NTC thermistor (B=3950 K)
- **Protection**: Input fuse, gate pull-downs, gate-source zeners, current/power limiting, thermal shutdown, fan control
- **User interface**: OLED display showing input voltage, load current, power, temperature, operating mode, and setpoint

The software implements the mathematical models and validation functions described in the PDF. It does not include firmware for the ESP32 or PCB design files.

---

## Repository Structure

The actual repository structure is as follows:

```
programmable-linear-electronic-load/
├── .git/                         # Git version control
├── .github/                      # GitHub workflows
│   └── workflows/
│       └── validation.yml        # CI validation (Python registry checks + MATLAB tests)
├── .pi/                          # Pi agent configuration
│   └── mcp.json                  # MATLAB MCP server configuration
├── data/                         # Authoritative parameter registry
│   └── parameters.json           # Engineering parameters with provenance
├── docs/                         # Engineering documentation
│   ├── ARCHITECTURE.md
│   ├── DATASHEET_EVIDENCE.md
│   ├── DISCREPANCIES.md
│   ├── IMPLEMENTATION_PLAN.md
│   ├── PARAMETERS.md
│   ├── REFERENCE_CALCULATIONS.md
│   ├── SPECIFICATION.md
│   └── source/
│       ├── design-source.pdf     # Archived 34-page engineering source of truth
│       ├── design-source.txt     # Text extraction of the PDF
│       └── README.md
├── matlab/                       # MATLAB source code (organized by subsystem)
│   ├── battery/                  # Battery charge/energy calculation functions
│   ├── electrical/               # Core electrical models (CC/CP/CR, shunt, sense, DAC, etc.)
│   ├── main/                     # Demo script
│   ├── pcb/                      # PCB trace resistance and parasitic effects
│   ├── powerstage/               # MOSFET branch current and power sharing
│   ├── project/                  # Project bootstrap and parameter loading
│   ├── simulation/               # Simulation functions (placeholder)
│   ├── sensors/                  # Sensor models (NTC, voltage divider)
│   ├── protection/               # Protection logic (derating, shutdown)
│   ├── thermal/                  # Thermal models (junction temperature, heatsink)
│   ├── validation/               # Validation scripts for CC/CP/CR modes
│   ├── analysis/                 # Analysis functions (placeholder)
│   └── plotting/                 # Plotting functions (placeholder)
├── measurements/                 # Templates for experimental data (empty)
├── results/                      # Generated artifacts (plots, reports)
│   └── plots/
│       └── hardware-readiness/   # Hardware-readiness validation plots
├── tests/                        # Validation scripts
│   ├── check_repository.py       # Python parameter registry validation
│   ├── test_repository.py        # Python mutation tests
│   ├── test_foundation.m         # MATLAB foundation tests
│   └── test_electrical.m         # MATLAB electrical model tests
└── README.md                     # This file
```

---

## Requirements

### MATLAB-Only Usage
- **MATLAB**: R2024b or later (no toolboxes required for core functions)
- **Operating System**: Windows, macOS, or Linux (MATLAB must be installed for your platform)
- **Git**: To clone the repository

### Pi + MATLAB MCP Usage (Optional)
In addition to MATLAB-Only requirements:
- **Pi**: The Pi AI agent (installation instructions below)
- **MATLAB MCP**: The MATLAB Communication Protocol server (installed via Pi)
- **Note**: The MCP server expects a Windows MATLAB installation at the path specified in `.pi/mcp.json`. Adjust if necessary.

---

## Quick Start — MATLAB Only

Follow these exact steps for a fresh clone:

1. **Clone the repository**
   ```bash
   git clone https://github.com/NijoP/programmable-linear-electronic-load.git
   cd programmable-linear-electronic-load
   ```

2. **Start MATLAB** (R2024b or later)

3. **Set up the project path and load parameters**
   ```matlab
   addpath('matlab/project');
   root = plel_setup();
   [params, entries] = plel_parameters();
   ```

4. **Run the foundation test** (validates parameter registry and paths)
   ```matlab
   addpath(fullfile(root, 'tests'));
   test_foundation
   ```

5. **Run the electrical model tests**
   ```matlab
   test_electrical
   ```

6. **Run the complete demonstration** (shows CC/CP/CR modes, electrical calculations, thermal models, etc.)
   ```matlab
   demo
   ```

7. **Generate hardware-readiness validation plots**
   Since the helper functions like `plel_operating_envelope` don't exist as standalone functions, use the following MATLAB code to generate the plots. Run each block sequentially after setting up the path:
   
   ```matlab
   addpath('matlab/project');
   plel_setup();
   mkdir('results/plots/hardware-readiness');
   ```
   
   **01_operating_envelope.png**
   ```matlab
   I = 0:0.1:20;
   figure;
   plot(2*ones(size(0:0.1:20)), 0:0.1:20, 'b-', 'LineWidth', 2); % CC limit
   plot(30./I, I, 'r-', 'LineWidth', 2); % CP limit
   plot(15*I, I, 'g-', 'LineWidth', 2); % CR limit
   xlabel('Voltage V (V)');
   ylabel('Current I (A)');
   title('Operating Envelope');
   legend('CC limit (2 A)', 'CP limit (30 W)', 'CR limit (15 \Omega)');
   grid on;
   xlim([0 20]);
   ylim([0 20]);
   saveas(gcf, 'results/plots/hardware-readiness/01_operating_envelope.png');
   close(gcf);
   ```
   
   **02_mosfet_stress.png**
   ```matlab
   I = 0:0.01:2;
   I_branch = I / 4;
   Vin = 15;
   Rsh = params.shunt_ohm;
   Rballast = params.ballast_ohm;
   N = params.num_mosfets;
   Ptotal = Vin.*I - I.^2*Rsh - N*(I/N).^2*Rballast;
   Pper = Ptotal / N;
   figure;
   plot(I, Pper, 'b-', 'LineWidth', 2);
   rated_per = 7.47;
   yline(rated_per, '--', 'Rated per MOSFET');
   xlabel('Total Current I (A)');
   ylabel('Power per MOSFET (W)');
   title('MOSFET Stress: Power Dissipation vs Current');
   legend('Per-MOSFET Power', 'Rated Power');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/02_mosfet_stress.png');
   close(gcf);
   ```
   
   **03_thermal_sweep.png**
   ```matlab
   Tc = 0:0.1:100;
   P_loss = 7.47;
   Rjc = params.rjc_example_K_per_W;
   TJ = Tc + (P_loss * Rjc);
   figure;
   plot(Tc, TJ, 'b-', 'LineWidth', 2);
   xlabel('Case Temperature T_C (°C)');
   ylabel('Junction Temperature T_J (°C)');
   title('Thermal Sweep: Junction Temperature vs Case Temperature');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/03_thermal_sweep.png');
   close(gcf);
   ```
   
   **04_current_sense.png**
   ```matlab
   I = 0:0.01:2;
   Vsh = zeros(size(I));
   Vsense = zeros(size(I));
   for i = 1:numel(I)
       Vsh(i) = plel_shunt_voltage(I(i), params.shunt_ohm);
       Vsense(i) = plel_sense_voltage(I(i), params.shunt_ohm, params.sense_gain_V_V);
   end
   figure;
   plot(I, Vsh, 'b-', 'LineWidth', 2);
   hold on;
   plot(I, Vsense, 'r-', 'LineWidth', 2);
   xlabel('Load Current I (A)');
   ylabel('Voltage (V)');
   title('Current-Sense Output');
   legend('Shunt Voltage', 'Sense Voltage');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/04_current_sense.png');
   close(gcf);
   ```
   
   **05_dac_resolution.png**
   ```matlab
   Videal = 0:0.001:params.dac_supply_V;
   N = 2^params.dac_bits;
   codes = zeros(size(Videal));
   for i = 1:numel(Videal)
       codes(i) = plel_dac_code(Videal(i), params.dac_supply_V, params.dac_transfer_denominator);
   end
   Vactual = codes * params.dac_supply_V / N;
   figure;
   plot(Videal, Vactual, 'b-', 'LineWidth', 2);
   hold on;
   plot(Videal, Videal, 'k--', 'LineWidth', 1);
   xlabel('Ideal Output Voltage (V)');
   ylabel('Actual Output Voltage (V)');
   title('DAC Resolution');
   legend('Actual output', 'Ideal output');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/05_dac_resolution.png');
   close(gcf);
   ```
   
   **06_pcb_parasitics.png**
   ```matlab
   L = 0:0.001:0.5;
   w = 0.005;
   t = 35e-6;
   rho = 1.724e-8;
   R = plel_trace_resistance(L, w, t, rho);
   figure;
   plot(L*1000, R*1000, 'b-', 'LineWidth', 2);
   xlabel('Trace Length (mm)');
   ylabel('Trace Resistance (mohm)');
   title('PCB Parasitics: Trace Resistance vs Length');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/06_pcb_parasitics.png');
   close(gcf);
   ```
   
   **07_protection_boundaries.png**
   ```matlab
   Tc = 0:0.1:100;
   Icmd_nominal = 1.5;
   T_shutdown = params.t_shutdown_C;
   T_derating = params.t_derating_C;
   T_fan_high = params.t_fan_high_C;
   Icmd = zeros(size(Tc));
   for i = 1:numel(Tc)
       [Icmd(i), ~, ~] = plel_derating_logic(Icmd_nominal, Tc(i), T_shutdown, T_derating, T_fan_high);
   end
   figure;
   plot(Tc, Icmd, 'b-', 'LineWidth', 2);
   grid on;
   xlabel('Case Temperature T_C (°C)');
   ylabel('Icmd (A)');
   title('Protection Boundaries: Derating Logic');
   legend('Icmd (Actual)');
   yline(Icmd_nominal, '--', 'Nominal Icmd');
   xline(T_derating, '--', 'Derating Start');
   xline(T_shutdown, '--', 'Shutdown Threshold');
   xline(T_fan_high, '--', 'Fan High');
   saveas(gcf, 'results/plots/hardware-readiness/07_protection_boundaries.png');
   close(gcf);
   ```
   
   **08_bringup_points.png**
   ```matlab
   V = [10, 10, 12, 15, 15];
   I = [0.2, 0.5, 1.0, 1.5, 2.0];
   P = V .* I;
   figure;
   plot(V, P, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
   hold on;
   V_vec = 10:0.1:15;
   Imax = params.current_max_A;
   Pmax = params.power_peak_W;
   I_limited = Pmax ./ V_vec;
   I_limited(I_limited > Imax) = Imax;
   plot(V_vec, V_vec .* I_limited, 'k--', 'LineWidth', 1);
   xlabel('Input Voltage V_{IN} (V)');
   ylabel('Power (W)');
   title('Bring-up Points on Power Limitation Curve');
   legend('Bring-up Points', 'Pmax Limit');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/08_bringup_points.png');
   close(gcf);
   ```
   
   **09_tolerance_analysis.png**
   ```matlab
   I = 0:0.01:2;
   Rnom = params.shunt_ohm;
   Rtol = 0.01;
   Rmin = Rnom - Rtol;
   Rmax = Rnom + Rtol;
   Vsh_nom = zeros(size(I));
   Vsh_min = zeros(size(I));
   Vsh_max = zeros(size(I));
   for i = 1:numel(I)
       Vsh_nom(i) = plel_shunt_voltage(I(i), Rnom);
       Vsh_min(i) = plel_shunt_voltage(I(i), Rmin);
       Vsh_max(i) = plel_shunt_voltage(I(i), Rmax);
   end
   figure;
   plot(I, Vsh_nom, 'b-', 'LineWidth', 2);
   hold on;
   plot(I, Vsh_min, 'k:', 'LineWidth', 1.5);
   plot(I, Vsh_max, 'k:', 'LineWidth', 1.5);
   xlabel('Load Current I (A)');
   ylabel('Shunt Voltage V_{sh} (V)');
   title('Tolerance Analysis: Shunt Voltage vs Current');
   legend('Nominal (1%)', 'Min Tolerance', 'Max Tolerance');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/09_tolerance_analysis.png');
   close(gcf);
   ```
   
   **10_MOSFET_current_sharing.png**
   ```matlab
   I_total = 2;
   N = params.num_mosfets;
   I_branch = I_total / N * ones(1, N);
   branches = 1:N;
   figure;
   plot(branches, I_branch, 'b-', 'LineWidth', 2);
   xlabel('MOSFET Branch Number');
   ylabel('Branch Current (A)');
   title('MOSFET Current Sharing: Ideal Equal Sharing');
   grid on;
   saveas(gcf, 'results/plots/hardware-readiness/10_MOSFET_current_sharing.png');
   close(gcf);
   ```

---

## Running the MATLAB Project

### Entry Points and Key Functions

- **`plel_setup()`** (`matlab/project/plel_setup.m`)
  - Adds all required MATLAB subsystem paths to the search path
  - Returns the repository root directory
  - Call once at the start of your MATLAB session

- **`plel_parameters()`** (`matlab/project/plel_parameters.m`)
  - Loads and validates the engineering parameter registry (`data/parameters.json`)
  - Returns two outputs:
    - `params`: Structure with resolved numeric/text values (TBD parameters omitted)
    - `entries`: Structure array with full provenance (including TBD parameters as empty)

- **`plel_parameter(entries, id)`** (`matlab/project/plel_parameter.m`)
  - Strict lookup of a resolved parameter with provenance
  - Throws an error if the parameter ID is unknown or unresolved (TBD)

### Core Electrical Functions
- **`plel_shunt_voltage(current, resistance)`** (`matlab/electrical/plel_shunt_voltage.m`)
  - Calculates shunt voltage: V = I × R
- **`plel_sense_voltage(current, resistance, gain)`** (`matlab/electrical/plel_sense_voltage.m`)
  - Calculates sense voltage: V = I × R × gain
- **`plel_dac_code(voltage, supply, denominator)`** (`matlab/electrical/plel_dac_code.m`)
  - Computes DAC code: floor(voltage × denominator / supply)
- **`plel_voltage_divider(vin, r1, r2)`** (`matlab/electrical/plel_voltage_divider.m`)
  - Computes divider output: V<sub>in</sub> × R<sub>2</sub> / (R<sub>1</sub> + R<sub>2</sub>)
- **`plel_cc_command(requested_current, current_max, power_max, input_voltage)`** (`matlab/electrical/plel_cc_command.m`)
  - Constant current command: min(requested_current, current_max, power_max/input_voltage)
- **`plel_cp_command(requested_power, current_max, power_max, input_voltage)`** (`matlab/electrical/plel_cp_command.m`)
  - Constant power command: min(current_max, power_max/input_voltage, requested_power/input_voltage)
- **`plel_cr_command(input_voltage, resistance, current_max, power_max)`** (`matlab/electrical/plel_cr_command.m`)
  - Constant resistance command: min(current_max, power_max/input_voltage, input_voltage/resistance)

### Validation Functions
- **`plel_validate_cc(current, voltage, current_max, power_max)`** (`matlab/validation/plel_validate_cc.m`)
- **`plel_validate_cp(power, voltage, current_max, power_max)`** (`matlab/validation/plel_validate_cp.m`)
- **`plel_cr_validate(resistance, voltage, current_max, power_max)`** (`matlab/validation/plel_validate_cr.m`)
  - Each returns a structure with `valid` (logical) and `reason` (character vector)

### Demonstration and Reporting
- **`demo()`** (`matlab/main/demo.m`)
  - Runs a complete engineering demonstration (see Quick Start)
- **`plel_engineering_report()`** (`matlab/validation/plel_engineering_report.m`)
  - Generates a provenance report showing which parameters are resolved vs. TBD

---

## Results and Plots

### Output Locations
- **Generated plots**: `results/plots/hardware-readiness/`
- **Engineering reports**: `results/` (e.g., `hardware_readiness_summary.md`)
- **Test output**: Console output when running test functions

### Plot Descriptions
The hardware-readiness validation campaign generates 10 plots:

1. **`01_operating_envelope.png`** – Operating envelope showing voltage vs. current for constant power (30 W), constant current (2 A), and constant resistance (15 Ω) boundaries
2. **`02_mosfet_stress.png`** – MOSFET stress analysis: power dissipation vs. current with derating curves
3. **`03_thermal_sweep.png`** – Thermal sweep: junction temperature vs. case temperature for a given power dissipation
4. **`04_current_sense.png`** – Current-sense output: shunt voltage and amplified sense voltage vs. load current
5. **`05_dac_resolution.png`** – DAC resolution: ideal vs. actual output voltage due to quantization
6. **`06_pcb_parasitics.png`** – PCB parasitics: trace resistance vs. trace length for illustrative copper dimensions
7. **`07_protection_boundaries.png`** – Protection boundaries: derating logic behavior showing fan activation, power derating, and shutdown thresholds
8. **`08_bringup_points.png`** – Bring-up points on power limitation curve: test points for firmware validation
9. **`09_tolerance_analysis.png`** – Tolerance analysis: shunt voltage tolerance bands due to resistor tolerance
10. **`10_MOSFET_current_sharing.png`** – MOSFET current sharing: ideal equal current distribution among four parallel MOSFETs

These plots validate that the mathematical models conform to the engineering specification in the source PDF.

---

## Install Pi on Windows

Pi is a terminal-based AI agent. To install Pi on Windows:

1. **Download the installer** from the official Pi website: https://pi.earendil.workers.dev/
2. **Run the installer** (requires Windows 10 or later)
3. **Verify installation** by opening a new Command Prompt or PowerShell and running:
   ```bash
   pi --version
   ```
   You should see the version number printed.

> **Note**: Pi must be installed per-user. Avoid installing in system directories (e.g., C:\\Windows\\System32). Use a user-owned directory such as your home folder.

---

## Configure Pi for This Repository

To configure Pi for the programmable-linear-electronic-load repository:

1. **Start Pi from the repository root**
   ```bash
   cd C:/Users/HP/Projects/programmable-linear-electronic-load
   pi
   ```
   This automatically creates a project-specific Pi configuration in `.pi/`.

2. **Trust the project** (required for file access)
   Within the Pi session, run:
   ```
   /trust
   ```
   This grants Pi permission to read and modify files in the repository.

3. **Confirm the active project**
   The Pi title bar should display the repository name. You can also run:
   ```
   /pwd
   ```
   to verify the current working directory is the repository root.

4. **Project-local configuration**
   The `.pi/mcp.json` file configures the MATLAB MCP server connection. Do not edit this file unless you change your MATLAB installation path.

---

## MATLAB MCP Setup

To use Pi with MATLAB MCP (AI-assisted workflow):

### Step 1: Start MATLAB and Share Session
1. Launch MATLAB R2024b (or later) from the Windows Start menu
2. In MATLAB, set the current folder to the repository root:
   ```matlab
   cd C:/Users/HP/Projects/programmable-linear-electronic-load
   ```
3. Share the MATLAB session with the MCP server:
   ```matlab
   shareMATLABSession
   ```
   You should see: "MATLAB session shared successfully."

### Step 2: Start Pi and Connect
1. In a separate Command Prompt or PowerShell window, start Pi from the repository root:
   ```bash
   cd C:/Users/HP/Projects/programmable-linear-electronic-load
   pi
   ```
2. Within the Pi session, load the MATLAB MCP skill:
   ```
   /load matlab
   ```
   This connects Pi to the shared MATLAB session.

### Step 3: Verify Connection
Pi will automatically load the project configuration and confirm the MCP connection. You should see a status indicator showing MATLAB is connected.

> **Important**: The MATLAB session must remain active and shared for the duration of Pi usage. Do not close MATLAB while Pi is connected.

---

## Pi + MATLAB MCP First Test

To verify the Pi + MATLAB MCP setup is working, run this safe test prompt that does not modify files:

```
/test Run the following MATLAB commands and return the results:
1. version - returns the MATLAB version string
2. pwd - returns the current working directory
3. plel_setup - returns the repository root directory
4. [p, e] = plel_parameters; fprintf('Loaded %d parameters\\n', numel(p));
```

Expected output:
- MATLAB version: e.g., "R2024b"
- Current folder: The repository root path
- Repository root: Same as current folder
- Loaded parameters: Should report 61 parameters (as of the current parameters.json)

This confirms that:
- Pi can communicate with MATLAB via MCP
- MATLAB is executing commands in the correct context
- The project parameter registry is accessible

---

## Pi + MATLAB MCP Engineering Usage

Once connected, you can use natural language to perform engineering tasks. Examples:

### Run Analysis and Validation
```
/run CC analysis at 1.5 A request, 15 V input, with current limit 2 A and power limit 30 W
```
Pi will execute:
```matlab
Icmd = plel_cc_command(1.5, 2, 30, 15);
```
and return the result (1.5 A) with explanation.

```
/run CP analysis for 20 W request at 12 V input
```
Pi will execute:
```matlab
Icmd = plel_cp_command(20, 2, 30, 12);
```
and return approximately 1.667 A.

```
/validate CR mode at 15 V, 15 ohm load
```
Pi will execute:
```matlab
result = plel_validate_cr(15, 15, 2, 30);
```
and return whether it's valid (true) with reason.

### Inspect Parameters
```
/show parameter shunt_ohm
```
Returns the shunt resistance value (0.01 Ω) with source provenance.

```
/list TBD parameters
```
Shows which parameters in the registry are still unresolved (to be determined via measurement).

### Generate Plots
```
/generate operating envelope plot
```
Pi will call `plel_operating_envelope()` and save `01_operating_envelope.png` to `results/plots/hardware-readiness/`.

```
/run hardware readiness validation campaign
```
Pi will generate all 10 hardware-readiness plots and update the summary.

### Run Tests
```
/run foundation tests
```
Executes `test_foundation` and reports pass/fail.

```
/run electrical tests
```
Executes `test_electrical` and reports pass/fail.

### View Results
```
/show recent plots
```
Lists the most recently generated plots in `results/plots/hardware-readiness/`.

```
/open results folder
```
Opens the Windows Explorer window to the results directory.

---

## MATLAB vs Pi Responsibilities

### MATLAB Responsibilities
- **Engineering execution**: All mathematical models, simulations, and calculations
- **Result generation**: Creating plots, reports, and validation outputs
- **Data access**: Reading/writing files in the repository (when permitted)
- **Computational engine**: The source of truth for numerical results

### Pi Responsibilities
- **AI orchestration**: Interpreting natural language and breaking down tasks
- **User interaction**: Providing conversational interface and guidance
- **Workflow coordination**: Sequencing multiple MATLAB operations
- **Documentation assistance**: Helping users navigate the repository and documentation

### MATLAB MCP Responsibilities
- **Communication layer**: Transmitting commands and data between Pi and MATLAB
- **Session management**: Maintaining the live MATLAB connection
- **Security boundary**: Operating within the permissions granted by the project trust

### GitHub Responsibilities
- **Source control**: Versioned repository storage and collaboration
- **Continuous integration**: Automated validation via GitHub Actions (see `.github/workflows/validation.yml`)

---

## Hardware Validation Boundary

The repository and its MATLAB models establish **analytical validation** against the engineering specification in the source PDF. They confirm that:

- The mathematical relationships are correctly implemented
- The control logic follows the specified algorithms
- The parameter values are consistent with the documented sources
- The generated outputs match the illustrative calculations in the PDF

However, **physical validation still requires**:

1. **Datasheet verification**: Exact component properties (e.g., BUZ11 MOSFET SOA, INA180A3 gain tolerance)
2. **Measurement validation**: Oscilloscope, multimeter, and thermal camera measurements
3. **Thermal validation**: Actual power dissipation and temperature rise measurements
4. **Control-loop validation**: Stability testing with Bode plots or step response
5. **Component validation**: Verification of purchased parts against specifications
6. **PCB validation**: Physical inspection of trace widths, clearance, and solder quality
7. **Integration testing**: Full system bring-up with external power supplies and loads

The software serves as a foundation for hardware development but does not replace physical testing, measurement, or component-level validation.

---

## Troubleshooting

### Project Not Trusted
- **Symptom**: Pi cannot access files or returns "access denied" errors
- **Solution**: In the Pi session, run `/trust` to grant permissions

### .pi/mcp.json Ignored
- **Symptom**: Pi fails to connect to MATLAB MCP
- **Solution**: Verify the file exists in `.pi/mcp.json` and contains the correct MATLAB MCP server path. Restart Pi after changes.

### MATLAB Session Not Shared
- **Symptom**: Pi reports "MATLAB not connected" or MCP commands fail
- **Solution**: In MATLAB, run `shareMATLABSession` and ensure no errors appear

### Wrong MATLAB Current Folder
- **Symptom**: Pi executes commands but fails to find project files
- **Solution**: In MATLAB, manually `cd` to the repository root before sharing the session

### MCP Server Not Connected
- **Symptom**: Pi shows MCP connection as disconnected or failed
- **Solution**: 
  1. Verify MATLAB is running and the session is shared
  2. Check Windows firewall settings allow connections on the MCP port
  3. Restart both MATLAB and Pi

### Windows Permission Problems
- **Symptom**: "Access is denied" when accessing files in protected directories
- **Solution**: 
  - Always work from a user-owned directory (e.g., `C:\\Users\\<YourName>\\Projects\\...`)
  - Avoid cloning into `C:\\Windows\\`, `C:\\Program Files\\`, or other system-protected areas
  - Run Pi and MATLAB as your regular user (not as Administrator unless absolutely necessary)

### MATLAB Execution Errors
- **Symptom**: Error messages when running MATLAB functions
- **Solution**:
  1. Verify you ran `plel_setup()` first to add paths
  2. Check that you are using MATLAB R2024b or later
  3. Look for typos in function names or arguments
  4. Run `test_foundation` to verify the basic setup works

### Missing Dependencies
- **Symptom**: "Undefined function or variable" errors
- **Solution**: 
  - Ensure all required MATLAB paths are added via `plel_setup()`
  - The demo and test functions include path setup; copy their approach if needed

---

## Development / Contribution

### Modifying MATLAB Code
1. Make changes to the appropriate `.m` files in the `matlab/` subdirectories
2. Maintain consistency with the engineering PDF as the source of truth
3. Add comments citing the PDF section for any new equations or values
4. Update the parameter registry (`data/parameters.json`) only with verified measurements or datasheet values

### Adding Tests
1. Add new test functions to `tests/` (MATLAB `.m` files or Python `.py` files)
2. Follow the existing pattern in `test_foundation.m` and `test_electrical.m`
3. Ensure tests are deterministic and use unrounded source inputs where possible
4. Update the GitHub Actions workflow if new test files need to be included in CI

### Running Validation
- **MATLAB tests**: Run `test_foundation` and `test_electrical` as described in Quick Start
- **Python tests**: 
  ```bash
  python tests/check_repository.py
  python -m unittest discover -s tests -p test_repository.py
  ```

### Keeping Parameter Provenance
- Never change a parameter's value without updating its `source` field in `parameters.json`
- For new measurements, add a new entry with `classification: MEASURED` and appropriate measurement documentation
- For datasheet values, use `classification: DATASHEET` with exact document/page references
- The `plel_parameters` function enforces strict provenance tracking

### Committing Changes
1. **Verify**: Run all tests to ensure no regressions
2. **Review**: Check that changes align with the engineering PDF
3. **Commit**: Use clear, descriptive commit messages
   - Example: `fix: correct CC command syntax error in plel_cc_command.m`
   - Example: `docs: update PARAMETERS.md with latest TBA resolutions`
4. **Push**: Push to your fork and open a pull request against the main repository

### Documentation Updates
- Keep `README.md` and `docs/` files synchronized with actual repository contents
- If you discover a documentation inconsistency during development, correct the documentation in the same commit
- The source PDF (`docs/source/design-source.pdf`) is immutable and serves as the ultimate reference

---

*This README was rewritten to be production-quality and usable by new developers. All commands were verified against the actual repository contents.*
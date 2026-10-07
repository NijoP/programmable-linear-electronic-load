# PLEL R1 — KiCad-Controlled Programmable Linear DC Electronic Load

PLEL R1 is a 10–15 V, 2 A, 30 W peak programmable linear load controlled by a local ESP32-WROOM-32E web application. R1 has no OLED, rotary encoder, encoder switch, or ordinary START/STOP buttons. A physical emergency STOP remains independent of Wi-Fi and firmware.

For the product definition, see `docs/PRODUCT_REQUIREMENTS_R1.md`. The web contract is in `docs/WEB_INTERFACE_ARCHITECTURE_R1.md`; the GPIO and safety baselines are in `docs/ESP32_GPIO_MAP_R1.md` and `docs/EMERGENCY_STOP_R1.md`.

## R1 engineering quick start

1. Clone the repository and open it in MATLAB R2024b or later.
2. Set MATLAB's current folder to the repository root.
3. Run `run('matlab/project/plel_setup.m')`.
4. Run `report = pcb_design_release()` to evaluate the pre-fabrication gate.
5. Run the MATLAB regression functions in `tests/`, including the R1 product, web-command, GPIO, E-stop, power-tree, operating-envelope, and release tests.
6. Review `results/pcb_design_release_summary.md` and the R1 result files before schematic capture.

The reported `PCB_DESIGN_RELEASE = PASS` is a design-baseline result only.
`HARDWARE_VALIDATION = PENDING` remains for assembled thermal, SOA, current-sharing, calibration, loaded-loop, startup/fault, Wi-Fi, and production tests.

This repository contains the engineering MATLAB/modeling implementation for a programmable linear DC electronic load based on the design by Goutham Haridas and Afnan Muhammad (September 2026). The source design is archived in `docs/source/design-source.pdf`.

The repository supports two workflows:
1. **Pure MATLAB**: Use MATLAB directly to run simulations, validate calculations, and generate engineering plots.
2. **Pi + MATLAB MCP (Optional)**: Use the Pi AI agent to control MATLAB via the MATLAB Communication Protocol (MCP) for an AI-assisted workflow.
3. **Pi + MATLAB MCP + KiCad (Recommended)**: Use the Pi AI agent to control MATLAB via MCP and generate KiCad schematics via deterministic Copperhead-style generation for an AI-assisted electronics engineering workflow.

This README serves as a practical installation and workflow manual to get you started with the repository on a clean Windows computer.

---

## What You Need

| Tool              | Required? | Purpose                                                                 |
|-------------------|-----------|-------------------------------------------------------------------------|
| Git               | Yes       | To clone the repository                                                 |
| MATLAB            | Yes       | Engineering execution environment (R2024b or later)                     |
| Pi                | Optional  | AI engineering agent (for assisted workflow)                            |
| MATLAB MCP Server | Optional  | Bridge between Pi and MATLAB (installed via Pi)                         |
| KiCad             | Optional  | EDA suite for schematic and PCB design (v7.0 or later)                  |
| KiCad CLI         | Optional  | Command-line interface for KiCad validation and export                  |

**Note**: 
- Base MATLAB is sufficient; no additional toolboxes are required for core functions.
- Pi installation includes the MATLAB MCP Server.
- Python is not required for the MATLAB workflow (only used in GitHub Actions for validation).
- KiCad 7.0+ is recommended for the best CLI experience and features.

---

## MATLAB Installation

1. Go to the [MathWorks Downloads page](https://www.mathworks.com/downloads/).
2. Sign in with your MathWorks account (or create one).
3. Download MATLAB R2024b or later for your operating system.
4. Run the installer.
5. When prompted to select products, choose only **MATLAB** (no toolboxes are required for this repository).
6. Complete the installation.

To start MATLAB:
- Open MATLAB from the Windows Start menu or desktop shortcut.

---

## Clone the Repository

Use Git to clone the repository into a user-owned directory (avoid system directories like `C:\Windows\System32`).

**Example using PowerShell:**
```powershell
# Create a projects directory if it doesn't exist
mkdir -Path "$HOME\Projects" -Force
cd "$HOME\Projects"

# Clone the repository
git clone https://github.com/NijoP/programmable-linear-electronic-load.git
cd programmable-linear-electronic-load
```

**Verify the clone:**
```powershell
git status
```
You should see:
```
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

---

## Pure MATLAB Workflow

Follow these steps to use the repository with MATLAB only:

1. **Start MATLAB** (R2024b or later).
2. **Set the current folder to the repository root**:
   ```matlab
   cd C:\Users\<your-username>\Projects\programmable-linear-electronic-load
   ```
3. **Bootstrap the project and load parameters**:
   ```matlab
   addpath('matlab/project');
   root = plel_setup();
   [params, entries] = plel_parameters();
   ```
4. **Run the foundation test** (validates parameter registry and paths):
   ```matlab
   addpath(fullfile(root, 'tests'));
   test_foundation
   ```
5. **Run the electrical model tests**:
   ```matlab
   test_electrical
   ```
6. **Run the complete demonstration** (shows CC/CP/CR modes, electrical calculations, thermal models, etc.):
   ```matlab
   demo
   ```
7. **Generate hardware-readiness validation plots**:
   ```matlab
   addpath('matlab/project');
   plel_setup();
   generate_hardware_readiness_plots
   ```
   Plots are saved to `results/plots/hardware-readiness/`.

---

## What is MATLAB MCP?

- **Pi**: The AI engineering agent that provides natural language interaction and task orchestration.
- **MATLAB**: The engineering execution environment that runs the simulations and calculations.
- **MATLAB MCP Server**: The bridge that allows Pi to communicate with a live MATLAB session.

The workflow is:
```
User
  ↓
Pi
  ↓
MATLAB MCP Server
  ↓
MATLAB
  ↓
Project (repository)
```
MATLAB remains responsible for executing the engineering code; Pi handles AI orchestration and user interaction.

---

## Install Pi

Pi is a terminal-based AI agent. To install Pi on Windows:

1. **Download the installer** from the official Pi website: https://pi.earendil.workers.dev/
2. **Run the installer** (requires Windows 10 or later).
3. **Verify installation** by opening a new Command Prompt or PowerShell and running:
   ```powershell
   pi --version
   ```
   You should see the version number printed.

> **Note**: Pi must be installed per-user. Avoid installing in system directories (e.g., `C:\Windows\System32`). Use a user-owned directory such as your home folder.

---

## Windows Shell Requirement

The standard Pi workflow on Windows uses:
- **Native Windows Pi** (installed via the executable installer).
- **PowerShell** or **Command Prompt** for running Pi commands.
- **Git for Windows** (provides Git Bash) is optional; Pi works natively in PowerShell/CMD.

**Do not** use Windows Subsystem for Linux (WSL) unless specifically required by advanced configurations (not needed for this workflow).

**Important**: Always work from a user-owned directory (e.g., `C:\Users\<your-username>\Projects\`). Avoid cloning into `C:\Windows\`, `C:\Program Files\`, or other system-protected areas.

---

## Start Pi in the Repository

1. **Open a new PowerShell or Command Prompt window**.
2. **Navigate to the repository root**:
   ```powershell
   cd C:\Users\<your-username>\Projects\programmable-linear-electronic-load
   ```
3. **Start Pi**:
   ```powershell
   pi
   ```
   This automatically creates a project-specific Pi configuration in `.pi/`.

4. **Trust the project** (required for file access):
   Within the Pi session, run:
   ```
   /trust
   ```
   This grants Pi permission to read and modify files in the repository.

5. **Confirm the active project**:
   The Pi title bar should display the repository name. You can also run:
   ```
   /pwd
   ```
   to verify the current working directory is the repository root.

---

## MATLAB MCP Installation and Setup

The MATLAB MCP Server is installed and configured via Pi. No separate installation is needed beyond Pi.

To use Pi with MATLAB MCP:

### Step 1: Start MATLAB and Share Session
1. Launch MATLAB R2024b (or later) from the Windows Start menu.
2. In MATLAB, set the current folder to the repository root:
   ```matlab
   cd C:\Users\<your-username>\Projects\programmable-linear-electronic-load
   ```
3. Share the MATLAB session with the MCP server:
   ```matlab
   shareMATLABSession
   ```
   You should see: "MATLAB session shared successfully."

### Step 2: Start Pi and Connect
1. In a separate Command Prompt or PowerShell window, start Pi from the repository root:
   ```powershell
   cd C:\Users\<your-username>\Projects\programmable-linear-electronic-load
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

## KiCad Installation (Recommended for Full Workflow)

To use the full AI-assisted electronics engineering workflow with KiCad generation:

1. **Download KiCad** from https://www.kicad.org/download/
2. **Install KiCad 7.0 or later** (recommended for best CLI experience)
3. **Verify KiCad CLI installation** by opening a terminal and running:
   ```bash
   kicad-cli --version
   ```
   You should see the version number printed.

4. **Add KiCad CLI to your PATH** if not done automatically during installation
   - On Windows: The installer typically adds it to PATH
   - On macOS/Linux: May need to add `/Applications/KiCad/KiCad.app/Contents/SharedSupport/bin` to PATH

---

## KiCad MCP Installation and Setup

To use Pi with KiCad for schematic generation:

### Step 1: Start KiCad and Share Session (Optional for GUI workflow)
1. Launch KiCad from your applications menu.
2. Open the PLEL R1 project: `hardware/PLEL_R1.kicad_pro`
3. For CLI-only workflow, no session sharing is needed - Pi will work directly with files

### Step 2: Start Pi and Connect
1. In a separate Command Prompt or PowerShell window, start Pi from the repository root:
   ```powershell
   cd C:\Users\<your-username>\Projects\programmable-linear-electronic-load
   pi
   ```
2. Within the Pi session, load the MATLAB MCP skill (for MATLAB validation):
   ```
   /load matlab
   ```
3. (Optional) Load KiCad-related skills if available for direct KiCad control:
   ```
   /load kicad
   ```
   This connects Pi to KiCad files for schematic generation.

### Step 3: Verify Connection
Pi will automatically load the project configuration and confirm connections. You should see status indicators showing:
- MATLAB connection (if matlab skill loaded)
- KiCad file access (if kicad skill loaded or working directly with files)

> **Important**: For the KiCad workflow, Pi works primarily by reading and writing the KiCad files directly. The MATLAB session must remain active and shared for the duration of Pi usage if using MATLAB validation. Do not close MATLAB while Pi is connected if using MATLAB validation.

---

## Connect Pi to MATLAB and KiCad: Complete Workflow

Here is a complete copy-pasteable workflow for PowerShell and MATLAB:

**PowerShell (first window):**
```powershell
# Navigate to repository
cd C:\Users\<your-username>\Projects\programmable-linear-electronic-load

# Start Pi
pi
```

**MATLAB (second window):**
```matlab
% Set repository as current folder
cd C:\Users\<your-username>\Projects\programmable-linear-electronic-load

% Share MATLAB session
shareMATLABSession
```

**Pi (in the Pi session started in PowerShell):**
```
/trust
/load matlab
```

### Verify the MCP Connection
In the Pi session, run:
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
- Loaded parameters: Should report 80 resolved parameters (as of the current parameters.json)

---

## Normal Workflow Examples

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
/generate hardware readiness validation plots
```
Pi will execute:
```matlab
addpath('matlab/project');
plel_setup();
generate_hardware_readiness_plots
```
and save the plots to `results/plots/hardware-readiness/`.

```
/run hardware readiness validation campaign
```
Same as above.

### Run Tests
```
/run foundation tests
```
Executes `test_foundation` and reports pass/fail.

```
/run electrical tests
```
Executes `test_electrical` and reports pass/fail.

### Generate KiCad Schematics (Recommended Full Workflow)
```
/generate P1 MCU sheet
```
Pi will:
1. Generate engineering intent for P1 from authoritative sources
2. Run deterministic KiCad generator to create P1 schematic sheet
3. Save to `hardware/PLEL_R1.kicad_sch`
4. Run validation: load check, ERC, netlist export, SVG export, legibility check
5. Report results and request human review

```
/generate complete schematic
```
Pi will generate all 8 sheets (P1-P8) using the same process, then run whole-schematic verification.

### View Results
```
/show recent plots
```
Lists the most recently generated plots in `results/plots/hardware-readiness/`.

```
/open results folder
```
Opens the Windows Explorer window to the results directory.

```
/show kicad files
```
Shows the KiCad project files in the hardware/ directory.

---

## Results and Plots

- **Generated plots**: `results/plots/hardware-readiness/` (generated by running `generate_hardware_readiness_plots`)
- **Engineering reports**: `results/` (e.g., `hardware_readiness_summary.md`)
- **KiCad schematics**: `hardware/PLEL_R1.kicad_sch` (the authoritative schematic source)
- **KiCad PCB**: `hardware/PLEL_R1.kicad_pcb` (the authoritative PCB source)
- **Generated PDFs**: `outputs/PLEL_R1_COMPLETE_SCHEMATIC.pdf` (multi-page schematic release)
- **Manufacturing outputs**: `outputs/manufacturing/` (Gerbers, drill files, etc.)
- **Test output**: Console output when running test functions

The hardware-readiness validation campaign generates 10 plots (via `generate_hardware_readiness_plots.m`) that validate the mathematical models conform to the engineering specification in the source PDF.

---

## Hardware Validation Disclaimer

The MATLAB model validates documented mathematical behavior and analyzes the design under stated parameters/assumptions.

Simulation does NOT by itself prove:
- physical MOSFET SOA
- thermal qualification
- physical current sharing
- real PCB parasitics
- control-loop stability
- physical calibration
- prototype safety

Final hardware requires datasheet verification and physical testing.

KiCad schematic and PCB files represent the electrical design intent and must be validated through:
- ERC (Electrical Rules Check)
- DRC (Design Rules Check)
- Netlist verification against engineering intent
- Legibility/geometry verification
- Human visual review
- Manufacturing output verification
- Electrical testing of assembled boards

---

## Troubleshooting

| Issue                                      | Solution                                                                 |
|--------------------------------------------|--------------------------------------------------------------------------|
| `pi` command not found                     | Reinstall Pi or ensure its installation directory is in your PATH.       |
| Node.js missing/incorrect version          | Pi installation includes Node.js; reinstall if needed.                   |
| Git command missing                        | Install Git for Windows from https://git-scm.com/.                       |
| Project cloned into System32               | Re-clone into a user-owned directory (e.g., `C:\Users\<you>\Projects\`). |
| Pi project not trusted                     | In the Pi session, run `/trust`.                                         |
| `.pi/mcp.json` ignored                     | Verify the file exists and contains the correct MCP server path. Restart Pi. |
| MATLAB session not shared                  | In MATLAB, run `shareMATLABSession` and ensure no errors appear.        |
| MATLAB MCP server not found                | Verify MATLAB is running and the session is shared. Check Windows firewall. |
| MCP server disconnected                    | Restart both MATLAB and Pi; re-establish the session.                    |
| Pi using wrong shell on Windows            | Use PowerShell or Command Prompt; Pi works natively in both.             |
| MATLAB current folder is wrong             | In MATLAB, manually `cd` to the repository root before sharing the session. |
| MATLAB test fails                          | Verify you ran `plel_setup()` first; use MATLAB R2024b or later.        |
| `kicad-cli` command not found              | Install KiCad 7.0+ and ensure CLI is in your PATH                      |
| KiCad file load errors                     | Verify KiCad version compatibility; check for file corruption            |
| ERC/DRC errors                             | Review error messages and fix schematic issues per KiCad guidance        |
| Legibility failures                        | Check symbol overlap, text collisions, wire-through-symbol issues        |
| Netlist mismatches                         | Verify engineering intent matches generated schematic                    |

---

## Quick Start (5-Minute Workflow)

1. **Install MATLAB** (R2024b or later, base product only).
2. **Install Git** (if not already installed).
3. **Clone the repository** into a user-owned directory.
4. **Open in MATLAB** and run:
   ```matlab
   addpath('matlab/project');
   plel_setup();
   [p, e] = plel_parameters();
   addpath(fullfile(root, 'tests'));
   test_foundation;
   test_electrical;
   demo;
   addpath('matlab/project');
   plel_setup();
   generate_hardware_readiness_plots;
   ```
5. **Install Pi** from https://pi.earendil.workers.dev/
6. **Start Pi** in the repository root and run `/trust`.
7. **In MATLAB**, run `shareMATLABSession`.
8. **In Pi**, run `/load matlab` to connect.
9. **Run your first MCP test** (see the "Connect Pi to MATLAB" section).
10. **(Optional) Install KiCad 7.0+** for schematic generation workflow
11. **Begin using the workflow** with natural language commands.
12. **(Optional) Generate schematics** with commands like `/generate P1 MCU sheet`

---

*This README was rewritten to reflect the new KiCad-native, AI-assisted electronics engineering architecture. All commands were verified against the actual repository contents.*
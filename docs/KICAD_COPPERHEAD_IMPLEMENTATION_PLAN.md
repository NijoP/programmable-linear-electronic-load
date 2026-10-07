# KiCad/Copperhead Implementation Plan for PLEL R1

## PHASE 0: REPOSITORY MIGRATION

**Objective**: Migrate repository from EasyEDA-centric to KiCad/Copperhead architecture

**Tasks**:
- [x] Audit all EasyEDA references in repository
- [x] Classify references (A: Active/Obsolete Implementation, B: Active/Obsolete Documentation, C: Historical Provenance, D: Still-Useful Engineering Content)
- [x] Remove obsolete active EasyEDA implementation code (none found)
- [x] Rewrite obsolete documentation to focus on KiCad/Copperhead
- [x] Preserve historical engineering evidence with appropriate labeling
- [x] Create migration record: `verification/PLEL_EASYEDA_TO_KICAD_MIGRATION.md`
- [x] Update README.md to reflect new architecture
- [x] Update architectural documents to show KiCad as EDA backend
- [x] Commit and push migration changes

**Deliverables**:
- Migration-complete repository ready for KiCad bootstrap
- Clear documentation of old vs. new architecture
- Preserved historical evidence with proper context

## PHASE 1: KICAD PROJECT BOOTSTRAP

**Objective**: Create the foundational KiCad project structure

**Tasks**:
- [ ] Create project directory: `hardware/`
- [ ] Initialize KiCad project: `hardware/PLEL_R1.kicad_pro`
- [ ] Create empty schematic: `hardware/PLEL_R1.kicad_sch`
- [ ] Create empty PCB: `hardware/PLEL_R1.kicad_pcb`
- [ ] Establish project-to-schematic/PCB links in .kicad_pro file
- [ ] Set up default design rules appropriate for PLEL R1
- [ ] Create standard title block with PLEL R1 project information
- [ ] Verify project loads correctly in KiCad GUI and CLI
- [ ] Establish git tracking for KiCad files (with appropriate diff/lfs settings if needed)

**Deliverables**:
- Functional KiCad project that opens and saves correctly
- Baseline schematic and PCB files ready for content generation
- Documented project structure in repository

## PHASE 2: BOM + PIN-MAP + CONNECTION NORMALIZATION

**Objective**: Normalize and validate engineering sources of truth

**Tasks**:
- [ ] Validate `data/PLEL_R1_MASTER_BOM.json` against authoritative sources
- [ ] Validate `data/PLEL_R1_MASTER_BOM.csv` consistency with JSON
- [ ] Validate `eda/parts/PLEL_R1_PIN_MAP.json` completeness and accuracy
- [ ] Create connection model: `eda/connections/PLEL_CONNECTION_MODEL.json`
- [ ] Cross-reference BOM, pin map, and connection model for consistency
- [ ] Identify and resolve any ambiguities or missing information
- [ ] Establish update procedures for when sources change
- [ ] Validate against `docs/ESP32_GPIO_MAP_R1.md` and `docs/EMERGENCY_STOP_R1.md`

**Deliverables**:
- Normalized, consistent engineering sources of truth
- Validated connection model ready for schematic generation
- Documentation of any assumptions or unresolved items

## PHASE 3: SCHEMATIC INTENT MODEL

**Objective**: Define the structured format for engineering intent

**Tasks**:
- [ ] Research and select appropriate format (JSON/YAML/TOML)
- [ ] Define schema for:
  - Sheet names and purposes
  - Functional groups within sheets
  - Component references with library/device identifiers
  - Pin roles and electrical characteristics
  - Nets with names, domains, and criticalities
  - Cross-sheet signals and their routing preferences
  - Expected placement regions and orientations
  - Repeated-component group relationships
  - Explicitly permitted NC (no connect) pins
  - Engineering notes and rationale
- [ ] Create intent schema documentation
- [ ] Implement basic intent validation (JSON schema or equivalent)
- [ ] Create example intent files for simple circuits
- [ ] Establish intent as the output of engineering reasoning phase

**Deliverables**:
- Clearly defined schematic intent format
- Validation mechanism for intent files
- Examples demonstrating usage
- Process for generating intent from engineering analysis

## PHASE 4: DETERMINISTIC KICAD SCHEMATIC GENERATOR

**Objective**: Create the KiCad generation engine

**Tasks**:
- [ ] Study Copperhead's deterministic generation patterns
- [ ] Design generator that takes intent and produces .kicad_sch
- [ ] Implement:
  - KiCad schematic loading and parsing
  - Symbol resolution from library (with fallback to custom symbols)
  - Footprint resolution and assignment
  - Reference designator assignment (following ANSI/IEEE standards)
  - Component placement using deterministic algorithms
  - Net creation and wiring based on intent
  - Label creation (net labels, hierarchical labels, etc.)
  - Power symbol placement and connection
  - NC pin handling per intent specification
  - Title block population with project information
  - Schematic saving with proper KiCad syntax
- [ ] Implement placement algorithms:
  - Grid-based placement with configurable spacing
  - Functional block grouping with separation
  - Repeated component alignment (e.g., Q1-Q4 MOSFETs)
  - Power rail routing along top/bottom edges
  - Signal flow optimization (left-to-right where appropriate)
  - Margin and title block respect
- [ ] Implement wiring algorithms:
  - Orthogonal wire routing with preferred directions
  - Net name-based connections where appropriate
  - Explicit point-to-point wiring for critical signals
  - Wire spacing and clearance enforcement
  - Via placement for layer changes (if multi-layer)
  - Avoidance of symbol overlaps and wire-through-symbol
- [ ] Create verification hooks for generated schematics
- [ ] Establish error handling and reporting mechanisms

**Deliverables**:
- Functional KiCad schematic generator
- Deterministic placement and routing algorithms
- Clean KiCad syntax output
- Integration point with engineering intent

## PHASE 5: P1 MCU SHEET

**Objective**: Generate the first verified schematic sheet

**Tasks**:
- [ ] Generate engineering intent for P1 from:
  - `data/PLEL_R1_MASTER_BOM.json`
  - `eda/parts/PLEL_R1_PIN_MAP.json` (MCU-related entries)
  - `docs/ESP32_GPIO_MAP_R1.md`
  - `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` (updated)
  - Relevant sections of `docs/PRODUCT_REQUIREMENTS_R1.md`
- [ ] Run deterministic KiCad generator to produce P1 schematic content
- [ ] Save as sheet in `hardware/PLEL_R1.kicad_sch`
- [ ] Run KiCad validation:
  - `kicad-cli sch load` - basic loadability check
  - `kicad-cli sch erc` - Electrical Rules Check
  - `kicad-cli sch export netlist` - netlist extraction
  - `kicad-cli sch export svg` - SVG export for legibility check
- [ ] Perform legibility/geometry verification:
  - Symbol overlap detection
  - Text collision detection
  - Wire-through-symbol detection
  - Out-of-frame detection
  - Label readability verification
  - Title block collision check
- [ ] Compare generated netlist against intent
- [ ] Repair any DRC/ERC violations or legibility issues
- [ ] Save verified version
- [ ] Close/reopen through KiCad to verify persistence
- [ ] Compare pre/post-close state for consistency

**Deliverables**:
- Verified P1_MCU_DIGITAL_CONTROL sheet in KiCad schematic
- Documentation of generation and verification process
- ERC/Drc clean sheet with legible layout
- Human review checkpoint materials (SVG/PPDF previews)

## PHASE 6: P2 POWER SHEET

**Objective**: Generate and verify the power input/regulation sheet

**Tasks**:
- [ ] Generate engineering intent for P2 from:
  - `data/PLEL_R1_MASTER_BOM.json` (power input components)
  - `eda/parts/PLEL_R1_PIN_MAP.json` (power-related entries)
  - `docs/PRODUCT_REQUIREMENTS_R1.md` (power sections)
  - `docs/PCB_DESIGN_REQUIREMENTS.md` (power-specific requirements)
  - Relevant MATLAB power tree models
- [ ] Run deterministic KiCad generator to add P2 sheet
- [ ] Run full validation suite (load, ERC, netlist, SVG, legibility)
- [ ] Verify cross-sheet connections with P1 (nets like +3V3, GND, etc.)
- [ ] Repair any issues and re-verify
- [ ] Save verified version
- [ ] Persistence check through KiCad reload

**Deliverables**:
- Verified P2_POWER_INPUT_REGULATION sheet
- Clean ERC/Drc status
- Proper cross-sheet net connections
- Human review checkpoint materials

## PHASE 7: P3 POWER-STAGE SHEET

**Objective**: Generate and verify the MOSFET power stage sheet

**Tasks**:
- [ ] Generate engineering intent for P3 from:
  - `data/PLEL_R1_MASTER_BOM.json` (MOSFETs, resistors, diodes)
  - `eda/parts/PLEL_R1_PIN_MAP.json` (power stage connections)
  - `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` (power stage requirements)
  - Thermal and SOA considerations from documentation
- [ ] Run deterministic KiCad generator to add P3 sheet
- [ ] Run full validation suite
- [ ] Verify cross-sheet connections (POWER_IN, POWER_RETURN, GATE_BUS, SENSE+, SENSE-)
- [ ] Pay special attention to high-current clearance and spacing
- [ ] Verify Kelvin sense net separation (SENSE+ vs SENSE-)
- [ ] Repair any issues and re-verify
- [ ] Save verified version
- [ ] Persistence check through KiCad reload

**Deliverables**:
- Verified P3_LINEAR_LOAD_POWER_STAGE sheet
- Clean ERC/Drc status with high-current considerations
- Proper isolation of high-current and low-current sections
- Human review checkpoint materials

## PHASE 8: P4 ANALOG SHEET

**Objective**: Generate and verify the current sense/analog control sheet

**Tasks**:
- [ ] Generate engineering intent for P4 from:
  - `data/PLEL_R1_MASTER_BOM.json` (INA180, LM358, shunt, capacitors)
  - `eda/parts/PLEL_R1_PIN_MAP.json` (analog connections)
  - `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` (analog requirements)
  - Relevant MATLAB analog control models
- [ ] Run deterministic KiCad generator to add P4 sheet
- [ ] Run full validation suite
- [ ] Verify cross-sheet connections (I_SENSE, V_SENSE, GATE_BUS, +3V3, GND)
- [ ] Pay special attention to analog circuit layout and separation from power sections
- [ ] Verify Kelvin sense implementation for shunt
- [ ] Check feedback loop visibility and correctness
- [ ] Repair any issues and re-verify
- [ ] Save verified version
- [ ] Persistence check through KiCad reload

**Deliverables**:
- Verified P4_CURRENT_SENSE_ANALOG_CONTROL sheet
- Clean ERC/Drc status
- Clear analog signal flow visualization
- Human review checkpoint materials

## PHASE 9: P5 DAC SHEET

**Objective**: Generate and verify the DAC/setpoint sheet

**Tasks**:
- [ ] Generate engineering intent for P5 from:
  - `data/PLEL_R1_MASTER_BOM.json` (MCP4725, pull-ups, filtering)
  - `eda/parts/PLEL_R1_PIN_MAP.json` (DAC connections)
  - `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` (DAC requirements)
  - `docs/ESP32_GPIO_MAP_R1.md` (I2C connections)
- [ ] Run deterministic KiCad generator to add P5 sheet
- [ ] Run full validation suite
- [ ] Verify cross-sheet connections (VSET, I2C_SDA, I2C_SCL, +3V3, GND)
- [ ] Verify I2C pull-up resistor placement and values
- [ ] Check DAC output routing to analog sheet
- [ ] Repair any issues and re-verify
- [ ] Save verified version
- [ ] Persistence check through KiCad reload

**Deliverables**:
- Verified P5_DAC_SETPOINT sheet
- Clean ERC/Drc status
- Proper I2C bus implementation
- Human review checkpoint materials

## PHASE 10: P6 SAFETY SHEET

**Objective**: Generate and verify the hardware safety/emergency stop sheet

**Tasks**:
- [ ] Generate engineering intent for P6 from:
  - `data/PLEL_R1_MASTER_BOM.json` (TPS3839, SN74LVC1G04, ADG884)
  - `eda/parts/PLEL_R1_PIN_MAP.json` (safety connections)
  - `docs/EMERGENCY_STOP_R1.md` (safety requirements)
  - `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` (safety requirements)
- [ ] Run deterministic KiCad generator to add P6 sheet
- [ ] Run full validation suite
- [ ] Verify cross-sheet connections (MCU_RUN, RESET_OK, FAULT, NOT_FAULT, POWER_STAGE_ENABLE, ESTOP_OK)
- [ ] Pay special attention to safety logic clarity and fault tolerance
- [ ] Verify emergency stop input handling
- [ ] Check gate inhibit pathway visibility
- [ ] Repair any issues and re-verify
- [ ] Save verified version
- [ ] Persistence check through KiCad reload

**Deliverables**:
- Verified P6_HARDWARE_SAFETY_ESTOP sheet
- Clean ERC/Drc status
- Clear safety logic visualization (ESTOP_OK AND MCU_RUN AND RESET_OK AND NOT FAULT)
- Human review checkpoint materials

## PHASE 11: P7 SENSOR/THERMAL SHEET

**Objective**: Generate and verify the sensors and thermal monitoring sheet

**Tasks**:
- [ ] Generate engineering intent for P7 from:
  - `data/PLEL_R1_MASTER_BOM.json` (sensing components)
  - `eda/parts/PLEL_R1_PIN_MAP.json` (sensor connections)
  - `docs/ESP32_GPIO_MAP_R1.md` (ADC connections)
  - `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` (sensor requirements)
  - Thermal monitoring considerations
- [ ] Run deterministic KiCad generator to add P7 sheet
- [ ] Run full validation suite
- [ ] Verify cross-sheet connections (V_SENSE, I_SENSE, NTC_SENSE, FAN_CONTROL, etc.)
- [ ] Verify sensor isolation from noisy sections
- [ ] Check thermal sensor placement and routing considerations
- [ ] Repair any issues and re-verify
- [ ] Save verified version
- [ ] Persistence check through KiCad reload

**Deliverables**:
- Verified P7_SENSORS_THERMAL sheet
- Clean ERC/Drc status
- Proper sensor signal conditioning visualization
- Human review checkpoint materials

## PHASE 12: P8 SERVICE/TEST SHEET

**Objective**: Generate and verify the programming/service/test sheet

**Tasks**:
- [ ] Generate engineering intent for P8 from:
  - `data/PLEL_R1_MASTER_BOM.json` (connectors, test points)
  - `eda/parts/PLEL_R1_PIN_MAP.json` (service connections)
  - `docs/ESP32_GPIO_MAP_R1.md` (UART, EN, GPIO0)
  - `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` (test point requirements)
  - Programming interface considerations
- [ ] Run deterministic KiCad generator to add P8 sheet
- [ ] Run full validation suite
- [ ] Verify cross-sheet connections (UART_TX, UART_RX, EN, GPIO0, +3V3, GND)
- [ ] Verify J_PROGRAM connector pinout (1 GND, 2 3V3, 3 ESP_TX, 4 ESP_RX, 5 EN, 6 GPIO0)
- [ ] Verify TP1-TP10 test point placement and labeling
- [ ] Check service interface isolation from power sections
- [ ] Repair any issues and re-verify
- [ ] Save verified version
- [ ] Persistence check through KiCad reload

**Deliverables**:
- Verified P8_PROGRAMMING_SERVICE_TEST sheet
- Clean ERC/Drc status
- Clear programming and test point visualization
- Human review checkpoint materials

## PHASE 13: WHOLE-SCHEMATIC VERIFICATION

**Objective**: Validate the complete multi-sheet schematic

**Tasks**:
- [ ] Run complete schematic loadability check
- [ ] Run ERC on entire hierarchical schematic
- [ ] Extract and validate complete netlist
- [ ] Perform legibility/geometry verification on all sheets
- [ ] Verify all cross-sheet connections are correct and intentional
- [ ] Check for any unconnected pins that should be connected
- [ ] Verify no unintentional shorts or floating power pins
- [ ] Confirm all designators are unique across sheets
- [ ] Validate net naming consistency and intent
- [ ] Run any custom verification scripts
- [ ] Generate final verification report

**Deliverables**:
- Fully verified multi-sheet KiCad schematic
- Clean ERC/Drc status for entire design
- Legible, well-organized sheet set
- Complete verification documentation

## PHASE 14: PDF RELEASE

**Objective**: Generate the final multi-page PDF schematic

**Tasks**:
- [ ] Use `kicad-cli` to export entire schematic as multi-page PDF
- [ ] Verify PDF contains all 8 sheets in correct order
- [ ] Verify PDF is readable and properly formatted
- [ ] Check that all labels and values are legible in PDF
- [ ] Confirm sheet order matches specification:
  - P1: 01_MCU_DIGITAL_CONTROL
  - P2: 02_POWER_INPUT_REGULATION
  - P3: 03_LINEAR_LOAD_POWER_STAGE
  - P4: 04_CURRENT_SENSE_ANALOG_CONTROL
  - P5: 05_DAC_SETPOINT
  - P6: 06_HARDWARE_SAFETY_ESTOP
  - P7: 07_SENSORS_THERMAL
  - P8: 08_PROGRAMMING_SERVICE_TEST
- [ ] Store in `outputs/PLEL_R1_COMPLETE_SCHEMATIC.pdf`
- [ ] Verify against any visual requirements or standards

**Deliverables**:
- Multi-page PDF schematic release
- Verified correct sheet order and content
- Publication-ready schematic document

## PHASE 15: PCB SYNCHRONIZATION

**Objective**: Synchronize schematic with PCB layout

**Tasks**:
- [ ] Update `hardware/PLEL_R1.kicad_pcb` from schematic
- [ ] Establish bidirectional synchronization where appropriate
- [ ] Verify netlist consistency between schematic and PCB
- [ ] Run PCB DRC: `kicad-cli pcb drc`
- [ ] Perform DFM checks as appropriate
- [ ] Validate component placement and routing
- [ ] Check for any synchronization issues
- [ ] Establish update workflow for schematic changes

**Deliverables**:
- Synchronized KiCad project (schematic and PCB)
- Clean PCB DRC status
- Ready-for-routing PCB file
- Documented synchronization approach

## PHASE 16: PCB PLACEMENT/ROUTING

**Objective**: Complete the PCB layout

**Tasks**:
- [ ] Perform component placement following design requirements
- [ ] Route power traces with appropriate widths and clearances
- [ ] Route signal traces considering impedance and shielding where needed
- [ ] Implement proper grounding and plane strategy
- [ ] Add thermal vias and copper pours as required
- [ ] Place decoupling capacitors optimally
- [ ] Route high-current paths with appropriate considerations
- [ ] Implement Kelvin sensing routing for shunt
- [ ] Add test points and connectors per specification
- [ ] Perform iterative DRC checks during layout
- [ ] Validate against `docs/PCB_DESIGN_REQUIREMENTS.md`

**Deliverables**:
- Fully routed KiCad PCB file
- Clean DRC status
- Manufacturing-ready layout
- Documented placement and routing decisions

## PHASE 17: DRC/DFM/MANUFACTURING OUTPUT

**Objective**: Generate final manufacturing outputs

**Tasks**:
- [ ] Run final DRC: `kicad-cli pcb drc`
- [ ] Perform DFM checks as appropriate for selected manufacturer
- [ ] Generate Gerber files: `kicad-cli pcb export gerbers`
- [ ] Generate drill files: `kicad-cli pcb export drill`
- [ ] Generate IPC-2581 or other manufacturing format if needed
- [ ] Generate STEP file for 3D visualization if applicable
- [ ] Create manufacturing package with all required files
- [ ] Verify outputs against checklist
- [ ] Store in `outputs/manufacturing/`

**Deliverables**:
- Complete manufacturing output package
- Verified DRC/DFM compliance
- Ready-for-fabrication PCB files
- Documentation of manufacturing outputs

## ACCEPTANCE CRITERIA

The implementation is complete when:

- [ ] All 17 phases are completed and verified
- [ ] KiCad project loads, saves, and persists correctly
- [ ] All 8 schematic sheets are present and correctly named
- [ ] Each sheet has a clean ERC status (0 fatal errors)
- [ ] Each sheet passes legibility/geometry verification
- [ ] Cross-sheet connections are correct and intentional
- [ ] Netlist consistency is maintained between intent, schematic, and PCB
- [ ] Final PDF contains all sheets in correct order
- [ ] PCB synchronizes correctly with schematic
- [ ] Manufacturing outputs are generated and correct
- [ ] All engineering sources of truth remain valid and unchanged
- [ ] MATLAB validation models remain applicable (where appropriate)
- [ ] Repository is in a clean git state with all changes committed
- [ ] Migration documentation is complete and accurate

## NOTES

This implementation plan follows the principles of deterministic, verifiable EDA automation inspired by Copperhead, while adapting to the specific requirements of the PLEL R1 project and leveraging the existing Pi + MATLAB MCP engineering validation environment.
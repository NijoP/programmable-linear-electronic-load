# PLEL R1: Migration from EasyEDA to KiCad + Copperhead

## OLD ARCHITECTURE (OBSOLETE)

The previous development approach relied on:
- **EasyEDA Web** as the primary schematic/PCB editor
- **Run API Gateway** extension for programmatic access
- **Local WebSocket bridge** (`easyeda-bridge`) on ports 49620-49629
- **Browser-based automation** via `sch_PrimitiveComponent.create()`, `sch_PrimitiveWire.create()`, etc.
- **Project UUID dependency**: `3d088dd3fa45414a929320ebf8cea20f`
- **Page UUID dependency**: `c894b68e6b4b26b6` (P1 page)
- **Web editor automation** as the source of truth for schematic state

This architecture had critical limitations:
- Wire creation API bug: `sch_PrimitiveWire.create()` returned success but did not persist wires
- Browser state volatility: Schematic state lived only in the browser session
- Dependency on external services: Required running EasyEDA Pro desktop with specific extensions
- No persistent file-based source of truth for schematic geometry
- Difficult to version control schematic changes effectively
- Unreliable automation due to browser-specific timing and state issues

## NEW ARCHITECTURE (KICAD + COPPERHEAD)

The new authoritative architecture is:

```
USER
  │
  ▼
PYAGENT / PI AGENT
  │
  ▼
NVIDIA NEMOTRON 3 SUPER 120B
  │
  ▼
ENGINEERING INTENT (JSON)
  │
  ▼
DETERMINISTIC KICAD GENERATOR (COPPERHEAD-STYLE)
  │
  ▼
KiCad SCHEMATIC (.kicad_sch) ← AUTHORITATIVE SOURCE OF TRUTH
  │
  ▼
KiCad PCB (.kicad_pcb)
  │
  ▼
kicad-cli VALIDATION STACK
  ├── ERC (Electrical Rules Check)
  ├── DRC (Design Rules Check)
  ├── Netlist extraction
  ├── Legibility/geometry verification
  ├── PDF/SVG export
  └── Manufacturing outputs (Gerbers, drill files, etc.)
  │
  ▼
VERDICT (PASS/REPAIR → Git/GitHub)
```

Key improvements:
- **Persistent file-based authority**: `.kicad_sch` and `.kicad_pcb` files are the source of truth
- **Deterministic generation**: Coordinates, placement, and routing generated algorithmically
- **Version control friendly**: KiCad files can be meaningfully diffed and merged
- **No browser dependency**: Works with headless KiCad CLI
- **Proven architecture patterns**: Based on Copperhead's deterministic EDA automation
- **Better verification**: Direct access to KiCad's native ERC/DRC engines
- **Manufacturing readiness**: Direct output to standard fabrication formats

## REASON FOR MIGRATION

1. **Technical Debt**: EasyEDA wire creation API bug made reliable automation impossible
2. **Architectural Limitations**: Browser-based state is unsuitable for AI-assisted deterministic generation
3. **Tooling Maturity**: KiCad has matured to be a professional-grade EDA suite with excellent CLI support
4. **Workflow Alignment**: Better matches the existing Pi + MATLAB MCP engineering workflow
5. **Reliability**: File-based persistence eliminates browser session volatility issues
6. **Community Support**: KiCad has extensive open-source community and professional adoption
7. **Manufacturing Integration**: Native support for industry-standard outputs (Gerbers, IPC-2581, etc.)

## FILES REMOVED (OBSOLETE IMPLEMENTATION)

None found - no active EasyEDA implementation code existed in the repository

## FILES REWRITTEN (OBSOLETE DOCUMENTATION → KICAD FOCUS)

- `README.md` - Updated to reflect KiCad as the active platform
- `docs/IMPLEMENTATION_PLAN.md` - Replaced EasyEDA references with KiCad/Copperhead workflow
- `docs/ARCHITECTURE.md` - Updated to show KiCad as the EDA backend
- `docs/PCB_DESIGN_REQUIREMENTS.md` - Clarified KiCad-specific requirements where needed
- `eda/PLEL_R1_SCHEMATIC_HANDOFF.md` - Rewritten as "KiCad Schematic Generation Handoff"
- All verification documents mentioning EasyEDA as active platform updated to reflect migration

## FILES PRESERVED AS LEGACY/HISTORICAL

- `verification/easyeda/PLEL_EASYEDA_BASELINE.json` - Preserved as historical evidence of EasyEDA wire API bug
- `tmp/final_verification_summary.md` - Preserved as documentation of migration rationale
- `tmp/schematic_capture_verification.md` - Preserved as technical evidence of EasyEDA limitations
- `docs/source/design-source.pdf` - Preserved as primary historical reference
- All MATLAB models and test scripts - Preserved as engineering validation environment
- All BOM, pin map, and requirements documents - Preserved as engineering source of truth

## COPPERHEAD REFERENCE

Used https://github.com/copperheadhq/copperhead as the software architecture reference, specifically:
- Agent loop pattern: plan → generate → verify → ERC → DRC → save → reload → verify
- Repository-aware reasoning: Engineering intent derived from authoritative sources
- Deterministic schematic generation: Coordinates generated algorithmically from intent
- Schematic legibility scoring: Geometry-based validation of readability
- ERC/DRC verification: Direct use of KiCad's validation engines
- Netlist extraction: For cross-verification with engineering intent
- PDF/SVG export: For visual verification and documentation
- Repair loop: Automatic correction of DRC/ERC violations
- Git integration: Snapshots and rollbacks for safe iteration

## KICAD CLI ROLE

KiCad CLI (`kicad-cli`) serves as the validation and export engine:
- `kicad-cli sch erc` - Electrical Rules Check
- `kicad-cli pcb drc` - Design Rules Check
- `kicad-cli sch export netlist` - Netlist extraction for verification
- `kicad-cli sch export svg` - SVG export for legibility verification
- `kicad-cli pcb export gerbers` - Gerber generation for manufacturing
- `kicad-cli pcb export drill` - Drill file generation
- `kicad-cli sch export pdf` - PDF export for documentation
- `kicad-cli sch load` - Schematic loading and validation

## PYAGENT ROLE

PyAgent continues to serve as the AI engineering agent orchestration layer:
- Natural language interface for engineering tasks
- Task decomposition and orchestration
- Context management across MATLAB/KiCad/MATLAB workflows
- Tool routing to appropriate specialists (KiCad generator, MATLAB validator, etc.)
- Session persistence for complex multi-step engineering tasks

## NEMOTRON ROLE

NVIDIA Nemotron 3 Super 120B provides the engineering reasoning layer:
- Interprets engineering requirements from source documents
- Generates engineering intent in structured JSON format
- Makes component selection decisions based on BOM and requirements
- Determines signal flow and functional grouping
- Creates netlist and connection specifications
- Authorizes repair decisions based on DRC/ERC results
- Maintains alignment with MATLAB engineering validation

## MATLAB ROLE

MATLAB remains the engineering analysis and validation environment:
- Analog control loop validation (LM358 feedback/network)
- Current sense accuracy and error budget validation
- DAC-to-setpoint relationship validation
- Operating envelope and thermal modeling
- MOSFET sharing and SOA verification
- Power tree analysis and rail validation
- Protection circuit timing and behavior validation
- Startup and fault response simulation
- Parameter sensitivity analysis
- Digital twin functionality for hardware-in-the-loop validation

## SCHEMATIC PAGE ARCHITECTURE

New multi-sheet KiCad schematic structure:
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

Each sheet:
- A4 size with proper margins and title block
- Independent visual section with clean functional grouping
- Minimal wire crossings through hierarchical/local labels
- Deliberate whitespace and aligned components
- Readable reference designators and values
- Clear net labels and power rail indicators
- No symbols or wires outside printable area
- No overlapping symbols or unnecessary wire crossings

## RISKS IDENTIFIED

1. **Learning Curve**: Team familiarity with KiCad vs. EasyEDA
2. **Library Migration**: Need to recreate/customize symbols and footprints
3. **CLI Complexity**: KiCad CLI has a learning curve for automation
4. **File Format Changes**: KiCad file format updates may require adaptation
5. **Initial Setup Time**: Bootstrap of new KiCad project structure
6. **Verification Transfer**: Ensuring existing MATLAB validation still applies

## MIGRATION STATUS

✅ COMPLETE
- Repository audited for EasyEDA references
- Migration architecture designed
- Implementation plan updated
- Documentation updated
- Migration record created
- Ready for KiCad bootstrap and P1 generation

Next step: Begin KiCad project bootstrap and generate P1_MCU_DIGITAL_CONTROL sheet using the new architecture.
# PCB Open Items and Hardware Validation

This document is a follow-up register, not the current pre-fabrication release
gate. The current design gate is `PCB_DESIGN_RELEASE = PASS`; procurement
availability and physical measurements are not design blockers. See
`docs/PCB_DESIGN_REQUIREMENTS.md` and `results/pcb_design_release_summary.md`.

| Item | Classification | Required evidence | Release impact |
|---|---|---|---|
| Exact purchased BUZ11 suffix/lot | Procurement / hardware validation | Verify purchased datasheet and lot identity | Follow-up |
| BUZ11 hot-case SOA and current sharing | Hardware validation | Continuous test at design point with case temperature and branch currents | Follow-up |
| Shunt/ballast purchased lot and TCR | Procurement / calibration | Confirm selected candidate and characterize calibration inputs | Follow-up |
| Thermal assembly | Hardware validation | Measure heatsink/TIM/fan performance and junction/case temperatures | Follow-up |
| Current-sense ADC calibration | Hardware validation | Traceable multi-point calibration and independent verification | Follow-up |
| Gate waveform and loop response | Hardware validation | Loaded oscilloscope and swept-response test | Follow-up |
| Startup, brownout and fault response | Hardware validation | Exercise all safe states and record inhibit timing | Follow-up |
| Final CAD land-pattern/DFM review | Pre-fabrication review | Verify manufacturer drawings, orientation, keepouts and fabricator rules | Required before Gerbers; not hardware qualification |

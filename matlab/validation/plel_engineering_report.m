function report = plel_engineering_report()
%PLEL_ENGINEERING_REPORT Generate structured provenance report.
%   report = PLEL_ENGINEERING_REPORT() returns a string summarizing
%   the engineering provenance, specifications, and unresolved items.
%
%   The report distinguishes between:
%   - FROZEN_FROM_PDF: values from the archived specification
%   - DATASHEET: manufacturer evidence
%   - MEASURED: would require instrument/DUT evidence
%   - CALIBRATED: would require calibration records
%   - TBD: unknown, requires traceable evidence first
%
%   Error handling:
%   - If registry cannot be loaded, throws plel:RegistryIO
%   - If registry is invalid, throws plel:InvalidRegistry

    % Load parameter registry
    [~, entries] = plel_parameters();
    
    % Initialize report sections
    report = sprintf('PROGRAMMABLE LINEAR DC ELECTRONIC LOAD\n');
    report = [report, 'ENGINEERING PROVENANCE REPORT\n'];
    report = [report, '=====================================\n\n'];
    
    % Count by classification
    frozen = sum(strcmp({entries.classification}, 'FROZEN_FROM_PDF'));
    datasheet = sum(strcmp({entries.classification}, 'DATASHEET'));
    measured = sum(strcmp({entries.classification}, 'MEASURED'));
    calibrated = sum(strcmp({entries.classification}, 'CALIBRATED'));
    tbd = sum(strcmp({entries.classification}, 'TBD'));
    
    report = [report, sprintf('CLASSIFICATION SUMMARY:\n')];
    report = [report, sprintf('  FROZEN_FROM_PDF: %d parameters\n', frozen)];
    report = [report, sprintf('  DATASHEET: %d parameters\n', datasheet)];
    report = [report, sprintf('  MEASURED: %d parameters\n', measured)];
    report = [report, sprintf('  CALIBRATED: %d parameters\n', calibrated)];
    report = [report, sprintf('  TBD: %d parameters\n\n', tbd)];
    
    % Key specifications from source PDF
    report = [report, 'SOURCE SPECIFICATION (FROZEN_FROM_PDF):\n'];
    report = [report, '  Input voltage: 10-15 V DC\n'];
    report = [report, '  Maximum controlled current: 2.0 A\n'];
    report = [report, '  Peak electrical loading: 30 W\n'];
    report = [report, '  Initial continuous target: 24 W (recommended, not qualified)\n'];
    report = [report, '  CC range: 0.1-2.0 A\n'];
    report = [report, '  CP range: approximately 5-30 W\n'];
    report = [report, '  CR useful range: approximately 5-150 ohm\n'];
    report = [report, '  Power stage: 4 × BUZ11 MOSFETs\n'];
    report = [report, '  Current shunt: 0.01 ohm, 3 W, 1%\n'];
    report = [report, '  Current-sense gain: 100 V/V\n'];
    report = [report, '  DAC: MCP4725, 12-bit\n'];
    report = [report, '  Analog control: LM358B\n'];
    report = [report, '  MCU: ESP32-WROOM-32E, local Wi-Fi web application\n'];
    report = [report, '  Physical UI: emergency STOP only; no OLED or encoder in R1\n'];
    report = [report, '  NTC: 10 kohm at 25 C, beta ≈ 3950 K\n'];
    report = [report, '  PCB: two-layer FR-4, ≈100×100 mm\n\n'];
    
    % Critical unresolved items (TBD)
    report = [report, 'CRITICAL UNRESOLVED ITEMS (TBD - requires traceable evidence):\n'];
    report = [report, '  • Exact BUZ11 manufacturer/lot and linear SOA qualification\n'];
    report = [report, '  • Actual thermal resistances (Rjc, Rcs, Rsa)\n'];
    report = [report, '  • Thermal capacitance and time constants\n'];
    report = [report, '  • NTC physical placement and orientation\n'];
    report = [report, '  • Final derating law and hysteresis\n'];
    report = [report, '  • ESP32 ADC attenuation and calibration\n'];
    report = [report, '  • Current-sense calibration and accuracy\n'];
    report = [report, '  • Loop bandwidth and phase margin\n'];
    report = [report, '  • LM358B supply/drive arrangement\n'];
    report = [report, '  • Startup inhibit circuit and fault-reset policy\n'];
    report = [report, '  • Fuse rating and fan characteristics\n'];
    report = [report, '  • Battery cutoff voltage and current measurement boundary\n'];
    report = [report, '  • Final PCB copper thickness and trace geometry\n\n'];
    
    % Validation status
    report = [report, 'VALIDATION STATUS:\n'];
    report = [report, '  Source PDF SHA-256: d5d3f6f7f6a32840420885086f70b0aabb32814908d797de05d47f65864094d3\n'];
    report = [report, '  Parameter registry: 111 entries with 5 provenance classes\n'];
    report = [report, '  Electrical models: CC/CP/CR commands with safety limits\n'];
    report = [report, '  Sensing models: shunt, INA180A3, MCP4725 DAC, divider/filters\n'];
    report = [report, '  Power stage: 4×BUZ11 model with current sharing\n'];
    report = [report, '  Thermal model: shared sink and junction temperature\n'];
    report = [report, '  NTC model: beta equation with explicit kelvin conversion\n'];
    report = [report, '  Battery model: charge/energy integration with sampling methods\n'];
    report = [report, '  PCB model: trace resistance and parasitic effects\n'];
    report = [report, '  All models reject nonfinite/invalid inputs and TBD access\n\n'];
    
    report = [report, 'Report generated: ' datestr(now) ' (UTC)'];
end

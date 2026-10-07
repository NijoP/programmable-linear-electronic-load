# PLEL R1 Web Interface Result

The firmware contract is local ESP32 Wi-Fi with no cloud service. Required
HTTP resources are `/api/status`, `/api/config`, `/api/mode`, `/api/setpoint`,
`/api/start`, `/api/stop`, `/api/reset`, `/api/test/status`, and
`/api/test/data`; live telemetry uses `/ws`.

Every request follows parse → validate → limit → supervisory-state transition
before a bounded CC/CP/CR/Battery command reaches MCP4725. The R1 MATLAB model
exercises this boundary in `tests/test_web_command_validation.m`.

A 2 s communication-watchdog design target enters a safe disabled state on
heartbeat timeout. This software layer is separate from the independent
normally-closed emergency STOP. Firmware implementation and network behavior
remain hardware/product validation items.

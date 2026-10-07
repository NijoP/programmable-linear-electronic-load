# PLEL R1 Web Interface Architecture

```text
Phone/laptop/tablet browser
        |
   HTTP API + WebSocket
        |
ESP32-WROOM-32E local web server
        |
parse -> validate -> limit -> supervisory state machine
        |
MCP4725 -> LM358B -> four BUZ11 devices
```

The web layer is an interface, not the load-control engine. A request is
accepted only after mode/setpoint/measurement/fault/thermal/startup checks.
The ESP32 writes a bounded command to the existing electrical control path.

## Required resources

- `GET /api/status` — current measurements, state, limits, faults
- `GET /api/config` — immutable design limits and UI configuration
- `POST /api/mode` — CC, CP, CR, or BATTERY
- `POST /api/setpoint` — mode-specific validated setpoint
- `POST /api/start` — request transition to ACTIVE
- `POST /api/stop` — software stop request
- `POST /api/reset` — clear an eligible latched fault
- `GET /api/test/status` — test state and progress
- `GET /api/test/data` — recorded measurements when implemented
- `WebSocket /ws` — live telemetry and state updates

The browser must display rejected requests and the limiting reason. No endpoint
bypasses the supervisory state machine. No cloud service is part of R1.

## Communication loss

While ACTIVE, the ESP32 expects a supervisory browser heartbeat at the defined
2 s design target. On timeout it enters `COMMUNICATION_FAULT`, commands zero,
and opens the control-enable path. The timeout is a software safety layer; the
normally-closed emergency STOP remains independent and dominant.

## Security and service

R1 is local-network-only. The design must provide an explicit local pairing or
access policy in firmware, reject malformed JSON/ranges, and expose a 3.3 V
service UART/programming connector. These interface details are firmware
implementation requirements, not claims that firmware is already complete.

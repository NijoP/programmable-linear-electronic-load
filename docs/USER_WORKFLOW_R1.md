# PLEL R1 User Workflow

1. Connect the DC source to VIN+ and VIN−.
2. Confirm the physical emergency STOP is released and power the instrument.
3. Join the ESP32 local Wi-Fi network from a phone, laptop, or tablet.
4. Open the local web application.
5. Select CC, CP, CR, or Battery Discharge/Test.
6. Enter a setpoint within the displayed limits.
7. Review VIN, current, power, and temperature limits.
8. Press **START** in the web application.
9. Observe live voltage, current, power, temperature, mode, and fault state.
10. Press **STOP** in the web application when the test is complete.
11. Download or retrieve test data when that firmware feature is implemented.

The web UI hides component-level details such as INA180A3, MCP4725, LM358B,
and MOSFET operation. The physical emergency STOP is independent of the web
application and must be used for immediate hazard response. Loss of Wi-Fi
causes the supervisory communication timeout to disable the load; it does not
replace the physical emergency STOP.

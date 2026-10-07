# PLEL R1 PCB DFM and Pre-Fabrication Checklist

| Check | Classification | Required evidence |
|---|---|---|
| DBV/CH/SOIC-8 regulator and amplifier land patterns | PRE-FABRICATION CHECK | Manufacturer drawing and pin-1 review |
| TO-220 body, tab isolation, screw/washer clearance | PRE-FABRICATION CHECK | Mechanical drawing and assembly clearance |
| Shunt Kelvin pads and current path | PRE-FABRICATION CHECK | Layout review and net-class check |
| 2 A trace width and four-via transitions | PRE-FABRICATION CHECK | Stackup, via and voltage-drop calculation |
| Input/output/fan/E-stop/service connector ratings | PRE-FABRICATION CHECK | Selected connector drawings and pinout |
| Fuse footprint and interrupt/current rating | PRE-FABRICATION CHECK | Fuse datasheet and placement review |
| Thermal copper and heatsink keepout | PRE-FABRICATION CHECK | Copper/pour and mechanical drawing review |
| Analog/digital partition and single reference join | PRE-FABRICATION CHECK | Layout review |
| ESP32 antenna keepout | PRE-FABRICATION CHECK | Module drawing, no copper/traces/vias/metal in keepout |
| Programming/service UART access | PRE-FABRICATION CHECK | Header footprint and TX/RX/GND labeling |
| E-stop connector and normally-closed routing | PRE-FABRICATION CHECK | Safety netlist and default-safe bias review |
| Test points | PRE-FABRICATION CHECK | VIN, rails, DAC, sense, gates, NTC, inhibit, fault |
| Polarity and silkscreen safety markings | PRE-FABRICATION CHECK | Gerber/silkscreen review |
| Creepage/clearance at 15 V DC | PRE-FABRICATION CHECK | Fabricator rule review; no mains voltage claim |
| Soldermask, annular ring, drill and fab rules | PRE-FABRICATION CHECK | Fabricator capability review |
| As-built solder quality and component orientation | POST-FABRICATION INSPECTION | Microscope/visual inspection |
| Actual copper, vias, antenna clearance and DFM | POST-FABRICATION INSPECTION | As-built inspection and photographs |

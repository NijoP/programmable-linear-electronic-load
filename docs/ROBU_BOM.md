# Robu.in-Only Prototype Procurement BOM

**Checked:** 2026-10-07 06:06:33 +05:30  
**Allowed supplier:** Robu.in only  
**Catalogue result:** Direct Robu catalogue/search requests returned HTTP 403 Forbidden from the native Windows environment. No product page, SKU, stock or price was visible to the engineering process.

## Procurement status

`ROBU_STATUS = UNCERTAIN` for every search that could not be verified. `UNCERTAIN` is not procurement confirmation and cannot support `PCB_RELEASE = PASS`.

The machine-readable record is `data/robu_procurement.json`. It contains the required value, quantity, search URL, MPN where supported by the source/datasheet, status, price, compatibility and release impact for the complete prototype BOM.

| Group | Required quantity | Robu result | Status |
|---|---:|---|---|
| BUZ11 MOSFET | 4 + 1 spare | Product identity/SOA not visible | UNCERTAIN / BLOCKED |
| 0.01 Ω shunt | 1 | No verified product page | UNCERTAIN / BLOCKED |
| 0.1 Ω ballast | 4 | No verified product page | UNCERTAIN / BLOCKED |
| Gate resistors/pull-downs/zener clamps | 4 each | No verified product page | UNCERTAIN / BLOCKED |
| INA180A3, MCP4725, LM358B | 1 each | Datasheet candidates exist; Robu listing not verified | UNCERTAIN |
| ESP32, regulators, NTC, OLED, encoder | 1 each | Exact module/MPN not verified | UNCERTAIN / BLOCKED |
| Fan, heatsink, fuse/holder, terminals | 1 each / 2 terminals | Thermal/mechanical/product data not verified | UNCERTAIN / BLOCKED |
| Buttons, LEDs and passives | As listed in JSON | Exact package/MPN not verified | UNCERTAIN / BLOCKED |

## Candidate records that must not be silently treated as final selections

- `INA180A3IDBVR`, TI SOT-23-5/DBV.
- `MCP4725A0T-E/CH`, Microchip SOT-23-6/CH.
- `LM358BIDR`, TI SOIC-8/D.

These candidates are supported by the manufacturer datasheets but have no verified Robu product page in this check. They require manual Robu confirmation before ordering.

## Cost

`PRICE NOT VISIBLE`; total cost is therefore not calculated. No price has been fabricated. The PDF planning budget cannot be compared until Robu product pages or an exported Robu cart provide current INR prices.

## Required manual recovery

Open each search URL in `data/robu_procurement.json` from a normal browser session, record the exact Robu product URL/SKU, MPN, package, stock label, displayed INR price and timestamp, then update the JSON. Re-run footprint, thermal and compatibility review after the exact listings are known.

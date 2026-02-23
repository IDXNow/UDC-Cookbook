# EDI 856 to JSON - Advance Ship Notice

*Got a shipping notification that looks like it was written by a mainframe in 1986? This recipe turns EDI 856 ASN documents into clean, nested JSON you can actually read.*

> Converts an X12 EDI 856 Advance Ship Notice into a structured, human-readable JSON document, preserving the hierarchical loop relationships.

## What This Solves

EDI 856 ASN documents are dense, cryptic, and deeply hierarchical - built for machine interchange, not human readability. You shouldn't need to be an EDI expert to know what's in a shipment. This recipe parses the HL loop hierarchy (Shipment → Order → Tare → Pack → Item), maps segment codes and qualifiers to meaningful field names, and gives you a clean nested JSON structure.

Don't know what an HL segment is? That's fine. The model prompt handles the parsing rules - you just bring the file.

## What You'll Get

**Before:** Cryptic segment codes that only an EDI translator could love.

```
ISA*00*          *00*          *ZZ*SENDER123      *ZZ*RECEIVER456    *240115*1030*U*00401*000000001*0*P*>~
GS*SH*SENDER123*RECEIVER456*20240115*1030*1*X*004010~
ST*856*0001~
BSN*00*SH123456*20240115*1030*0001~
...
HL*1**S~
...
HL*2*1*O~
PRF*PO-2024-00123~
...
HL*3*2*I~
LIN**UP*012345678901*VP*SKU-WIDGET-001~
SN1**100*EA~
PID*F****DELUXE WIDGET BLUE 12PK~
CTT*1~
SE*23*0001~
```

**After:** A clear picture of what shipped, where it's going, and what's inside.

```json
{
  "interchange": { "sender_id": "SENDER123", "receiver_id": "RECEIVER456", ... },
  "shipment": {
    "asn_number": "SH123456",
    "shipped_date": "20240115",
    "carrier": { "scac": "UPSN", "tracking_number": "1Z999AA10123456784", "bol_number": "BOL789012" },
    "ship_from": { "name": "ACME WAREHOUSE", "address": { ... } },
    "ship_to": { "name": "RETAIL STORE 42", "address": { ... } }
  },
  "orders": [
    {
      "po_number": "PO-2024-00123",
      "invoice_number": "INV-2024-00567",
      "items": [
        {
          "identifiers": { "upc": "012345678901", "vendor_part": "SKU-WIDGET-001" },
          "description": "DELUXE WIDGET BLUE 12PK",
          "quantity_shipped": 100,
          "uom": "EA"
        }
      ]
    }
  ],
  "totals": { "hl_total_count": 3, "hl_item_count": 1, "segment_count": 23 }
}
```

### Key Mappings

The YAML configuration includes comprehensive mapping tables for:

| EDI Element | Maps To |
|---|---|
| HL level codes (S/O/T/P/I) | JSON hierarchy nesting |
| DTM qualifiers (011, 017, etc.) | Named date fields (shipped_date, estimated_delivery) |
| REF qualifiers (BM, CN, IA, etc.) | Named references (bol_number, tracking_number, invoice_number) |
| N1 qualifiers (SF, ST, BY) | Party objects (ship_from, ship_to, buyer) |
| LIN qualifiers (UP, VP, SK) | Item identifiers (upc, vendor_part, buyer_sku) |

### CTT Totals (X12 Standard)

The recipe correctly handles CTT segment interpretation per X12 856 standards:
- **CTT01** = Count of item-level HL segments only (level code "I"), not all HL segments
- **CTT02** = Hash total (sum of all SN102 shipped quantities)

## How to Run

```bash
# Single files
# Simple sample (1 order, 1 item)
python udc01.py --conversion "conversion/edi856-to-json/edi856_to_json_conv.yaml" \
                --file "conversion/edi856-to-json/edi856_simple.edi"

# Multi-order sample (2 orders, 5 items)
python udc01.py --conversion "conversion/edi856-to-json/edi856_to_json_conv.yaml" \
                --file "conversion/edi856-to-json/edi856_multi_order.edi"

# Folder + search pattern
python udc01.py --conversion "conversion/edi856-to-json/edi856_to_json_conv.yaml" \
                --folder "conversion/edi856-to-json" \
                --pattern "edi856*.edi"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `edi856_to_json_conv.yaml` | UDC01 conversion configuration with full EDI segment mapping tables |
| `edi856_simple.edi` | Simple EDI 856 sample (S → O → I, 1 order, 1 item, CTT without hash) |
| `expected_output_simple.txt` | Expected JSON output for simple sample |
| `edi856_multi_order.edi` | Multi-order EDI 856 sample (S → O → I, 2 orders, 5 items, CTT with hash total) |
| `expected_output_multi_order.txt` | Expected JSON output for multi-order sample |

## Sample Comparison

| | Simple | Multi-Order |
|---|---|---|
| Orders | 1 | 2 |
| Items | 1 | 5 |
| HL segments | 3 (S, O, I) | 8 (S, 2×O, 5×I) |
| CTT hash total | No | Yes (240 = 24+36+48+60+72) |
| Estimated delivery | No | Yes (DTM*017) |
| Lot numbers | No | Yes (REF*LT) |
| Expiration dates | No | Yes (DTM*036) |
| Buyer party | No | Yes (N1*BY) |
| Trailer number | No | Yes (TD3) |
| Contact info | No | Yes (PER) |

## Model Requirements

- A capable model is strongly recommended - EDI parsing requires precise segment/element positional awareness
- The model must understand X12 EDI hierarchical loop structures and parent-child HL references
- Accurate CTT hash total interpretation is critical for validation

## Adapt This Recipe

This example targets the standard 856 ASN structure, but your trading partner's implementation may differ. In the YAML:

- **Add or remove HL loop levels** - Some implementations include Tare (T) and Pack (P) levels; others skip them. Update the mapping tables and prompt instructions to match your specific loop hierarchy
- **Extend the qualifier tables** - Add REF, DTM, N1, and LIN qualifier codes that your trading partners use but aren't in the sample mapping tables
- **Change the JSON structure** - Reshape the output to match the schema your system expects (e.g., flatten nested objects, rename keys, split or combine sections)
- **Apply to other EDI transaction sets** - The same prompt-driven approach works for other X12 transaction sets (810, 850, 855, etc.); update the segment and loop definitions accordingly
- **Add validation rules** - Tighten the validation prompt to cross-check quantities, enforce required segments, or flag missing mandatory data

# ACH/NACHA to JSON - Payroll Payment File

*Got a wall of 94-character fixed-width records with no delimiters, no headers, and no decimal points? This recipe parses NACHA/ACH payment files into clean, enriched JSON - amounts converted, names reformatted, bank names decoded.*

> Converts NACHA/ACH fixed-width payment files (94 characters per record, positional format) into structured JSON with AI-decoded transaction codes, routing number identification, and enriched field descriptions.

## What This Solves

ACH files power virtually every electronic payment in the US banking system - payroll direct deposits, vendor payments, bill pay, consumer debits, and more. But the raw NACHA format is pure positional fixed-width: every field is defined by character position, not delimiters. There are no column names, no decimal points, no separators.

`0000324567` at positions 30–39 of a Type 6 record means $3,245.67. `22` at positions 2–3 means "deposit to checking." `PPD` at positions 51–53 of a Type 5 record means "Prearranged Payment and Deposit." Without the NACHA specification document in hand, none of this is readable.

This recipe parses the file's hierarchical record structure (File Header → Batch Header → Entry Detail → Batch/File Control), decodes every coded field into plain English, converts all amounts from cents to dollars, and produces structured JSON you can actually work with.

## What You'll Get

**Before:** Fixed-width records that require a NACHA specification document to interpret.

```
101 021000021 1234567890250115102501094101JPMORGAN CHASE         ACME CORPORATION
5220ACME CORPORATION    1234567890PPD PAYROLL   Jan 15250115   1021000020000001
62202100002192109876543210     0000324567EMP-10045      JOHNSON MARY           00...
62202600959344455667788     0000412850EMP-10078      WILLIAMS JAMES         00...
8220000006024616236000000000000002124118123456789                         021000020000001
9000001000001000000060246162360000000000000002124118
```

**After:** Clean JSON with decoded fields, converted amounts, and AI-enriched descriptions:

```json
{
  "file_header": {
    "immediate_destination_routing": "021000021",
    "immediate_destination_name": "JPMORGAN CHASE",
    "immediate_origin_name": "ACME CORPORATION",
    "file_creation_date": "2025-01-15",
    "file_creation_time": "10:25"
  },
  "batches": [
    {
      "service_class_code": "220",
      "service_class_description": "Credits Only",
      "company_name": "ACME CORPORATION",
      "sec_code": "PPD",
      "sec_code_description": "Prearranged Payment and Deposit - recurring individual payments such as payroll direct deposits ...",
      "entry_description": "PAYROLL",
      "effective_entry_date": "2025-01-15",
      "originating_bank_name": "JPMorgan Chase",
      "entries": [
        {
          "transaction_code": "22",
          "transaction_description": "Automated Deposit to Checking (Credit)",
          "receiving_bank_name": "JPMorgan Chase",
          "account_number": "9876543210",
          "amount": 3245.67,
          "individual_name_raw": "JOHNSON MARY",
          "individual_name_formatted": "Mary Johnson",
          "has_addenda": false
        }
      ],
      "batch_control": {
        "entry_count": 6,
        "total_debits": 0.00,
        "total_credits": 21241.18
      }
    }
  ],
  "file_summary": {
    "payment_type": "Payroll Direct Deposit",
    "total_entries": 6,
    "total_disbursement": 21241.18,
    "effective_date": "2025-01-15"
  }
}
```

### AI Enrichments

This recipe goes beyond positional parsing - six enrichment types are applied to every file:

| Enriched Field | Source | Description |
|---|---|---|
| `transaction_description` | Transaction code (pos 2–3, Type 6) | Human-readable meaning (e.g., "Automated Deposit to Checking") |
| `service_class_description` | Service class code (pos 2–4, Type 5) | Batch type in plain English (Mixed, Credits Only, Debits Only) |
| `sec_code_description` | SEC code (pos 51–53, Type 5) | Full name and purpose of the Standard Entry Class code |
| `originating_bank_name` | Originating DFI routing number | Financial institution name identified from routing number |
| `receiving_bank_name` | Receiving DFI routing + check digit | Financial institution name (best-effort from routing number) |
| `individual_name_formatted` | Individual name field (pos 55–76, Type 6) | Reformatted from NACHA's LAST FIRST to proper First Last |
| `payment_type` | SEC code + entry description | High-level file categorization (Payroll Direct Deposit, Vendor Payment, etc.) |

### Key Record Types

| Record | Type Code | Purpose |
|---|---|---|
| File Header | 1 | Sending bank, receiving bank, creation date/time |
| Batch Header | 5 | Company name, SEC code, effective date, entry description |
| Entry Detail | 6 | Individual payment: routing, account, amount, name |
| Batch Control | 8 | Entry count, hash total, debit/credit totals |
| File Control | 9 | File-level totals and batch count |

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/ach-to-json/nacha_ach_enrichment_conv.yaml" \
                --file "conversion/ach-to-json/acme_payroll.ach"

# Folder + search pattern
python udc01.py --conversion "conversion/ach-to-json/nacha_ach_enrichment_conv.yaml" \
                --folder "path/to/your/ach-files" \
                --pattern "*.ach"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `nacha_ach_enrichment_conv.yaml` | UDC01 conversion configuration with full NACHA record layout reference and enrichment instructions |
| `acme_payroll.ach` | Sample NACHA file - ACME CORPORATION payroll with 6 employees across 4 banks |
| `expected_output.txt` | Expected enriched JSON output for the sample payroll file |

## Model Requirements

- A capable model is strongly recommended - fixed-width positional parsing requires precise character-counting that smaller models may struggle with
- Routing number → bank name identification requires financial domain knowledge (major US bank routing numbers) embedded in the model
- Works reliably with GPT-4o, Claude Sonnet/Opus, Gemini Pro; local or smaller models may produce off-by-one parsing errors
- Amount conversion from cents to dollars (dividing zero-padded integers by 100) is validated strictly - the validation agent will catch any conversion errors

## Adapt This Recipe

This example processes a payroll direct deposit file, but the same YAML handles any NACHA-compliant ACH file. In the YAML:

- **Apply to vendor payments** - CCD and CTX files use the same record structure; the prompt already handles all common SEC codes (PPD, CCD, CTX, WEB, TEL, and more)
- **Add addenda record parsing** - For CTX files with remittance detail in Type 7 addenda records, extend the prompt to extract invoice numbers, PO references, and payment details from addenda
- **Change the JSON schema** - Reshape the output to match what your ERP, Treasury Management System, or accounting platform expects on import
- **Extend the routing number table** - Add institution names for routing numbers specific to your bank relationships in the enrichment instructions
- **Add business validation rules** - Instruct the validation agent to flag entries exceeding amount thresholds, verify batch totals cross-foot, or catch prenote entries (transaction codes 23, 28, 33, 38) that shouldn't carry dollar amounts

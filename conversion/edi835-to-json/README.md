# EDI 835 to JSON - Healthcare Remittance Advice

*Got an 835 file and no idea what's in it? You're not alone. This recipe turns that wall of cryptic segments into clean, readable JSON - with plain-English explanations of every code, adjustment, and denial.*

> Converts an X12 EDI 835 Healthcare Claim Payment/Advice into structured, enriched JSON with AI-derived descriptions for claim statuses, procedure codes, adjustment reason codes, and follow-up action recommendations.

## What This Solves

EDI 835 remittance files are how insurance payers tell healthcare providers what got paid, what got denied, and why - but the raw format looks like this: `CAS*CO*45*50.00~`. Unless you've memorized CARC reason codes, that means nothing to you.

Don't worry about what ISA segments or CAS group codes are. The model prompt handles the parsing rules and code lookups - you just bring the file.

This is the most complex recipe in the cookbook, and it works on three levels at once:

1. **Format translation** - Parses the EDI segment/element structure (tilde-terminated, asterisk-separated, colon composites) into hierarchical JSON. Fundamentally different from delimited-file conversions.
2. **Code decoding** - Four separate code-to-description lookups embedded in the system prompt: CLP status codes, CPT/HCPCS procedure codes, CAS group codes, and CARC reason codes. The prompt includes common values as a reference table so the LLM doesn't hallucinate descriptions.
3. **Business logic enrichment** - The `follow_up_action` field requires the LLM to synthesize claim status, adjustment types, and reason codes into an actionable recommendation. A CO-45 on a paid claim means "no action," but a PR-2 means "bill patient $100 for coinsurance," and a CO-16 denial means "fix the billing error and resubmit."

## What You'll Get

**Before:** A wall of `ISA*00*...` segments that only an EDI parser could love.

```
ISA*00*          *00*          *ZZ*GREENPAYER      *ZZ*ACMEHEALTH    *250115*1025*^*00501*000000001*0*P*:~
GS*HP*GREENPAYER*ACMEHEALTH*20250115*1025*1*X*005010X221A1~
ST*835*0001~
BPR*I*1075.00*C*ACH*CCP*01*021000089*DA*123456789*...~
TRN*1*GCGS20250115001*1234567890~
...
CLP*PAT1001-20250103*1*250.00*200.00**12*GCGS2025-00412*11*1~
NM1*QC*1*JOHNSON*MARY****MI*XYZ123456~
SVC*HC:99213*250.00*200.00**1~
DTM*472*20250103~
CAS*CO*45*50.00~
...
```

**After:** Clean, nested JSON with every claim, payment, and adjustment in its place - plus plain-English explanations:

```json
{
  "remittance": {
    "payer_name": "GREEN CROSS GREEN SHIELD OF NC",
    "payee_name": "ACME HEALTH SERVICES",
    "payment_amount": 1075.00,
    "payment_method": "ACH",
    "payment_date": "2025-01-15",
    "trace_number": "GCGS20250115001"
  },
  "summary": {
    "total_claims": 3,
    "total_charged": 1800.00,
    "total_paid": 1075.00,
    "total_adjusted": 725.00,
    "claims_paid": 2,
    "claims_denied": 1
  },
  "claims": [
    {
      "claim_id": "PAT1001-20250103",
      "claim_status_code": "1",
      "claim_status_description": "Processed as Primary",
      "patient_name": "MARY JOHNSON",
      "total_charged": 250.00,
      "total_paid": 200.00,
      "service_lines": [
        {
          "procedure_code": "99213",
          "procedure_description": "Office or other outpatient visit, established patient, low to moderate complexity",
          "adjustments": [
            {
              "group_code": "CO",
              "group_description": "Contractual Obligation ...",
              "reason_code": "45",
              "reason_description": "Charge exceeds fee schedule/maximum allowable ..."
            }
          ]
        }
      ],
      "follow_up_action": "No action required -- claim paid per contract terms"
    }
  ]
}
```

### AI Enrichments

This recipe goes beyond structural conversion - five fields are AI-enriched:

| Enriched Field | Source | Description |
|---|---|---|
| `claim_status_description` | CLP status code | Human-readable claim status (e.g., "Processed as Primary", "Denied") |
| `procedure_description` | CPT/HCPCS code | Plain-English description of medical procedure codes |
| `group_description` | CAS group code | Explanation of adjustment group (CO, PR, OA, PI, CR) |
| `reason_description` | CARC reason code | Plain-English explanation of adjustment reason codes |
| `follow_up_action` | Claim outcome | Recommended next step (bill patient, resubmit, appeal, no action) |

### Key Mappings

| EDI Segment | Maps To |
|---|---|
| BPR (payment info) | `remittance.payment_amount`, `payment_method`, `payment_date` |
| TRN (trace number) | `remittance.trace_number` |
| N1*PR / N1*PE | Payer and payee identification |
| CLP (claim payment) | Claim-level IDs, status, charged/paid amounts |
| NM1*QC (patient) | `patient_name`, `patient_member_id` |
| SVC (service line) | Procedure codes, amounts, units |
| CAS (adjustments) | Group codes, reason codes, adjustment amounts |
| DTM*472 (service date) | `service_date` in YYYY-MM-DD format |
| AMT*B6 (allowed amount) | `allowed_amount` |

### Sample Claims

The sample EDI includes 3 claims demonstrating different adjudication outcomes:

| Claim | Patient | Status | Charged | Paid | Key Feature |
|---|---|---|---|---|---|
| PAT1001-20250103 | Mary Johnson | Paid (Primary) | $250.00 | $200.00 | Contractual write-off only (CO-45) |
| PAT1002-20250105 | James Williams | Paid (Primary) | $1,100.00 | $875.00 | Multi-service, patient coinsurance (PR-2) |
| PAT1003-20250108 | Robert Chen | Denied | $450.00 | $0.00 | Billing error denial (CO-16), requires resubmission |

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/edi835-to-json/edi835_to_json_remittance_conv.yaml" \
                --file "conversion/edi835-to-json/edi835_remittance.edi"

# Folder + search pattern
python udc01.py --conversion "conversion/edi835-to-json/edi835_to_json_remittance_conv.yaml" \
                --folder "conversion/edi835-to-json" \
                --pattern "*.edi"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `edi835_to_json_remittance_conv.yaml` | UDC01 conversion configuration with EDI 835 parsing rules and AI enrichment instructions |
| `edi835_remittance.edi` | Sample EDI 835 (3 claims, 4 service lines, mixed paid/denied outcomes) |
| `expected_output.txt` | Expected enriched JSON output |

## Validation Approach

The validation agent is deliberately lenient on enrichment wording - it won't fail over minor differences in AI-generated descriptions as long as the meaning is correct. But it's strict where it matters:

- All monetary amounts must trace exactly to the source EDI segment values
- Summary totals must cross-foot (`total_adjusted` = `total_charged` - `total_paid`)
- Dates must convert accurately from YYYYMMDD to YYYY-MM-DD format
- Claim and service line counts must match the source EDI

## Model Requirements

- **High-end models required** - local/smaller models were unable to reliably convert or validate this recipe in testing. Larger cloud models (GPT-4o, Claude Sonnet/Opus, Gemini Pro) handled it without issue.
- The three-level complexity (format parsing + code decoding + business logic) demands precise segment/element positional awareness, domain-specific code knowledge, and multi-step reasoning simultaneously
- Accurate code decoding requires medical coding knowledge (CPT/HCPCS, CARC codes, CAS group codes) - the prompt provides common values as a reference, but the model must not hallucinate descriptions for unlisted codes
- Follow-up action recommendations require synthesizing multiple data points (claim status + adjustment types + reason codes) into actionable guidance

## Adapt This Recipe

This example covers a typical healthcare remittance scenario, but 835 implementations vary by payer. In the YAML:

- **Extend the code reference tables** - Add CARC codes, CPT/HCPCS codes, or CAS group codes that appear in your payers' files but aren't in the sample prompt
- **Change the follow-up action logic** - Rewrite the business logic instructions to match your practice's workflow (e.g., different thresholds for appeal vs. write-off, different billing rules for patient responsibility)
- **Reshape the JSON output** - Adjust the schema to match what your practice management or billing system expects on import
- **Add payer-specific segments** - Some payers include non-standard segments or loops; extend the parsing instructions in the prompt to handle them
- **Apply to other claim types** - The approach works beyond standard outpatient claims: adjust the procedure code tables and enrichment instructions for dental (CDT codes), vision, or institutional claims

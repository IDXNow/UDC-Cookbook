# JSON to CSV - CRM Contacts

*Got a JSON export from your CRM? This recipe flattens nested contact records into a clean CSV you can open in Excel or import anywhere.*

> Converts a JSON array of CRM contact objects to CSV format, flattening nested address fields and extracting the primary phone number.

## What This Solves

CRM systems export contact data as JSON with nested objects - addresses buried inside an `address` block, phone numbers in an array. This recipe pulls everything flat into a single CSV row per contact, ready for bulk import, reporting, or handoff to a system that doesn't speak JSON.

## Input

JSON array of contact objects with nested `address` and `phones` fields:

```json
[
  {
    "contact_id": "CON-1001",
    "first_name": "Sarah",
    "last_name": "Mitchell",
    "email": "smitchell@acmecorp.com",
    "company": "Acme Corporation",
    "title": "VP of Operations",
    "status": "Customer",
    "created_date": "2024-03-12",
    "address": { "city": "New York", "state": "NY", ... },
    "phones": [{ "type": "work", "number": "212-555-0142" }, ...],
    ...
  }
]
```

## Output

Flat CSV with one row per contact:

```
ContactID,FirstName,LastName,Email,Company,Title,City,State,Phone,Status,CreatedDate
CON-1001,Sarah,Mitchell,smitchell@acmecorp.com,Acme Corporation,VP of Operations,New York,NY,212-555-0142,Customer,2024-03-12
```

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/json-to-csv/crm_contacts_conv.yaml" \
                --file "conversion/json-to-csv/crm_contacts.json"

# Folder + search pattern
python udc01.py --conversion "conversion/json-to-csv/crm_contacts_conv.yaml" \
                --folder "conversion/json-to-csv" \
                --pattern "*.json"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `crm_contacts_conv.yaml` | UDC01 conversion configuration |
| `crm_contacts.json` | Example JSON with 5 contact records |
| `expected_output.csv` | Expected CSV result |

## Model Requirements

- Works with any supported LLM provider (local, OpenAI, Anthropic, Google)
- Straightforward flattening - no special model capabilities required

## Adapt This Recipe

This example uses CRM contacts, but the pattern works for any JSON-to-CSV conversion involving nested objects or arrays. In the YAML:

- **Change the field names** - Update the column list and flattening instructions to match your JSON schema (e.g., `customer.address.city` instead of `address.city`)
- **Select from arrays differently** - Adjust the phone selection rule to pick last, all, or a specific type (e.g., extract all emails from a `contacts` array into separate columns)
- **Add or remove columns** - Trim the output to only the fields your target system needs, or add extra nested fields
- **Rename output fields** - Map source names to whatever your downstream system expects (e.g., `first_name` → `First Name`)
- **Handle missing fields** - The prompt instructs the model to leave empty values for missing fields; adjust the fallback behavior as needed

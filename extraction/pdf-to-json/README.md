# PDF to JSON - Gift Order Document

*Use this recipe to eliminate manual PDF keying and produce structured order data in one repeatable pass.*

> Extracts structured order data from a PDF gift order document and produces a flat JSON object.

## What This Solves

Order and invoice PDFs often force manual transcription, which slows operations and introduces avoidable errors in financial and fulfillment systems.

This recipe extracts vendor details, customer details, line items, totals, and shipping fields into structured JSON so teams can automate ingestion, validation, and reconciliation without retyping documents.

## What You'll Get

**Before:** A PDF sitting in your inbox that someone has to read and retype.

**After:**

```json
{
  "order_number": "WCG-2025-00847",
  "order_date": "...",
  "vendor_name": "...",
  "customer_name": "...",
  "items": [
    { "description": "...", "qty": 1, "unit_price": 29.99, "line_total": 29.99 }
  ],
  "subtotal": 29.99,
  "tax_amount": 2.40,
  "grand_total": 32.39
}
```

Every field extracted, every number accurate, ready to feed into whatever system needs it.

## Input

PDF document containing an order/invoice with vendor info, customer info, line items, and totals.

## How to Run

```bash
# Single file
python udc01.py --conversion "extraction/pdf-to-json/gift_order_pdf_conv.yaml" \
                --file "extraction/pdf-to-json/gift_order_input.pdf"

# Folder + search pattern
python udc01.py --conversion "extraction/pdf-to-json/gift_order_pdf_conv.yaml" \
                --folder "extraction/pdf-to-json" \
                --pattern "*.pdf"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `gift_order_pdf_conv.yaml` | UDC01 conversion configuration |
| `gift_order_input.pdf` | Example PDF order document |

## Model Requirements

- UDC01 requires `pdfplumber` for PDF text extraction (`pip install pdfplumber`)
- Works best with text-based PDFs; scanned documents may need OCR preprocessing
- A capable model is recommended for accurate line-item extraction from PDF layouts

## Adapt This Recipe

This example extracts a gift order document, but it's designed for any repeatable PDF layout with structured content. In the YAML:

- **Change the document type** - Apply the same approach to invoices, purchase orders, contracts, remittance statements, shipping manifests, or any repeating document format your organization receives
- **Redesign the JSON schema** - Define the fields and nested sections that match your document: the model will extract whatever structure you describe
- **Update the extraction instructions** - Describe the layout of your specific document in the prompt (e.g., where header fields appear, how line items are formatted, what totals to look for)
- **Add validation rules** - Instruct the validation agent to cross-check extracted values (e.g., verify line item totals sum to the subtotal, confirm required fields are present)
- **Handle multi-page documents** - For longer documents, adjust the prompt to describe content that spans pages or repeats in consistent patterns


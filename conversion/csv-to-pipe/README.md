# CSV to Pipe-Delimited - Sales Invoice

*Got a CSV that needs to be pipe-delimited? Drop it in, get it back with clean columns and consistent formatting.*

> Converts a CSV sales invoice file to pipe-delimited format with standardized column names.

## What This Solves

Sales invoice data arrives as CSV with varying column names and formats. This recipe standardizes it into a consistent pipe-delimited output with fixed column ordering - ready for whatever system needs it next.

## Input

CSV file with sales invoice records containing fields like Invoice ID, Customer Name, dates, amounts, and payment status.

```
InvoiceID,CustomerName,CustomerID,InvoiceDate,DueDate,...,TotalAmount,PaymentStatus,...
INV-2025-0001,Acme Corporation,CUST001,2025-01-15,2025-02-14,...,1253.62,Paid,...
```

## Output

Pipe-delimited text with standardized columns:

```
InvoiceID|CustomerID|CustomerName|InvoiceDate|DueDate|TotalAmount|PaymentStatus
INV-2025-0001|CUST001|Acme Corporation|2025-01-15|2025-02-14|1253.62|Paid
```

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/csv-to-pipe/sales_invoice_conv.yaml" \
                --file "conversion/csv-to-pipe/sales_invoice.csv"

# Folder + search pattern
python udc01.py --conversion "conversion/csv-to-pipe/sales_invoice_conv.yaml" \
                --folder "conversion/csv-to-pipe" \
                --pattern "*.csv"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `sales_invoice_conv.yaml` | UDC01 conversion configuration |
| `sales_invoice.csv` | Example CSV with 5 invoice records |
| `expected_output.txt` | Expected pipe-delimited result |

## Model Requirements

- Works with any supported LLM provider (local, OpenAI, Anthropic, Google)
- Straightforward format conversion - no special model capabilities required

## Adapt This Recipe

This example uses sales invoices, but the pattern works for any CSV-to-pipe conversion. In the YAML:

- **Change the columns** - Update the field mapping to match your CSV's actual column names and select only the fields your target system needs
- **Rename output fields** - Remap source column names to whatever your downstream system expects (e.g., `CustomerName` → `client_name`)
- **Add derived fields** - Instruct the prompt to compute or format new values (e.g., combine first/last name, reformat a date, flag overdue records)
- **Change the delimiter** - Switch from pipe to tab, semicolon, or any other separator if your target system requires it
- **Filter rows** - Add prompt instructions to exclude certain records (e.g., only include paid invoices, skip zero-amount rows)

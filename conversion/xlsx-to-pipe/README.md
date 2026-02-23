# Excel to Pipe-Delimited - Customer Orders

*Got order data stuck in a spreadsheet? This recipe pulls it out with clean dates, consistent formatting, and standardized columns.*

> Converts an Excel spreadsheet of customer orders to pipe-delimited format with standardized columns and date/number formatting.

## What This Solves

Customer order data lives in Excel spreadsheets with varying column names, inconsistent dates, and messy number formats. This recipe standardizes everything - enforces YYYY-MM-DD dates, normalizes currency to two decimal places, and outputs a clean pipe-delimited file.

## Input

Excel (.xlsx) file with customer order records including order numbers, customer info, product details, quantities, totals, and shipping status.

## Output

Pipe-delimited text with standardized columns:

```
OrderNumber|CustomerID|CustomerName|OrderDate|ProductSKU|ProductDescription|Quantity|OrderTotal|ShippingStatus
ORD-12345|CUST-100|Acme Corporation|2023-01-20|PROD-100|Deluxe Widget|10|299.90|Shipped
```

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/xlsx-to-pipe/customer_order_conv.yaml" \
                --file "conversion/xlsx-to-pipe/customer_order.xlsx"

# Folder + search pattern
python udc01.py --conversion "conversion/xlsx-to-pipe/customer_order_conv.yaml" \
                --folder "conversion/xlsx-to-pipe" \
                --pattern "*.xlsx"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `customer_order_conv.yaml` | UDC01 conversion configuration |
| `customer_order.xlsx` | Example Excel workbook with order records |

## Model Requirements

- Works with any supported LLM provider
- UDC01 reads Excel via `openpyxl` - ensure it's installed (`pip install openpyxl`)

## Adapt This Recipe

This example pulls customer orders from a spreadsheet, but the pattern works for any Excel-to-pipe conversion. In the YAML:

- **Match your column names** - Update the field mapping to reflect the actual headers in your workbook
- **Target a specific sheet** - If your workbook has multiple sheets, add a sheet name instruction to the prompt
- **Change date and number formats** - Adjust formatting rules to match whatever your target system requires (e.g., MM/DD/YYYY instead of YYYY-MM-DD, integers instead of decimals)
- **Drop or add columns** - Include only the fields your downstream system needs; add derived columns if useful
- **Change the output format** - Swap pipe-delimited for CSV, JSON, or another format as needed

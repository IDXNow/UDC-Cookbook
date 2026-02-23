# Transaction Classification — Business Transactions

*`AMZN MKTP US*2K7YR4QT1` — what even is that? This recipe reads your bank transactions and tells you: it's Amazon, it's office supplies, and yes, it's tax-deductible.*

> Converts bank transaction data from CSV to pipe-delimited format while enriching each record with AI-derived accounting classifications, tax deductibility flags, and vendor identification.

## What This Solves

Bank transaction descriptions are cryptic shorthand that doesn't tell your accountant much. Manually classifying transactions for bookkeeping, tax prep, and financial reporting is tedious and error-prone. This recipe reads your raw bank export and enriches each transaction with accounting-ready classifications — category, subcategory, tax deductibility, and a clean vendor name.

## Input

CSV file with bank transactions including the raw merchant description, amount, and debit/credit indicator.

```
TransactionID,AccountName,TransactionDate,Description,Amount,DebitCredit
TXN-90001,Acme Corporation,2025-01-03,AMZN MKTP US*2K7YR4QT1 AMZN.COM/BILL WA,-247.83,Debit
TXN-90003,Acme Corporation,2025-01-06,GUSTO PAY 250106 GUSTO.COM PAYROLL,-34520.75,Debit
TXN-90012,Acme Corporation,2025-01-20,INTERNAL REVENUE SVC USATAXPYMT 250120,-4200.00,Debit
```

## Output

Pipe-delimited text with all original fields plus four enrichment columns:

```
TransactionID|AccountName|TransactionDate|Description|Amount|DebitCredit|Category|Subcategory|TaxDeductible|VendorName
TXN-90001|Acme Corporation|2025-01-03|AMZN MKTP US*2K7YR4QT1 AMZN.COM/BILL WA|247.83|Debit|Office Supplies|General Supplies|Yes|Amazon
TXN-90003|Acme Corporation|2025-01-06|GUSTO PAY 250106 GUSTO.COM PAYROLL|34520.75|Debit|Payroll|Salaries and Wages|Yes|Gusto
TXN-90012|Acme Corporation|2025-01-20|INTERNAL REVENUE SVC USATAXPYMT 250120|4200.00|Debit|Taxes|Federal Income Tax|No|IRS
```

### Enrichment Fields

| Field | Description | Example Values |
|---|---|---|
| Category | High-level expense/revenue category | Office Supplies, Payroll, Travel, Utilities, Software, Taxes, Revenue, Insurance, Transfer, Professional Services |
| Subcategory | Specific classification within category | General Supplies, Airfare, Lodging, SaaS Subscription, Electric, Customer Payment, Federal Income Tax |
| TaxDeductible | Whether the expense is typically deductible | Yes, No |
| VendorName | Cleaned, human-readable vendor name extracted from the raw description | Amazon, United Airlines, Duke Energy, IRS |

## How to Run

```bash
# Single file
python udc01.py --conversion "enrichment/transaction-classification/business_transaction_categorize_conv.yaml" \
                --file "enrichment/transaction-classification/business_transactions_input.csv"

# Folder + search pattern
python udc01.py --conversion "enrichment/transaction-classification/business_transaction_categorize_conv.yaml" \
                --folder "enrichment/transaction-classification" \
                --pattern "*.csv"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `business_transaction_categorize_conv.yaml` | UDC01 conversion configuration |
| `business_transactions_input.csv` | 12 bank transactions with cryptic merchant descriptions |
| `expected_output.txt` | Expected pipe-delimited result with enrichment fields |

## Model Requirements

- A capable model is recommended for accurately interpreting cryptic bank transaction descriptions
- The model must recognize vendor abbreviations and merchant codes (e.g., `AMZN MKTP` → Amazon, `GUSTO PAY` → Gusto payroll)
- Tax deductibility determination requires general US business tax knowledge

## Use Cases

This recipe demonstrates value for:
- **Bookkeeping automation** — Classify transactions for import into accounting software (QuickBooks, Xero, etc.)
- **Tax preparation** — Flag deductible expenses and categorize by tax schedule
- **Expense reporting** — Auto-categorize corporate card transactions
- **Financial analysis** — Generate spend-by-category breakdowns without manual tagging

## Adapt This Recipe

This example uses a US business expense taxonomy, but your chart of accounts and rules will differ. In the YAML:

- **Define your own category taxonomy** — Replace the generic categories with your actual chart of accounts, cost center codes, or expense policy categories
- **Add a GL account field** — Extend the output with a `GLAccount` or `AccountCode` field and instruct the prompt to map each transaction to your specific general ledger codes
- **Adjust tax deductibility rules** — Update the prompt for your jurisdiction and entity type (e.g., non-US tax rules, nonprofit expense policies, industry-specific deductions)
- **Handle personal vs. business split** — For mixed-use accounts, add a `BusinessUsePercent` field and instruct the model to estimate the business portion
- **Apply to other transaction sources** — The same pattern works for credit card exports, expense reports, procurement system data, or any feed with raw merchant descriptions that need classification

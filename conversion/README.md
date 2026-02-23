# Conversion Recipes

**Whatever format your data is stuck in, there's a recipe to get it out.** Format A -> Format B - clean structural mapping, no guesswork.

These recipes handle direct format transformations - taking data in one structure and converting it to another. From simple CSV-to-pipe conversions to full EDI parsing, just point it at your file and go.

Use each recipe as a baseline pattern. You are expected to customize field mappings, output structure, and validation details for your own source systems and downstream requirements.
## Recipes

| Recipe | Input | Output | Description |
|---|---|---|---|
| [csv-to-pipe/](csv-to-pipe/) | CSV | Pipe-delimited | Sales invoice data with standardized columns |
| [xml-to-pipe/](xml-to-pipe/) | XML | Pipe-delimited | Product inventory from nested XML hierarchy |
| [xlsx-to-pipe/](xlsx-to-pipe/) | Excel (.xlsx) | Pipe-delimited | Customer orders with date/number formatting |
| [html-to-csv/](html-to-csv/) | HTML | CSV | Job listing extraction from web page markup |
| [edi856-to-json/](edi856-to-json/) | EDI X12 856 | JSON | Advance Ship Notice with hierarchical loop parsing |
| [edi835-to-json/](edi835-to-json/) | EDI X12 835 | JSON | Healthcare Remittance Advice with AI-enriched code descriptions |
| [ach-to-json/](ach-to-json/) | ACH/NACHA | JSON | Fixed-width payment file with decoded transaction codes and bank identification |
| [json-to-csv/](json-to-csv/) | JSON | CSV | CRM contacts with nested address and phone array flattening |

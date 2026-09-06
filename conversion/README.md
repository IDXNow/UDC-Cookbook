# Conversion Recipes

This category exists for direct format-to-format transformations where structure matters more than domain enrichment. We use these patterns when teams need reliable shape conversion that feeds downstream systems with minimal manual cleanup.

These recipes turn data from one format into another, from straightforward CSV-to-pipe mappings to complex EDI parsing. Each recipe is designed to be runnable as-is and then customized to match your field mappings and target schema.

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
| [math-to-latex/](math-to-latex/) | Text (ASCII math) | LaTeX | Plain math notation to render-ready LaTeX |
| [math-to-mathml/](math-to-mathml/) | Text (ASCII math) | MathML | Plain math notation to Presentation MathML |

# Enrichment Recipes

**Don't just convert your data - understand it.** These recipes convert and augment records with AI insight in a single step.

They go beyond format conversion - the LLM reads your data, adds intelligence (sentiment scores, categories, classifications, routing recommendations), and gives you back something more valuable than what you started with.

These are starter enrichment patterns. Tune categories, scoring logic, output fields, and prompt instructions so the transformation aligns with your operational and domain-specific needs.
## Recipes

| Recipe | Input | Output | Description |
|---|---|---|---|
| [sentiment-analysis/](sentiment-analysis/) | CSV | Pipe-delimited | Customer reviews enriched with sentiment, score, topics, and urgency |
| [ticket-categorization/](ticket-categorization/) | CSV | Pipe-delimited | Support tickets enriched with category, priority, routing, and emotion |
| [transaction-classification/](transaction-classification/) | CSV | Pipe-delimited | Bank transactions enriched with category, tax deductibility, vendor, and GL code |

## Common Use Cases

- Sentiment analysis on customer feedback during ingestion
- Auto-categorization and routing of support tickets
- Classification of bank transactions for bookkeeping and tax prep

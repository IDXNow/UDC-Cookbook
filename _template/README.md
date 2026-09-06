# Recipe Name

> Brief one-line description of what this recipe does.

## Problem

What conversion or transformation does this solve?

## Input

Describe the source data format and structure. Example:

```
(paste a snippet of sample input here)
```

## Output

Describe the expected result. Example:

```
(paste a snippet of expected output here)
```

## How to Run

```bash
# Command to execute this recipe
```

## Model Requirements

- Model: (e.g., any provider, or a named tier such as GPT-5.x / Claude 5 / Gemini 3.x if the recipe needs one)
- Config notes: (any special configuration needed - `reasoning_effort`, `max_tokens` headroom, dependencies like `pdfplumber`)
- Runtime keys: (note here if the recipe sets `verification: {enabled: false}` or `include_prior_output_on_retry: true`, and why)

## Adapt This Recipe

This recipe is a starting point. Open the YAML configuration and adjust it to match your own data:

- **Input fields** — Update field names and descriptions to reflect your actual source data
- **Output fields** — Add, remove, or rename output columns to match your target system
- **Prompt instructions** — Rewrite the conversion and validation prompts to describe your specific transformation logic
- **Validation rules** — Tighten or relax the validation criteria to match your data quality requirements
- **Format** — Change the output format (pipe, CSV, JSON, etc.) to whatever your downstream system expects

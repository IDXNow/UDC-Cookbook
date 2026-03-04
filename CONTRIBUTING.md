# Contributing to UDC-Cookbook

This guide explains how we add recipes in a way that stays easy to run, easy to review, and easy to maintain. The goal is simple: anyone on the team should be able to open a folder, understand the pattern, and trust the sample output.

## Adding a New Recipe

1. Copy the `_template/` folder into the appropriate category directory.
2. Rename the folder to describe the conversion (for example, `csv-to-pipe`, `resume-to-json`).
3. Replace the template files with your actual YAML, sample input, and expected output.
4. Fill in the recipe's `README.md` following the template structure.

We use this flow because it keeps every recipe self-contained and consistent across categories.

## Recipe Folder Structure

Every recipe folder should contain:

```
recipe-name/
├── README.md              # What it does, sample usage, model requirements
├── <recipe>.yaml          # The UDC01 conversion YAML
├── sample_input.*         # Example input file
└── expected_output.*      # Expected conversion result
```

This structure makes review faster and prevents hidden dependencies between recipes.

## README Template

The recipe README should cover:

- **Problem** - What conversion or transformation does this solve?
- **Input** - What the source data looks like (format, structure)
- **Output** - What the result looks like
- **How to Run** - The command to execute the recipe
- **Model Requirements** - Any specific model or configuration notes

These sections exist so both implementers and stakeholders can quickly see what the recipe does, why it matters, and how to run it.

## Adding a New Category

If the recipe does not fit an existing category:

1. Create a new top-level folder with a lowercase, hyphenated name.
2. Add a `README.md` explaining the category's purpose and listing its recipes.
3. Update the root `README.md` category table.

We keep categories intentional so the cookbook stays navigable as it grows.

## Conventions

- Use lowercase, hyphenated folder names (for example, `edi-x12-856-to-json`).
- Keep recipes self-contained with no cross-folder dependencies.

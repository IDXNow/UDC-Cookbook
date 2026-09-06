# Contributing to UDC-Cookbook

This guide explains how we add recipes in a way that stays easy to run, easy to review, and easy to maintain. The goal is simple: anyone on the team should be able to open a folder, understand the pattern, and trust the sample output.

## Adding a New Recipe

1. Copy the `_template/` folder into the appropriate category directory.
2. Rename the folder to describe the conversion (for example, `csv-to-pipe`, `resume-to-json`).
3. Fill in `conversion.yaml` and rename it to match your recipe, then add your sample input and expected output.
4. Fill in the recipe's `README.md` following the template structure.
5. Add an entry to the root [recipes.yaml](recipes.yaml) catalog, and a row to the category `README.md` and the root README's All Recipes table.

We use this flow because it keeps every recipe self-contained and consistent across categories.

**Starting from scratch?**  UDC01 ships with **UDC-Studio**, a Streamlit app that profiles a sample file and generates a first-draft conversion YAML.  It gets you past the blank page; the prompt engineering that makes a recipe reliable still happens by hand afterward.  See the [UDC-Studio Guide](https://github.com/IDXNow/UDC01/blob/main/UDC-STUDIO.md).

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
- Two optional top-level YAML keys let a recipe carry its own runtime behavior: `verification: {enabled: false}` to skip pre-conversion verification when input quality is guaranteed, and `include_prior_output_on_retry: true` to feed a rejected output back into the next attempt.

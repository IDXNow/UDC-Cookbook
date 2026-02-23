# Contributing to UDC-Cookbook

## Adding a New Recipe

1. Copy the `_template/` folder into the appropriate category directory
2. Rename the folder to describe the conversion (e.g., `csv-to-pipe`, `resume-to-json`)
3. Replace the template files with your actual YAML, sample input, and expected output
4. Fill in the recipe's `README.md` following the template structure

## Recipe Folder Structure

Every recipe folder should contain:

```
recipe-name/
├── README.md              # What it does, sample usage, model requirements
├── <recipe>.yaml          # The UDC01 conversion YAML
├── sample_input.*         # Example input file
└── expected_output.*      # Expected conversion result
```

## README Template

The recipe README should cover:

- **Problem** - What conversion or transformation does this solve?
- **Input** - What the source data looks like (format, structure)
- **Output** - What the result looks like
- **How to Run** - The command to execute the recipe
- **Model Requirements** - Any specific model or configuration notes

## Adding a New Category

If the recipe doesn't fit an existing category:

1. Create a new top-level folder with a lowercase, hyphenated name
2. Add a `README.md` explaining the category's purpose and listing its recipes
3. Update the root `README.md` category table

## Conventions

- Use lowercase, hyphenated folder names (e.g., `edi-x12-856-to-json`)
- Keep recipes self-contained - no cross-folder dependencies

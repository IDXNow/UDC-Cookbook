# HTML to JSON - Real Estate Listing

*Got a property listing scattered across an HTML page? This recipe pulls every detail - price, features, agent info, photos - into one clean JSON object.*

> Extracts structured property data from an HTML real estate listing page and produces a hierarchical JSON object.

## What This Solves

Real estate listings are published as rich HTML pages with property details, agent info, media references, and company data scattered across the markup. Getting that data into a structured format usually means manual copy-paste or a custom scraper. This recipe extracts everything into a well-organized JSON structure with nested objects for address, features, taxes, and more.

## Input

HTML file containing a full property listing page with details like price, bedrooms/bathrooms, square footage, features, agent contact info, and image gallery.

```html
<h1 class="property-title">Luxury Waterfront Estate</h1>
<p class="property-address">1234 Lakeview Drive, Crystal Lake, MI 49815</p>
<div class="property-price">$3,850,000</div>
```

## Output

Structured JSON with main sections:

```json
{
  "property": {
    "id": "CL154782",
    "title": "Luxury Waterfront Estate",
    "address": { "street": "1234 Lakeview Drive", "city": "Crystal Lake", ... },
    "price": 3850000,
    "bedrooms": 5,
    ...
  },
  "agent": { "name": "Elizabeth Chen", ... },
  "media": { "images": [...], "virtualTour": "..." },
  "company": { "name": "Lakeside Realty", ... }
}
```

## How to Run

```bash
# Single file
python udc01.py --conversion "extraction/html-to-json/real_estate_listing_conv.yaml" \
                --file "extraction/html-to-json/real_estate_listing.html"

# Folder + search pattern
python udc01.py --conversion "extraction/html-to-json/real_estate_listing_conv.yaml" \
                --folder "extraction/html-to-json" \
                --pattern "*.html"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `real_estate_listing_conv.yaml` | UDC01 conversion configuration |
| `real_estate_listing.html` | Example HTML real estate listing page |

## Model Requirements

- Recommended: a capable model for accurate extraction of deeply nested property details
- Model must interpret complex HTML layouts and produce valid, well-structured JSON

## Adapt This Recipe

This example extracts real estate listings, but the pattern works for any HTML page where you need richly structured JSON output. In the YAML:

- **Change the target page type** - Apply the same approach to product pages, restaurant menus, event listings, company profiles, or any other content-rich HTML
- **Redesign the JSON schema** - Define the top-level objects, nested sections, and field names that match your use case - the model will populate whatever structure you specify
- **Guide the extraction logic** - Update the prompt to describe which HTML elements contain which data, especially for pages with non-obvious or inconsistent markup
- **Add or remove sections** - Include only the objects your system needs; add new nested sections (e.g., reviews, specifications, availability) that aren't in the sample schema
- **Handle multiple records** - If a page contains a list of items rather than a single detailed record, adjust the prompt to produce a JSON array instead

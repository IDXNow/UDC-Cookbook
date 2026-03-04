# HTML to JSON - Real Estate Listing

*We use this recipe when rich listing pages need to become structured JSON for analytics, search, or downstream APIs.*

> Extracts structured property data from an HTML real estate listing page and produces a hierarchical JSON object.

## What This Solves

Real estate listings usually spread critical details across many HTML elements, which makes manual extraction slow and brittle.  This recipe maps those details into a nested JSON contract so valuation workflows, listing syndication, and reporting can run on consistent structured data.

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

This example extracts real estate listings, but we designed the pattern for any content-rich HTML page that needs structured JSON output. In the YAML:

- **Change the target page type** - Apply the same approach to product pages, restaurant menus, event listings, company profiles, or any other content-rich HTML
- **Redesign the JSON schema** - Define the top-level objects, nested sections, and field names that match your use case - the model will populate whatever structure you specify
- **Guide the extraction logic** - Update the prompt to describe which HTML elements contain which data, especially for pages with non-obvious or inconsistent markup
- **Add or remove sections** - Include only the objects your system needs; add new nested sections (e.g., reviews, specifications, availability) that aren't in the sample schema
- **Handle multiple records** - If a page contains a list of items rather than a single detailed record, adjust the prompt to produce a JSON array instead


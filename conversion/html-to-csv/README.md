# HTML to CSV - Job Listings

*Got job listings on a web page with no export button? This recipe scrapes the HTML and gives you a clean CSV.*

> Extracts structured job listing data from an HTML page and converts it to CSV format.

## What This Solves

Job listings are published as HTML web pages with semantic markup but no machine-readable export. You need the data in a spreadsheet, not a browser. This recipe parses the HTML structure and produces a clean CSV with standardized fields.

## Input

HTML file containing a job listing page with details like title, department, location, required skills, and company info embedded in various HTML elements.

```html
<h1 class="job-title">Senior Data Engineer</h1>
<span class="job-department">Engineering</span>
<span class="job-location">San Francisco, CA (Hybrid)</span>
<span class="job-id">Job ID: NX-ENG-2025-042</span>
```

## Output

CSV with standardized columns:

```
JobID,Title,Department,Location,WorkArrangement,CompanyName,PostedDate,RequiredExperience,EducationLevel,Skills
NX-ENG-2025-042,Senior Data Engineer,Engineering,"San Francisco, CA",Hybrid,NexusAI Technologies,2025-01-28,5+ years,Bachelor's,"Python;SQL;AWS;Spark;Airflow;ETL;Data Warehousing;Kafka;Docker;Git;Terraform;CI/CD"
```

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/html-to-csv/job_listing_conv.yaml" \
                --file "conversion/html-to-csv/job_listings.html"

# Folder + search pattern
python udc01.py --conversion "conversion/html-to-csv/job_listing_conv.yaml" \
                --folder "conversion/html-to-csv" \
                --pattern "*.html"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `job_listing_conv.yaml` | UDC01 conversion configuration |
| `job_listings.html` | Example HTML job listing page |

## Model Requirements

- Works with any supported LLM provider
- Model must interpret HTML semantic structure to extract relevant fields

## Adapt This Recipe

This example extracts job listings, but the pattern applies to any HTML page with repeated structured content. In the YAML:

- **Change the target content** - Point the prompt at a different page type: product listings, event schedules, restaurant menus, directory entries, news articles
- **Update the output fields** - Define the columns that match what your page actually contains and what your system needs
- **Describe your HTML structure** - Update the prompt to describe how your page organizes its content (CSS class names, element hierarchy, data attributes)
- **Change the output format** - Switch from CSV to pipe-delimited or JSON if that's what your downstream system requires
- **Handle multiple records per page** - If the page lists many items, clarify in the prompt how to identify and separate each record

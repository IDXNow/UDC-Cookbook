# Sentiment Analysis - Customer Reviews

*Your customers are telling you exactly what they think. This recipe converts their reviews and tells you what they actually mean - sentiment, key topics, and who needs attention right now.*

> Converts customer review data from CSV to pipe-delimited format while enriching each record with AI-derived sentiment analysis fields.

## What This Solves

Customer reviews are full of valuable signal buried in free text. A 3-star review that says "love the product but shipping was a disaster" tells you something a star rating alone never will. This recipe doesn't just convert your data - it reads every review and adds four AI-generated fields: overall sentiment, a numeric confidence score, the key topics mentioned, and an urgency flag for customer service routing.

You get a converted file *and* actionable intelligence in one step.

## What You'll Get

**Before:** Raw CSV reviews - you'd have to read each one to know what's going on.

```
ReviewID,CustomerName,ProductName,Rating,ReviewDate,ReviewText
REV-1001,Maria Santos,Ultra HD Smart Television,5,2025-01-15,"Absolutely love this TV! The picture quality is stunning..."
REV-1004,Robert Huang,Smart Refrigerator,1,2025-01-22,"The touchscreen stopped working after three days..."
```

**After:** Every review scored, tagged, and triaged - ready for your team to act on.

```
ReviewID|CustomerName|ProductName|Rating|ReviewDate|Sentiment|SentimentScore|KeyTopics|Urgency
REV-1001|Maria Santos|Ultra HD Smart Television|5|2025-01-15|Positive|0.95|picture quality;smart features;voice control;easy setup|Low
REV-1004|Robert Huang|Smart Refrigerator|1|2025-01-22|Negative|0.05|touchscreen failure;ice maker leak;floor damage;refund request|Critical
```

### Enrichment Fields

| Field | Description | Values |
|---|---|---|
| Sentiment | Overall sentiment classification | Positive, Neutral, Negative |
| SentimentScore | Confidence score from 0.0 (most negative) to 1.0 (most positive) | 0.00–1.00 |
| KeyTopics | Semicolon-separated list of key themes mentioned | Free-form extracted topics |
| Urgency | Customer service routing priority | Critical, High, Medium, Low |

## How to Run

```bash
# Single file
python udc01.py --conversion "enrichment/sentiment-analysis/product_review_sentiment_conv.yaml" \
                --file "enrichment/sentiment-analysis/product_reviews_input.csv"

# Folder + search pattern
python udc01.py --conversion "enrichment/sentiment-analysis/product_review_sentiment_conv.yaml" \
                --folder "enrichment/sentiment-analysis" \
                --pattern "*.csv"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `product_review_sentiment_conv.yaml` | UDC01 conversion configuration |
| `product_reviews_input.csv` | 10 customer reviews across 5 products with varied sentiment |
| `expected_output.txt` | Expected pipe-delimited result with enrichment fields |

## Model Requirements

- A capable model is recommended for accurate sentiment analysis and topic extraction
- The model must interpret review text semantically - not just rely on star ratings
- Note: SentimentScore should reflect the text content, which may differ from the numeric Rating

## Adapt This Recipe

This example analyzes product reviews, but the pattern applies to any free-text feedback. In the YAML:

- **Change the input source** - Apply the same approach to survey responses, NPS comments, social media mentions, support email text, or app store reviews
- **Redefine the sentiment scale** - Change from three-level (Positive/Neutral/Negative) to a five-point scale, a numeric-only score, or a domain-specific classification (e.g., Satisfied/Dissatisfied/Mixed)
- **Change the urgency logic** - Update the prompt to flag urgency based on your specific criteria (e.g., escalate anything mentioning a refund, safety issue, or competitor)
- **Add or replace enrichment fields** - Swap KeyTopics for product-specific tags, add a `FollowUpRequired` flag, include a `RecommendedAction` field, or extract the specific product feature being praised or criticized
- **Change the output format** - Switch from pipe-delimited to JSON or CSV, or restructure the fields to match what your CRM or analytics platform expects on import

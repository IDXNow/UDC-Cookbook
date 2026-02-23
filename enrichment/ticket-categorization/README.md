# Ticket Categorization - Support Tickets

*Your support inbox shouldn't be a bottleneck. This recipe reads every ticket, figures out what it's about, how urgent it is, and routes it to the right team - automatically.*

> Converts support ticket data from CSV to pipe-delimited format while enriching each record with AI-derived categorization, priority, routing, and emotion fields.

## What This Solves

Support tickets arrive as unstructured text with a subject line and a free-form description. Someone has to read each one, decide what category it falls into, gauge the urgency, figure out which team should handle it, and route it - over and over, all day long. That's slow, inconsistent, and burns out your best people.

This recipe does the triage for you. It preserves the original ticket metadata and adds five AI-generated fields so each ticket arrives pre-categorized, prioritized, and routed to the right department. Your team can skip the sorting and jump straight to solving.

## What You'll Get

**Before:** A pile of tickets that someone has to read and manually sort.

```
TicketID,CustomerName,CustomerEmail,SubmittedDate,Subject,Description
TKT-4001,Rachel Foster,rfoster@acmecorp.com,2025-02-01,Cannot log into my account,"I've been trying to log in since yesterday morning..."
TKT-4006,Michael Torres,mtorres@acmecorp.com,2025-02-06,API returning 500 errors intermittently,"Our integration has been failing with 500 Internal Server Error..."
```

**After:** Every ticket categorized, prioritized, and routed - ready for your team to act on immediately.

```
TicketID|CustomerName|CustomerEmail|SubmittedDate|Subject|Category|Subcategory|Priority|DepartmentRouting|CustomerEmotion
TKT-4001|Rachel Foster|rfoster@acmecorp.com|2025-02-01|Cannot log into my account|Technical|Authentication|High|Technical Support|Frustrated
TKT-4006|Michael Torres|mtorres@acmecorp.com|2025-02-06|API returning 500 errors intermittently|Technical|API Issue|Critical|Engineering|Concerned
```

### Enrichment Fields

| Field | Description | Values |
|---|---|---|
| Category | High-level ticket classification | Technical, Billing, Account, Inquiry |
| Subcategory | Specific issue type within the category | Authentication, Invoice Dispute, Application Bug, Feature Question, etc. |
| Priority | Triage priority based on impact and urgency | Critical, High, Medium, Low |
| DepartmentRouting | Recommended team to handle the ticket | Engineering, Technical Support, Billing, Account Management, Customer Success, Legal |
| CustomerEmotion | Detected emotional tone of the customer | Frustrated, Angry, Concerned, Neutral |

## How to Run

```bash
# Single file
python udc01.py --conversion "enrichment/ticket-categorization/support_ticket_triage_conv.yaml" \
                --file "enrichment/ticket-categorization/support_tickets_input.csv"

# Folder + search pattern
python udc01.py --conversion "enrichment/ticket-categorization/support_ticket_triage_conv.yaml" \
                --folder "enrichment/ticket-categorization" \
                --pattern "*.csv"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `support_ticket_triage_conv.yaml` | UDC01 conversion configuration |
| `support_tickets_input.csv` | 12 support tickets across varied categories and severity |
| `expected_output.txt` | Expected pipe-delimited result with enrichment fields |

## Model Requirements

- A capable model is recommended for accurate multi-label classification and emotion detection
- The model must interpret both the subject and description to determine appropriate categorization
- Priority should consider business impact signals (e.g., "production", "blocking", "deadline") not just tone

## Adapt This Recipe

This example uses generic support categories, but your team's taxonomy is probably more specific. In the YAML:

- **Define your own categories and subcategories** - Replace the generic categories (Technical, Billing, Account, Inquiry) with the classifications your team actually uses for reporting and routing
- **Update department routing** - Change the routing targets to match your actual team names, queues, or ticketing system values
- **Adjust priority logic** - Update the prompt to define what "Critical" and "High" mean in your context (e.g., revenue impact thresholds, SLA tiers, affected user count)
- **Add or replace enrichment fields** - Add fields like `EstimatedResolutionTime`, `RelatedProduct`, `SLABreach`, or `RequiresManagerApproval` based on your workflow needs
- **Apply to other intake formats** - The same pattern works for HR requests, facilities tickets, change requests, or any structured text where classification and routing are needed

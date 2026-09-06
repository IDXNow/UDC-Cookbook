# SQL View Transform - Add Customer Name Join

*Got a set of views that expose customer_no but not the name?  This recipe rewrites each one to pull customer_name in from your dimension table - across as many views as you have, in one batch run.*

> Transforms SQL CREATE VIEW statements by inserting `c.customer_name` into the SELECT list and appending an INNER JOIN to `d_customer` on `customer_no`.

## What This Solves

Views built on transactional tables often carry `customer_no` as a foreign key but no readable name - because the name lives in a dimension table.  Updating each view by hand is repetitive and error-prone.  This recipe applies the same structural change to every view file in a folder, consistently, without touching anything else in the SQL.

## Input

SQL CREATE VIEW statement with `customer_no` in the SELECT list:

```sql
CREATE VIEW v_customer_orders AS
SELECT
    o.order_id,
    o.customer_no,
    o.order_date,
    o.order_status,
    o.total_amount
FROM orders o;
```

## Output

Same view with `c.customer_name` added after `customer_no` and the join appended:

```sql
CREATE VIEW v_customer_orders AS
SELECT
    o.order_id,
    o.customer_no,
    c.customer_name,
    o.order_date,
    o.order_status,
    o.total_amount
FROM orders o
INNER JOIN d_customer c ON o.customer_no = c.customer_no;
```

## How to Run

### Single file

```bash
python udc01.py --conversion "code-transform/sql-view-customer-join/add_customer_join_conv.yaml" \
                --file "code-transform/sql-view-customer-join/v_customer_orders.sql"
```

### Batch — all views in a folder

Process all three view files in one run using `--folder` and `--pattern`:

```bash
python udc01.py --conversion "code-transform/sql-view-customer-join/add_customer_join_conv.yaml" \
                --folder "code-transform/sql-view-customer-join" \
                --pattern "v_*.sql"
```

The `v_*.sql` pattern targets only the input view files and skips the expected output files. To run against your own views, point `--folder` at the directory containing your `.sql` files and adjust `--pattern` as needed.

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

## Files

| File | Description |
|---|---|
| `add_customer_join_conv.yaml` | UDC01 transformation configuration |
| `v_customer_orders.sql` | Input view — order records with customer_no |
| `v_customer_invoices.sql` | Input view — invoice records with customer_no |
| `v_customer_shipments.sql` | Input view — shipment records with customer_no |
| `expected_v_customer_orders.sql` | Expected output for orders view |
| `expected_v_customer_invoices.sql` | Expected output for invoices view |
| `expected_v_customer_shipments.sql` | Expected output for shipments view |

## Model Requirements

- Works with any supported LLM provider (local, OpenAI, Anthropic, Google)
- Structural SQL rewriting — no special model capabilities required

## Pre-Conversion Verification Is Off

This is the one cookbook recipe that ships with UDC01's pre-conversion verification disabled:

```yaml
verification:
  enabled: false
```

The input is machine-generated `CREATE VIEW` DDL from a controlled source, so its shape is guaranteed before the run starts. Verifying it would cost up to three extra agent calls per file and catch nothing. Post-conversion validation still runs with the full 2/3 consensus — the output is what needs checking here, not the input.

If you point this recipe at hand-written or untrusted SQL, delete the block (or set `enabled: true`). The `data_verification_system_msg` and `data_verification_request_msg` fields are still present in the YAML, so verification comes straight back with that one-line change.

## Adapt This Recipe

This example joins to `d_customer` on `customer_no`, but the pattern applies to any repeating structural change across SQL files. In the YAML:

- **Change the dimension table** — Replace `d_customer` with your own lookup table (e.g., `d_product`, `d_location`)
- **Change the join key** — Update `customer_no` to whatever foreign key your views carry (e.g., `product_id`, `store_code`)
- **Change the added field** — Replace `c.customer_name` with any field from the dimension table, or add multiple fields
- **Use a LEFT JOIN instead** — Swap `INNER JOIN` for `LEFT JOIN` if some views may have no matching dimension record
- **Target a different file pattern** — Adjust `--pattern` to match your naming convention (e.g., `rpt_*.sql`, `vw_*.sql`)

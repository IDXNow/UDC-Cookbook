CREATE VIEW v_customer_invoices AS
SELECT
    i.invoice_id,
    i.customer_no,
    c.customer_name,
    i.invoice_date,
    i.due_date,
    i.invoice_amount,
    i.payment_status
FROM invoices i
INNER JOIN d_customer c ON i.customer_no = c.customer_no;

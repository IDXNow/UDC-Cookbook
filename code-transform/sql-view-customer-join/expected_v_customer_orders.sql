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

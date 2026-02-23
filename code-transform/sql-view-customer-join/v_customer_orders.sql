CREATE VIEW v_customer_orders AS
SELECT
    o.order_id,
    o.customer_no,
    o.order_date,
    o.order_status,
    o.total_amount
FROM orders o;

CREATE VIEW v_customer_shipments AS
SELECT
    s.shipment_id,
    s.customer_no,
    c.customer_name,
    s.ship_date,
    s.carrier,
    s.tracking_no,
    s.delivery_status
FROM shipments s
INNER JOIN d_customer c ON s.customer_no = c.customer_no;

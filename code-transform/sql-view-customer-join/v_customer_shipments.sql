CREATE VIEW v_customer_shipments AS
SELECT
    s.shipment_id,
    s.customer_no,
    s.ship_date,
    s.carrier,
    s.tracking_no,
    s.delivery_status
FROM shipments s;

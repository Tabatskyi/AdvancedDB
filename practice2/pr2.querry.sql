WITH CompletedOrders AS (
    SELECT order_id, customer_id
    FROM orders
    WHERE status = 'completed'
)
SELECT 
    c.customer_name,
    c.country,
    CustomerRevenue.total_revenue
FROM customers c
JOIN (
    SELECT 
        co.customer_id, 
        SUM(oi.quantity * p.price) AS total_revenue
    FROM CompletedOrders co
    JOIN order_items oi ON co.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY co.customer_id
) CustomerRevenue ON c.customer_id = CustomerRevenue.customer_id
ORDER BY CustomerRevenue.total_revenue DESC;


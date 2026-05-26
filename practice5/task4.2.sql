-- 1. Create the target table to house the audit logs
CREATE TABLE order_status_logs (
    log_id        SERIAL PRIMARY KEY, --  Auto-incrementing sequential integer
    order_id      VARCHAR(50) NOT NULL,
    old_status    order_status_enum,
    new_status    order_status_enum,
    changed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. The Trigger Function
CREATE OR REPLACE FUNCTION audit_order_status_transitions()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert the historical state difference directly into the log table
    INSERT INTO order_status_logs (order_id, old_status, new_status)
    VALUES (NEW.order_id, OLD.order_status, NEW.order_status);

    -- In AFTER triggers, the return value is ignored, but returning NEW is standard practice
    RETURN NEW;
END;
$$;

-- 3. The Trigger Binding (Fires AFTER an UPDATE)
CREATE OR REPLACE TRIGGER trg_log_order_status_updates
AFTER UPDATE ON orders
FOR EACH ROW
WHEN (NEW.order_status IS DISTINCT FROM OLD.order_status) -- Trigger executes only when status changes
EXECUTE FUNCTION audit_order_status_transitions();

UPDATE orders 
SET order_status = 'returned' 
WHERE order_id = 'O-2025-8888';

SELECT log_id, order_id, old_status, new_status, changed_at 
FROM order_status_logs 
WHERE order_id = 'O-2025-8888';

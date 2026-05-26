CREATE OR REPLACE FUNCTION classify_user_loyalty(
    p_user_id users.user_id%TYPE,
    OUT p_name users.name%TYPE,
    OUT p_order_count INTEGER,
    OUT p_loyalty_tier VARCHAR(50)
)   
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_count INTEGER;
BEGIN
    SELECT name, COUNT(order_id) 
    INTO p_name, v_order_count
    FROM users 
    JOIN orders USING (user_id)
    WHERE user_id = p_user_id
    GROUP BY user_id, name;

    p_order_count := v_order_count;

    IF v_order_count > 5 THEN
        p_loyalty_tier := 'Loyal Customer';
    ELSE
        p_loyalty_tier := 'Standard Customer';
    END IF;
    
    RETURN; 
END;
$$;

SELECT * FROM classify_user_loyalty('U000001');
SELECT * FROM classify_user_loyalty('U000006');
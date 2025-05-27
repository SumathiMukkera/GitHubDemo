/*1.	Write  a function to Calculate the total stock value for a given category:
(Stock value=ROUND(SUM(unit_price * units_in_stock)::DECIMAL, 2)
Return data type is DECIMAL(10,2) */
CREATE OR REPLACE FUNCTION get_total_cost(p_product_id INT)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$ 
DECLARE 
v_stock_value DECIMAL(10,2);
BEGIN
SELECT 
ROUND(SUM(unit_price * units_in_stock)::DECIMAL, 2)
INTO v_stock_value
FROM products p
WHERE p.Product_id = p_product_id ;	

RETURN v_stock_value;

END;
$$;

SELECT get_total_cost (10);

select product_id from products

----2.Try writing a   cursor query which I executed in the training

Create OR REPLACE procedure update_price_with_curson()
LANGUAGE plpgsql
AS $$ 
DECLARE 
product_cursor CURSOR FOR 
SELECT product_id, product_name,unit_price, units_in_stock
FROM products 
WHERE discontinued =0;

product_record RECORD;
v_new_price Decimal(10,2);

BEGIN 

OPEN product_cursor;

LOOP 

--fetch the next row
FETCH product_cursor INTO product_record;

---exit when no more rows to fetch
EXIT WHEN NOT FOUND;

---calculate new unit price
IF product_record.units_in_stock < 10 THEN 
v_new_price := product_record.unit_price * 1.1; --10% increase 
ELSE 
v_new_price := product_record.unit_price * 0.95 ;---5% Decrese
END IF;

---update product 
UPDATE products
SET unit_price = ROUND(v_new_price, 2)
WHERE product_id = product_record.product_ID;

RAISE NOTICE 'Updated % price from % to % ',
product_record.product_name,
product_record.unit_price,
v_new_price;
END LOOP;

CLOSE product_cursor;
END;
$$;

--To execute 
CALL update_price_with_curson();

SELECT * FROM products;

----------------- hackathon questions------------
CREATE OR REPLACE PROCEDURE gdm_status_cursor()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor to fetch all participants with diagnosed_gdm = 1
    gdm_cursor CURSOR FOR
        SELECT 
            p.participant_id, 
            p."Still-birth", 
            g.diagnosed_gdm, 
            s.previous_gdm
        FROM pregnancy_info p 
        JOIN glucose_tests g ON p.participant_id = g.participant_id 
        JOIN screening s ON p.participant_id = s.participant_id
        WHERE g.diagnosed_gdm = 1;

    -- Variables to hold each row's values
    v_participant_id INT;
    v_still_birth TEXT;
    v_diagnosed_gdm INT;
    v_previous_gdm INT;
BEGIN
    OPEN gdm_cursor;

    LOOP
        FETCH gdm_cursor INTO v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm;
        EXIT WHEN NOT FOUND;

        -- Process each participant here (e.g., print/log values)
        RAISE NOTICE 'Participant: %, Still-birth: %, GDM: %, Previous GDM: %',
            v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm;
    END LOOP;

    CLOSE gdm_cursor;
END;
$$;

CALL gdm_status_cursor();

CREATE OR REPLACE PROCEDURE gdm_status_proc(IN p_participant_id INT,
INOUT    v_participant_id INT DEFAULT 0,
 INOUT   v_still_birth TEXT DEFAULT 0,
 INOUT   v_diagnosed_gdm INT DEFAULT 0,
  INOUT  v_previous_gdm INT DEFAULT 0)
LANGUAGE plpgsql
AS $$

BEGIN
    SELECT 
        p.participant_id, 
        p."Still-birth", 
        g.diagnosed_gdm, 
        s.previous_gdm
    INTO v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm
    FROM pregnancy_info p 
    JOIN glucose_tests g ON p.participant_id = g.participant_id 
    JOIN screening s ON p.participant_id = s.participant_id
    WHERE g.diagnosed_gdm = 1 AND p.participant_id = p_participant_id;
    

    RAISE NOTICE 'Participant: %, Still-birth: %, GDM: %, Previous GDM: %',
        v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm;
    
END;
$$;
----call stored procedure ----------
CALL gdm_status_proc(8);

---71. What proportion of participants diagnosed with gestational diabetes mellitus (GDM) have a family or their own previous history of the condition ?
WITH diagnosed AS (
  SELECT participant_id
  FROM glucose_tests
  WHERE diagnosed_gdm = 1
),
joined_data AS (
  SELECT
    d.participant_id,
    COALESCE(s.previous_gdm, 0) AS previous_gdm,
    COALESCE(dm.family_history, 0) AS family_history
  FROM diagnosed d
  LEFT JOIN screening s ON d.participant_id = s.participant_id
  LEFT JOIN demographics dm ON d.participant_id = dm.participant_id
)
SELECT
  COUNT(*) AS total_diagnosed,
  COUNT(*) FILTER (
    WHERE previous_gdm = 1 OR family_history = 1
  ) AS diagnosed_with_history,
  ROUND(
    COUNT(*) FILTER (
      WHERE previous_gdm = 1 OR family_history = 1
    ) * 100.0 / COUNT(*),
    2
  ) AS percentage_with_history
FROM joined_data;


----- for a single user ---------------
CREATE OR REPLACE PROCEDURE gdm_status_proc(IN p_participant_id INT,
INOUT    v_participant_id INT DEFAULT 0,
 INOUT   v_still_birth TEXT DEFAULT 0,
 INOUT   v_diagnosed_gdm INT DEFAULT 0,
  INOUT  v_previous_gdm INT DEFAULT 0)
LANGUAGE plpgsql
AS $$

BEGIN
    SELECT 
        p.participant_id, 
        p."Still-birth", 
        g.diagnosed_gdm, 
        s.previous_gdm
    INTO v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm
    FROM pregnancy_info p 
    JOIN glucose_tests g ON p.participant_id = g.participant_id 
    JOIN screening s ON p.participant_id = s.participant_id
    WHERE g.diagnosed_gdm = 1 AND p.participant_id = p_participant_id;
    

    RAISE NOTICE 'Participant: %, Still-birth: %, GDM: %, Previous GDM: %',
        v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm;
    
END;
$$;
----call stored procedure ----------
CALL gdm_status_proc(8);


--1. Create AFTER UPDATE trigger to track product price changes
---Create a audit table
CREATE TABLE product_price_audit(
    audit_id SERIAL PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(40),
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_name VARCHAR(50) DEFAULT CURRENT_USER
);

----1. define trigger function
CREATE OR REPLACE FUNCTION log_new_product()
RETURNs TRIGGER as $$
BEGIN 

----2. Insert into aufit log table 
INSERT INTO product_price_audit(
        product_id,
        product_name,
        old_price,
        new_price
)
VALUES (
   OLD.product_id,
        OLD.product_name,
        OLD.unit_price,
        NEW.unit_price
);
---3. return new row 
RETURN NEW;    ----required for AFTER TRIGGERS
END;
$$ LANGUAGE plpgsql;

---Create a row level trigger for below event: AFTER UPDATE OF unit_price ON products

CREATE TRIGGER after_product_uodate 
AFTER UPDATE OF unit_price ON products
FOR EACH ROW
EXECUTE FUNCTION log_new_product();

--· Test the trigger by updating the product price by 10% to any one product_id.

UPDATE products 
SET unit_price = unit_price* 1.1
WHERE product_id = 3;


SELECT * FROM products
WHERE product_id = 3;


-- 2. Create stored procedure  using IN and INOUT parameters to assign tasks to employees

CREATE or REPLACE PROCEDURE assign_tasks(
IN p_employee_id INT,
IN p_task_name VARCHAR(50),
INOUT p_task_count INT DEFAULT 0
)
LANGUAGE plpgsql
AS $$
BEGIN
---·  Inside Logic: Create table employee_tasks:

  CREATE TABLE IF NOT EXISTS employee_tasks(
 task_id SERIAL PRIMARY KEY,
  employee_id INT,
  task_name VARCHAR(50),
  assigned_date DATE DEFAULT CURRENT_DATE);
----- Insert employee_id, task_name  into employee_tasks

  INSERT INTO employee_tasks(employee_id,task_name)
  Values(p_employee_id, p_task_name);
----· Count total tasks for employee and put the total count into p_task_count .

  SELECT 
  count(*)
  INTO p_task_count INT 
  FROM employee_tasks;
----· Raise NOTICE message:

  RAISE NOTICE 'ask "%" assigned to employee %. Total tasks: %',p_task_name, p_employee_id, p_task_count;

  END;
  $$;

---After creating stored procedure test by calling  it:
CALL assign_tasks( 2, 'Review Reports');


----You should see the entry in employee_tasks table.

SELECT * FROM employee_tasks;



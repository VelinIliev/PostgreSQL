-- 01. Count Employees by Town

CREATE FUNCTION fn_count_employees_by_town(town_name VARCHAR(20))
RETURNS INT
AS $$
DECLARE employees_count_by_town INT;
BEGIN
SELECT COUNT(employee_id) INTO employees_count_by_town
FROM employees
JOIN addresses USING (address_id)
JOIN towns USING(town_id)
WHERE towns.name = town_name;
RETURN employees_count_by_town;
END;
$$ LANGUAGE plpgsql;

SELECT fn_count_employees_by_town('Sofia') AS count;
SELECT fn_count_employees_by_town('Berlin') AS count;
SELECT fn_count_employees_by_town(NULL) AS count;

-- 02. Employees Promotion

CREATE OR REPLACE PROCEDURE sp_increase_salaries(department_name VARCHAR(50))
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees AS e
    SET salary = salary * 1.05
    WHERE e.department_id = (
    SELECT department_id FROM departments WHERE name = department_name);
END; $$;

CALL sp_increase_salaries('Finance');

-- 03. Employees Promotion By ID

CREATE OR REPLACE PROCEDURE sp_increase_salary_by_id(id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
            SELECT 1 FROM employees
            WHERE id = employee_id
        ) THEN
        UPDATE employees
        SET salary = salary * 1.05
        WHERE id = employee_id;
    END IF;
END; $$;

CALL sp_increase_salary_by_id(17);

-- 04. Triggered

CREATE TABLE deleted_employees(
employee_id SERIAL PRIMARY KEY,
first_name VARCHAR(20),
last_name VARCHAR(20),
middle_name VARCHAR(20),
job_title VARCHAR(50),
department_id INT,
salary NUMERIC(19,4)
);

CREATE OR REPLACE FUNCTION trigger_fn_on_employee_delete()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO deleted_employees (
        first_name,
        last_name,
        middle_name,
        job_title,
        department_id,
        salary
    ) VALUES (
        OLD.first_name,
        OLD.last_name,
        OLD.middle_name,
        OLD.job_title,
        OLD.department_id,
        OLD.salary
    );
    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_deleted_employees
AFTER DELETE ON employees FOR EACH ROW
EXECUTE FUNCTION trigger_fn_on_employee_delete();

DELETE FROM employees
WHERE employee_id = 290
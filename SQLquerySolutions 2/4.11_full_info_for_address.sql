-- Stored Procedure which return NOTICE:
CREATE TABLE search_results_1 (
    id SERIAL PRIMARY KEY,
    address_name VARCHAR(50),
    full_name VARCHAR(100),
    level_of_bill VARCHAR(20),
    make VARCHAR(30),
    condition CHAR(1),
    category_name VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE sp_courses_by_address_1(
    IN address_name VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    result_record RECORD;
BEGIN
    -- Clear previous results from the table
    TRUNCATE TABLE search_results_1;

    -- Insert new results into the table
    INSERT INTO search_results_1 (
        address_name,
        full_name,
        level_of_bill,
        make,
        "condition",
        category_name
    )
    SELECT 
		a."name",
		cl.full_name,
           CASE
               WHEN cou.bill <= 20 THEN 'Low'
               WHEN cou.bill <= 30 THEN 'Medium'
               ELSE 'High'
           END AS level_of_bill,
           c.make, 
		   c."condition", 
		   cat."name"
    FROM 
		courses cou
    INNER JOIN 
		addresses AS a 
		ON
		cou.from_address_id = a."id"
    INNER JOIN 
		clients AS cl 
		ON
		cou.client_id = cl."id"
    INNER JOIN 
		cars AS c 
		ON
		cou.car_id = c."id"
    INNER JOIN 
		categories AS cat 
		ON 
		c.category_id = cat."id"
    WHERE 
		a."name" = address_name
    ORDER BY 
		c.make, 
		cl.full_name;

    -- Print the results as a notice
    FOR 
		result_record 
		IN SELECT * 
		FROM 
			search_results_1 
			LOOP
				RAISE NOTICE 
				'Address: %, 
				Full Name: %, 
				Level of Bill: %, 
				Make: %, 
				Condition: %, 
				Category: %',
					result_record.address_name,
					result_record.full_name,
					result_record.level_of_bill,
					result_record.make,
					result_record.condition,
					result_record.category_name;
			END LOOP;
END;
$$;


CALL sp_courses_by_address_1('700 Monterey Avenue');
CALL sp_courses_by_address_1('66 Thompson Drive');


-- Stored Procedure which return the results as a table:
CREATE TABLE search_results_2 (
    id SERIAL PRIMARY KEY,
    address_name VARCHAR(50),
    full_name VARCHAR(100),
    level_of_bill VARCHAR(20),
    make VARCHAR(30),
    condition CHAR(1),
    category_name VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE sp_courses_by_address_2(
    IN address_name VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Clear previous results from the table
    TRUNCATE TABLE search_results_2;

    -- Insert new results into the table
    INSERT INTO search_results_2 (
        address_name,
        full_name,
        level_of_bill,
        make,
        "condition",
        category_name
    )
    SELECT 
		a.name, 
		cl.full_name,
           CASE
               WHEN cou.bill <= 20 THEN 'Low'
               WHEN cou.bill <= 30 THEN 'Medium'
               ELSE 'High'
           END AS level_of_bill,
           c.make, 
		   c."condition", 
		   cat."name"
    FROM courses cou
    INNER JOIN 
		addresses AS a 
		ON
		cou.from_address_id = a."id"
    INNER JOIN 
		clients AS cl 
		ON
		cou.client_id = cl.id
    INNER JOIN 
		cars AS c 
		ON
		cou.car_id = c.id
    INNER JOIN 
		categories AS cat 
		ON
		c.category_id = cat.id
    WHERE 
		a."name" = address_name
    ORDER BY 
		c.make, 
		cl.full_name;
END;
$$;

CALL sp_courses_by_address_2('700 Monterey Avenue');
CALL sp_courses_by_address_2('66 Thompson Drive');

SELECT * FROM search_results_2;
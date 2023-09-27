-- 1.1. Database Design

CREATE TABLE IF NOT EXISTS addresses(
    id SERIAL PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    "name" VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS drivers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL ,
    last_name VARCHAR(30) NOT NULL ,
    "age" INT NOT NULL ,
    rating NUMERIC DEFAULT 5.5,
    CONSTRAINT drivers_age_check CHECK (age > 0)
);

CREATE TABLE IF NOT EXISTS cars (
    id SERIAL PRIMARY KEY,
    make VARCHAR(20) NOT NULL,
    model VARCHAR(20),
    "year" INT DEFAULT 0 NOT NULL,
    mileage INT DEFAULT 0,
    condition CHAR(1) NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT fk_cars_categories
        FOREIGN KEY(category_id)
            REFERENCES categories(id)
                  ON DELETE CASCADE
                  ON UPDATE CASCADE,
    CONSTRAINT cars_year_check CHECK ("year" > 0),
    CONSTRAINT cars_mileage_check CHECK ( mileage > 0 )
);

CREATE TABLE IF NOT EXISTS courses(
    id SERIAL PRIMARY KEY,
    from_address_id INT NOT NULL,
    "start" TIMESTAMP NOT NULL,
    bill NUMERIC(10, 2) DEFAULT 10,
    car_id INT NOT NULL,
    client_id INT NOT NULL,
    CONSTRAINT courses_bill_check CHECK ( bill > 0 ),
    CONSTRAINT fk_courses_addresses
        FOREIGN KEY(from_address_id)
            REFERENCES addresses(id)
                  ON DELETE CASCADE
                  ON UPDATE CASCADE,
    CONSTRAINT fk_courses_cars
        FOREIGN KEY(car_id)
            REFERENCES cars(id)
                  ON DELETE CASCADE
                  ON UPDATE CASCADE,
    CONSTRAINT fk_courses_clients
        FOREIGN KEY(client_id)
            REFERENCES clients(id)
                  ON DELETE CASCADE
                  ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cars_drivers(
    car_id INT NOT NULL ,
    driver_id INT NOT NULL ,
    CONSTRAINT fk_cars_drivers_cars
        FOREIGN KEY(car_id)
            REFERENCES cars(id)
                  ON DELETE CASCADE
                  ON UPDATE CASCADE,
    CONSTRAINT fk_cars_drivers_drivers
        FOREIGN KEY(driver_id)
            REFERENCES drivers(id)
                  ON DELETE CASCADE
                  ON UPDATE CASCADE
);

-- 2.2. Insert

INSERT INTO clients(full_name, phone_number)
SELECT
    CONCAT(first_name, ' ', last_name),
    CONCAT('(088) 9999', (id * 2)::VARCHAR)
FROM drivers
WHERE id between 10 AND 20;

-- 2.3. Update

UPDATE cars
SET condition = 'C'
WHERE
    (mileage >= 800000 OR mileage IS NULL)
  AND
    "year" <= 2010
  AND
    make != 'Mercedes-Benz';

-- 2.4. Delete

DELETE FROM clients
WHERE id IN (
    SELECT c.id FROM courses
    RIGHT JOIN clients c on courses.client_id = c.id
    WHERE courses.client_id ISNULL
    );

-- 3.5. Cars

SELECT make, model, condition FROM cars
ORDER BY id;

-- 3.6. Drivers and Cars

SELECT d.first_name, d.last_name, c.make, c.model, c.mileage FROM drivers AS d
JOIN cars_drivers cd on d.id = cd.driver_id
JOIN cars c on c.id = cd.car_id
WHERE mileage IS NOT NULL
ORDER BY mileage DESC , first_name;

-- 3.7. Number of Courses for Each Car

SELECT
    c.id AS car_id,
    c.make,
    c.mileage,
    COUNT(c2.id) AS "count_of_courses",
    ROUND(AVG(c2.bill), 2) AS "average_bill"
FROM cars AS c
LEFT JOIN courses c2 on c.id = c2.car_id
GROUP BY c.id, c.make, c.mileage
HAVING COUNT(c2.id) != 2
ORDER BY "count_of_courses" DESC, c.id;

-- 3.8. Regular Clients

SELECT
    c.full_name,
    COUNT(co.car_id) AS "count_of_cars",
    SUM(co.bill) AS "total_sum"
FROM courses AS co
JOIN clients c on co.client_id = c.id
WHERE SUBSTRING(c.full_name, 2, 1) = 'a'
GROUP BY co.client_id, c.full_name
HAVING COUNT(co.car_id) > 1
ORDER BY c.full_name ASC;

-- 3.9. Full Information of Courses

SELECT
    a.name AS "address",
    CASE
        WHEN EXTRACT('Hour' from co.start) BETWEEN 6 AND 20 THEN 'Day'
        ELSE 'Night'
    END AS "day_time",
    co.bill AS "bill",
    c.full_name,
    c2.make,
    c2.model,
    c3.name AS "name"
FROM courses AS co
JOIN addresses a on co.from_address_id = a.id
JOIN clients c on co.client_id = c.id
JOIN cars c2 on c2.id = co.car_id
JOIN categories c3 on c2.category_id = c3.id
ORDER BY co.id;

-- 4.10. Find all Courses by Client’s Phone Number

CREATE OR REPLACE FUNCTION fn_courses_by_client(
    phone_num VARCHAR(20)
)
RETURNS INT
LANGUAGE PLPGSQL
AS $$
DECLARE courses INT;
BEGIN
    courses =
        (SELECT COUNT(c.id)FROM courses AS co
        JOIN clients c on co.client_id = c.id
        WHERE c.phone_number = phone_num
        GROUP BY c.id);
    IF courses ISNULL THEN RETURN 0;
    ELSE return courses;
    END IF;
END;
$$;

SELECT fn_courses_by_client('(803) 6386812');
SELECT fn_courses_by_client('(831) 1391236');
SELECT fn_courses_by_client('(704) 2502909');

-- 4.11. Full Info for Address

CREATE TABLE search_results(
    id SERIAL PRIMARY KEY,
    address_name VARCHAR(100),
    full_name VARCHAR(100),
    level_of_bill VARCHAR(20),
    make VARCHAR(30),
    condition CHAR(1),
    category_name VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE sp_courses_by_address (
    sp_courses_by_address VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE search_results;

    INSERT INTO search_results(address_name, full_name, level_of_bill, make, condition, category_name)
    SELECT
        a.name AS "address_name",
        c.full_name AS "full_name",
        CASE
            WHEN co.bill <= 20 THEN 'Low'
            WHEN co.bill <= 30 THEN 'Medium'
            ELSE 'High'
        END AS "level_of_bill",
        ca.make,
        ca.condition,
        c2.name AS "category_name"
    FROM courses AS co
    JOIN addresses a on a.id = co.from_address_id
    JOIN clients c on c.id = co.client_id
    JOIN cars ca on ca.id = co.car_id
    JOIN categories c2 on ca.category_id = c2.id
    WHERE a.name = sp_courses_by_address
    ORDER BY ca.make, c.full_name;
END
$$ ;

CALL sp_courses_by_address('700 Monterey Avenue');
CALL sp_courses_by_address('66 Thompson Drive')

SELECT * FROM search_results;


-- SELECT
--     a.name AS "address_name",
--     c.full_name AS "full_name",
--     CASE
--         WHEN co.bill <= 20 THEN 'Low'
--         WHEN co.bill <= 30 THEN 'Medium'
--         ELSE 'High'
--     END AS "level_of_bill",
--     ca.make,
--     ca.condition,
--     c2.name AS "category_name"
-- FROM courses AS co
-- JOIN addresses a on a.id = co.from_address_id
-- JOIN clients c on c.id = co.client_id
-- JOIN cars ca on ca.id = co.car_id
-- JOIN categories c2 on ca.category_id = c2.id
-- WHERE a.name = '700 Monterey Avenue'
-- ORDER BY ca.make, c.full_name
-- 01. River Info

CREATE OR REPLACE VIEW view_river_info AS
    SELECT 'The river' || ' ' || river_name || ' ' || 'flows into the' || ' ' || outflow || ' ' || 'and is' || ' ' || "length" || ' ' || 'kilometers long.' AS "River Information"
    FROM rivers
    ORDER BY river_name;

-- 02. Concatenate Geography Data
CREATE OR REPLACE VIEW view_continents_countries_currencies_details AS
    SELECT
        TRIM(c.continent_name) || ': ' || TRIM(c.continent_code) AS "Continent Details",
        TRIM(country_name) || ' - ' || TRIM(capital) || ' - ' || area_in_sq_km || ' - km2' AS "Country Information",
        TRIM(c2.description) || ' (' || TRIM(c2.currency_code) || ')' AS "Currencies"
    FROM countries
    JOIN continents c on countries.continent_code = c.continent_code
    JOIN currencies c2 on countries.currency_code = c2.currency_code
    ORDER BY "Country Information", "Currencies";

-- 03. Capital Code
ALTER TABLE countries
ADD COLUMN capital_code char(2);

UPDATE countries
SET capital_code = SUBSTRING(capital, 1, 2);

-- 04. (Descr)iption
SELECT SUBSTRING(description, 5) FROM currencies;

-- 05. Substring River Length
SELECT (regexp_matches("River Information", '([0-9]{1,4})'))[1] AS river_length FROM view_river_info;

-- 06. Replace A
SELECT
    REPLACE(mountain_range, 'a', '@') AS "replace_a",
    REPLACE(mountain_range, 'A', '$') AS "replace_A"
FROM mountains;

-- 07. Translate
SELECT capital, TRANSLATE(capital, 'áãåçéíñóú', 'aaaceinou') AS "translated_name" FROM countries;

-- 08. LEADING
SELECT continent_name, TRIM(continent_name) FROM continents;

-- 09. TRAILING
SELECT continent_name, TRIM(continent_name) FROM continents;

-- 10. LTRIM & RTRIM
SELECT
    LTRIM(peak_name, 'M') AS "Left Trim" ,
    RTRIM(peak_name, 'm') AS "Right Trim"
FROM peaks;

-- 11. Character Length and Bits
SELECT
    CONCAT(mountain_range, ' ', p.peak_name) AS "Mountain Information" ,
    LENGTH(CONCAT(mountain_range, ' ', p.peak_name)) AS "Characters Length",
    BIT_LENGTH(CONCAT(mountain_range, ' ', p.peak_name)) AS "Bits of a String"
FROM mountains
JOIN peaks p on mountains.id = p.mountain_id;

-- 12. Length of a Number
SELECT population, LENGTH(CAST(population AS VARCHAR)) FROM countries;
SELECT population, LENGTH(population::VARCHAR) FROM countries;

-- 13. Positive and Negative LEFT
SELECT
    peak_name,
    LEFT(peak_name, 4) AS "Positive Left",
    LEFT(peak_name, -4) AS "Negative Left"
FROM peaks;

-- 14. Positive and Negative RIGHT
SELECT
    peak_name,
    RIGHT(peak_name, 4) "Positive Right",
    RIGHT(peak_name, -4) AS "Positive Right"
FROM peaks;

-- 15. Update iso_code
UPDATE countries
SET iso_code = UPPER(SUBSTRING(country_name, 1, 3))
WHERE iso_code IS NULL;

-- 16. REVERSE country_code
UPDATE countries
SET country_code = LOWER(reverse(country_code));

-- 17. Elevation --->> Peak Name
SELECT elevation || ' --->> ' || peak_name AS "Elevation --->> Peak Name" FROM peaks
WHERE elevation >= 4884;

-- 18. Arithmetical Operators
CREATE TABLE bookings_calculation AS
SELECT booked_for,
       booked_for::numeric * 50 AS "multiplication",
       booked_for::numeric % 50 AS "modulo"
FROM bookings
WHERE apartment_id = 93;

-- 19. ROUND vs TRUNC
SELECT
    latitude,
    round(latitude, 2),
    trunc(latitude, 2)
FROM apartments;

-- 20. Absolute Value
SELECT longitude, ABS(longitude) FROM apartments;

-- 21. Billing Day
ALTER TABLE bookings
ADD COLUMN billing_day TIMESTAMPTZ default CURRENT_TIMESTAMP;

SELECT
    billing_day,
    TO_CHAR(billing_day, 'DD "Day" MM "Month" YYYY "Year" HH24:MI:SS') AS "Billing Day"
FROM bookings;

-- 22. EXTRACT Booked At
SELECT
    EXTRACT(YEAR FROM booked_at) AS "YEAR",
    EXTRACT(MONTH FROM booked_at) AS "MONTH",
    EXTRACT(DAY FROM booked_at) AS "DAY",
    EXTRACT(HOUR FROM booked_at AT TIME ZONE 'UTC') AS "HOUR",
    EXTRACT(MINUTE FROM booked_at ) AS "MINUTE",
    CEILING(EXTRACT(SECOND FROM booked_at)) AS "SECOND"
FROM
    bookings;

-- 23. Early Birds**
SELECT
    user_id,
    AGE(starts_at, booked_at) AS "Early Birds"
FROM bookings
WHERE starts_at - booked_at >= '10 MONTHS';

-- 24. Match or Not
SELECT companion_full_name, email FROM users
WHERE email NOT LIKE '%@gmail' AND companion_full_name ILIKE '%and%';

-- 25. COUNT by Initial
SELECT
    LEFT(first_name, 2) AS initials,
    COUNT('initials') AS user_count
FROM users
GROUP BY initials
ORDER BY user_count DESC, initials;

-- 26. SUM
SELECT SUM(booked_for) FROM bookings
WHERE apartment_id = 90;

-- 27. Average Value
SELECT AVG(multiplication) FROM bookings_calculation;
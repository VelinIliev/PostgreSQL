-- 01. Booked for Nights
SELECT
    CONCAT(address, ' ', address_2) AS "Apartment Address",
    b.booked_for AS "Nights"
FROM apartments
JOIN bookings b on b.booking_id = apartments.booking_id
ORDER BY apartments.apartment_id ASC;

-- 02. First 10 Apartments Booked At

SELECT
    a.name AS "Name",
    a.country AS "Country",
    DATE(b.booked_at) AS "Booked at"
FROM apartments AS a
LEFT JOIN bookings b on b.booking_id = a.booking_id
LIMIT 10;

-- 03. First 10 Customers with Bookings

SELECT
    b.booking_id AS "Booking ID",
    DATE(b.starts_at) AS "Start Date",
    b.apartment_id AS "Apartment ID",
    CONCAT(c.first_name, ' ', c.last_name) AS "Customer Name" FROM bookings AS b
RIGHT JOIN customers c on c.customer_id = b.customer_id
ORDER BY "Customer Name"
LIMIT 10;

-- 04. Booking Information

SELECT
    b.booking_id AS "Booking ID",
    a.name AS "Apartment Owner",
    a.apartment_id AS "Apartment ID",
    CONCAT(c.first_name, ' ', c.last_name) AS "Customer Name"
FROM bookings AS b
FULL JOIN apartments a on b.booking_id = a.booking_id
FULL JOIN customers c on c.customer_id = b.customer_id
ORDER BY "Booking ID", "Apartment Owner", "Customer Name"

-- 5. Multiplication of Information**

SELECT
    b.booking_id AS "Booking ID",
    c.first_name AS "Customer Name"
FROM bookings AS b
CROSS JOIN customers AS c
ORDER BY "Customer Name";

-- 06. Unassigned Apartments

SELECT b.booking_id, b.apartment_id, c.companion_full_name FROM bookings AS b
JOIN customers c on c.customer_id = b.customer_id
WHERE b.apartment_id ISNULL;

SELECT b.booking_id, b.apartment_id, c.companion_full_name FROM bookings AS b
JOIN customers c USING(customer_id)
WHERE b.apartment_id ISNULL;

-- 07. Bookings Made by Lead

SELECT b.apartment_id, b.booked_for, c.first_name, c.country FROM bookings b
INNER JOIN customers c USING(customer_id)
WHERE c.job_type = 'Lead';

-- 08. Hahn`s Bookings

SELECT COUNT(*) FROM bookings AS b
JOIN customers c USING (customer_id)
WHERE c.last_name = 'Hahn';

-- 09. Total Sum of Nights

SELECT a.name AS "name", SUM(b.booked_for) AS "sum"  FROM apartments AS a
JOIN bookings b USING(apartment_id)
GROUP BY a.name
ORDER BY a.name;

-- 10. Popular Vacation Destination

SELECT a.country, COUNT(*) AS "booking_count" FROM apartments a
JOIN bookings b USING(apartment_id)
WHERE b.booked_at > '2021-05-18 07:52:09.904+03' AND b.booked_at < '2021-09-17 19:48:02.147+03'
GROUP BY a.country
ORDER BY "booking_count" DESC;

-- 11. Bulgaria's Peaks Higher than 2835 Meters

SELECT mc.country_code, m.mountain_range, p.peak_name, p.elevation  FROM peaks AS p
JOIN mountains m on p.mountain_id = m.id
JOIN mountains_countries mc on m.id = mc.mountain_id
WHERE p.elevation > 2835 AND mc.country_code = 'BG'
ORDER BY p.elevation DESC ;

-- 12. Count Mountain Ranges

SELECT country_code, count(*) AS "mountain_range_count" FROM mountains_countries
WHERE country_code IN ('US', 'RU', 'BG')
GROUP BY country_code
ORDER BY "mountain_range_count" DESC ;

-- 13. Rivers in Africa

SELECT c.country_name, r.river_name FROM countries AS c
LEFT JOIN countries_rivers cr on c.country_code = cr.country_code
LEFT JOIN rivers r on r.id = cr.river_id
WHERE c.continent_code = 'AF'
ORDER BY c.country_name ASC
LIMIT 5;

-- 14. Minimum Average Area Across Continents

SELECT AVG(area_in_sq_km) AS "min_average_area" FROM countries
GROUP BY continent_code
ORDER BY "min_average_area"
LIMIT 1;

-- 15. Countries Without Any Mountains

SELECT COUNT(*) AS "countries_without_mountains" FROM countries
LEFT JOIN mountains_countries mc on countries.country_code = mc.country_code
WHERE mc.mountain_id ISNULL;

-- 16. Monasteries by Country

CREATE TABLE monasteries (
    id SERIAL PRIMARY KEY,
    monastery_name VARCHAR(255),
    country_code CHAR(2)
);

INSERT INTO monasteries(monastery_name, country_code)
VALUES
    ('Rila Monastery “St. Ivan of Rila”', 'BG'),
    ('Bachkovo Monastery “Virgin Mary”', 'BG'),
    ('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
    ('Kopan Monastery', 'NP'),
    ('Thrangu Tashi Yangtse Monastery', 'NP'),
    ('Shechen Tennyi Dargyeling Monastery', 'NP'),
    ('Benchen Monastery', 'NP'),
    ('Southern Shaolin Monastery', 'CN'),
    ('Dabei Monastery', 'CN'),
    ('Wa Sau Toi', 'CN'),
    ('Lhunshigyia Monastery', 'CN'),
    ('Rakya Monastery', 'CN'),
    ('Monasteries of Meteora', 'GR'),
    ('The Holy Monastery of Stavronikita', 'GR'),
    ('Taung Kalat Monastery', 'MM'),
    ('Pa-Auk Forest Monastery', 'MM'),
    ('Taktsang Palphug Monastery', 'BT'),
    ('Sümela Monastery', 'TR');

ALTER TABLE countries
ADD COLUMN "three_rivers" BOOLEAN DEFAULT FALSE;

UPDATE countries c
SET three_rivers = FALSE

UPDATE countries
SET three_rivers = true
    WHERE country_code IN (
        SELECT country_code FROM countries_rivers
        GROUP BY country_code
        HAVING COUNT(*) <= 3
             );

SELECT
    m.monastery_name AS "Monastery",
    c.country_name AS "Country"
FROM monasteries AS m
JOIN countries c on m.country_code = c.country_code
WHERE c.three_rivers = true
ORDER BY m.monastery_name;
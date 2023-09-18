--  01. Find Book Titles
SELECT title FROM books
WHERE title LIKE('The%')
ORDER BY id;

-- 02. Replace Titles
UPDATE books
SET title = '***' || SUBSTRING(title, 4)
WHERE title LIKE('The%');

SELECT title FROM books
WHERE title LIKE('***%')
ORDER BY id;

-- 03. Triangles on Bookshelves
SELECT
    id,
    ((side * height) / 2) AS area
FROM triangles
ORDER BY id;

-- 04. Format Costs
SELECT title, cost::decimal(16, 3) AS "modified_price" FROM books
ORDER BY id;

-- 05. Year of Birth
SELECT
    first_name,
    last_name,
    EXTRACT(YEAR FROM born) AS year
FROM authors;

-- 06. Format Date of Birth
SELECT
    last_name AS "Last Name",
    TO_CHAR(born, 'DD (Dy) Mon YYYY') AS "Date of Birth"
FROM authors;

-- 07. Harry Potter Books
SELECT title FROM books
WHERE title LIKE('%Harry Potter%');

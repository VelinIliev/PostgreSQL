-- 01. Departments Info by ID
SELECT department_id, COUNT(department_id) FROM employees
GROUP BY department_id
ORDER BY department_id;


-- 02. Departments Info by Salary
SELECT department_id, COUNT(salary) FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 03. Sum Salaries per Department
SELECT department_id, SUM(salary) FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 04. Maximum Salary
SELECT department_id, MAX(salary) FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 05. Minimum Salary
SELECT department_id, MIN(salary) FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 06. Average Salary
SELECT department_id, AVG(salary) FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 07. Filter Total Salaries
SELECT department_id, SUM(salary) AS "Total Salary" FROM employees
GROUP BY department_id
HAVING SUM(salary) < 4200
ORDER BY department_id;

-- 08. Department Names
-- Write a query to retrieve information from table employees about the department names,
-- according to department_id. The output should have the following fields:
-- •	id of the employee
-- •	first_name
-- •	last_name
-- •	salary – formatted to the second decimal place.
-- •	department_id
-- •	department_name – use Simple CASE Expression
-- o	1 – "Management"
-- o	2 – "Kitchen Staff"
-- o	3 – "Service Staff"
-- o	any other number – "Other"
-- See the examples for more information. Format the salary to 2 digits after the decimal point.
-- Submit your queries, ordered by employee id.

SELECT
    e.id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id,
    CASE
        WHEN e.department_id = 1 THEN 'Management'
        WHEN e.department_id = 2 THEN 'Kitchen Staff'
        WHEN e.department_id = 3 THEN 'Service Staff'
        ELSE 'Other'
    END AS department_name
FROM employees AS e


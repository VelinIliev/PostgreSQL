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
SELECT
    e.id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id,
    CASE
        WHEN e.department_id <= 3 THEN d.name
        ELSE 'Other'
    END AS department_name
FROM employees AS e
JOIN departments d on d.id = e.department_id;


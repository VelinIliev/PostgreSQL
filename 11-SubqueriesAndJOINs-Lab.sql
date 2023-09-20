-- 01. Towns Addresses

SELECT t.town_id, t.name, address_text FROM addresses
JOIN towns t on t.town_id = addresses.town_id
WHERE t.name IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY t.town_id, t.name, address_id;

-- 02. Managers

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS "full_name",
    d.department_id,
    d.name AS "department_name"
FROM departments AS d
JOIN employees e on e.employee_id = d.manager_id
ORDER BY e.employee_id
LIMIT 5;

-- 03. Employees Projects

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS "full_name",
    p.project_id,
    p.name AS "project_name"
FROM employees_projects AS ep
JOIN employees e on e.employee_id = ep.employee_id
JOIN projects p on p.project_id = ep.project_id
WHERE ep.project_id = 1;

-- 04. Higher Salary

SELECT COUNT(*) FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
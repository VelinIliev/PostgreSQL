-- Delete records from referencing tables first
DELETE FROM volunteers
WHERE department_id = 2;


-- Delete records from volunteers_departments table
DELETE FROM volunteers_departments
WHERE "id" = 2
RETURNING *;
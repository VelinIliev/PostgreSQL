-- 1.1. Database Design

CREATE TABLE owners (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL ,
    phone_number VARCHAR(15) NOT NULL ,
    address VARCHAR(50)
);

CREATE TABLE animal_types(
    id SERIAL PRIMARY KEY,
    animal_type VARCHAR(30) NOT NULL
);

CREATE TABLE cages (
    id SERIAL PRIMARY KEY,
    animal_type_id INT NOT NULL ,
    CONSTRAINT fk_cages_animal_types
        FOREIGN KEY(animal_type_id)
            REFERENCES animal_types(id) ON DELETE CASCADE
);

CREATE TABLE animals (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    birthdate DATE NOT NULL,
    owner_id INT,
    animal_type_id INT NOT NULL,
    CONSTRAINT fk_animals_owners
        FOREIGN KEY(owner_id)
            REFERENCES owners(id) ON DELETE CASCADE,
    CONSTRAINT fk_animals_animal_types
        FOREIGN KEY(animal_type_id)
            REFERENCES animal_types(id) ON DELETE CASCADE
);

CREATE TABLE volunteers_departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(30) NOT NULL
);

CREATE TABLE volunteers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(50),
    animal_id INT,
    department_id INT NOT NULL,
    CONSTRAINT fk_volunteers_animals
        FOREIGN KEY(animal_id)
            REFERENCES animals(id) ON DELETE CASCADE,
    CONSTRAINT fk_volunteers_volunteers_departments
        FOREIGN KEY(department_id)
            REFERENCES volunteers_departments(id) ON DELETE CASCADE
);

CREATE TABLE animals_cages (
    cage_id INT NOT NULL,
    animal_id INT NOT NULL,
    CONSTRAINT fk_animals_cages_cages
        FOREIGN KEY(cage_id)
            REFERENCES cages(id) ON DELETE CASCADE,
    CONSTRAINT fk_animals_cages_animals
        FOREIGN KEY(animal_id)
            REFERENCES animals(id) ON DELETE CASCADE
);

-- 2.2. Insert

INSERT INTO volunteers(name, phone_number, address, animal_id, department_id)
VALUES
    ('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
    ('Dimitur Stoev', '0877564223', NULL, 42, 4),
    ('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
    ('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
    ('Boryana Mileva', '0888112233', NULL, 31, 5);


INSERT INTO animals(name, birthdate, owner_id, animal_type_id)
VALUES
    ('Giraffe', '2018-09-21', 21, 1),
    ('Harpy Eagle', '2015-04-17', 15, 3),
    ('Hamadryas Baboon', '2017-11-02', NULL, 1),
    ('Tuatara', '2021-06-30', 2, 4);

-- 2.3. Update

UPDATE animals
SET owner_id = (SELECT id FROM owners WHERE owners.name = 'Kaloqn Stoqnov')
WHERE owner_id ISNULL;

-- 2.4. Delete

DELETE FROM volunteers_departments
WHERE department_name = 'Education program assistant';

-- 3.5. Volunteers

SELECT name, phone_number, address, animal_id, department_id FROM volunteers
ORDER BY name, animal_id, department_id;

-- 3.6. Animals Data

SELECT
    a.name,
    at.animal_type,
    TO_CHAR(a.birthdate, 'DD.MM.YYYY') AS "birthdate"
FROM animals AS a
JOIN animal_types at on at.id = a.animal_type_id
ORDER BY a.name;

-- 3.7. Owners and Their Animals

SELECT
    o.name AS "Owner",
    COUNT(*) AS "Count of animals"
FROM owners AS o
LEFT JOIN animals a on o.id = a.owner_id
GROUP BY o.name
ORDER BY "Count of animals" DESC, "Owner"
LIMIT 5;

-- 3.8. Owners, Animals and Cages

SELECT
    CONCAT(o.name, ' - ', a.name) AS "Owners - Animals",
    o.phone_number AS "Phone Number",
    ac.cage_id AS "Cage ID"
FROM owners AS o
JOIN animals a on o.id = a.owner_id
JOIN animal_types at on at.id = a.animal_type_id
JOIN animals_cages ac on a.id = ac.animal_id
WHERE at.animal_type = 'Mammals'
ORDER BY o.name, a.name DESC;

-- 3.9. Volunteers in Sofia

SELECT
    v.name AS "Volunteers Name",
    v.phone_number AS "Phone Number",
    TRIM(SUBSTRING(v.address, POSITION(',' IN v.address) + 1)) AS "Address"
FROM volunteers AS v
JOIN volunteers_departments vd on vd.id = v.department_id
WHERE vd.department_name = 'Education program assistant'
  AND
    v.address LIKE '%Sofia%'
ORDER BY v.name;

-- 3.10. Animals for Adoption

SELECT
    a.name AS "Animal Name",
    EXTRACT('YEAR' FROM a.birthdate ) AS "Birth Year",
    at.animal_type AS "Animal Type"
FROM animals AS a
JOIN animal_types at on at.id = a.animal_type_id
WHERE owner_id ISNULL
  AND
    at.animal_type != 'Birds'
    AND birthdate > '2022-01-01'::DATE - interval '5 years'
ORDER BY a.name;

-- 4.11. All Volunteers in a Department

CREATE OR REPLACE FUNCTION fn_get_volunteers_count_from_department(
    searched_volunteers_department VARCHAR(30)
)
RETURNS INT
LANGUAGE PLPGSQL
AS $$
BEGIN
    RETURN (
        SELECT COUNT(*) FROM volunteers AS v
        JOIN volunteers_departments vd on vd.id = v.department_id
        WHERE vd.department_name = searched_volunteers_department
        );
END;
$$;

SELECT fn_get_volunteers_count_from_department('Education program assistant');
SELECT fn_get_volunteers_count_from_department('Guest engagement');
SELECT fn_get_volunteers_count_from_department('Zoo events');

-- 4.12. Animals with Owner or Not


CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not_1 (
    IN animal_name VARCHAR(30),
	OUT result TEXT )
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        CASE
            WHEN o.name ISNULL THEN 'For adoption'
            ELSE o.name
        END
    INTO result FROM animals AS a
    LEFT JOIN owners o on a.owner_id = o.id
    WHERE a.name ILIKE animal_name;
END
$$ ;

-- CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not_1 (animal_name VARCHAR(30))
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE result VARCHAR;
-- BEGIN
--     SELECT
--         CASE
--             WHEN o.name ISNULL THEN 'For adoption'
--             ELSE o.name
--         END
--     INTO result FROM animals AS a
--     LEFT JOIN owners o on a.owner_id = o.id
--     WHERE a.name ILIKE animal_name;
--     RAISE NOTICE '%', result;
-- END
-- $$ ;

CALL sp_animals_with_owners_or_not_1('Pumpkinseed Sunfish');
CALL sp_animals_with_owners_or_not_1('Hippo', '');
CALL sp_animals_with_owners_or_not_1('Brown bear', '');
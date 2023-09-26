-- 1. Mountains and Peaks
CREATE TABLE mountains (
    id INT GENERATED ALWAYS AS IDENTITY UNIQUE,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE peaks (
    id INT GENERATED ALWAYS AS IDENTITY UNIQUE,
    name VARCHAR(50) NOT NULL,
    mountain_id INT,
    CONSTRAINT fk_peaks_mountains
        FOREIGN KEY(mountain_id)
            REFERENCES mountains(id)
);

-- 2. Trip Organization
SELECT
    driver_id,
    vehicle_type,
    CONCAT(c.first_name, ' ', c.last_name) AS "driver_name"
FROM vehicles
JOIN campers c ON vehicles.driver_id = c.id;

-- 3. SoftUni Hiking
SELECT
    start_point,
    end_point,
    leader_id,
    CONCAT(c.first_name, ' ', c.last_name) AS "leader_name"
FROM routes
JOIN campers c on c.id = routes.leader_id;

-- 4. Delete Mountains

-- DROP TABLE peaks;
-- DROP TABLE mountains;

CREATE TABLE mountains (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE peaks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    mountain_id INT,
    CONSTRAINT fk_mountain_id
        FOREIGN KEY(mountain_id)
            REFERENCES mountains(id) ON DELETE CASCADE
);
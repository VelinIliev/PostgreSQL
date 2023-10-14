-- 1.1. Database Design

CREATE TABLE towns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL
    );

CREATE TABLE stadiums (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    capacity INT NOT NULL CHECK ("capacity" > 0),
    town_id INT NOT NULL,
    CONSTRAINT fk_stadiums_towns
        FOREIGN KEY(town_id)
            REFERENCES towns(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
);

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    established DATE NOT NULL ,
    fan_base INT NOT NULL DEFAULT 0 CHECK ("fan_base" >= 0),
    stadium_id INT NOT NULL,
    CONSTRAINT fk_teams_stadiums
        FOREIGN KEY(stadium_id)
            REFERENCES stadiums(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
);

CREATE TABLE coaches(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    salary NUMERIC(10, 2) DEFAULT 0 NOT NULL CHECK ("salary" >= 0),
    coach_level INT DEFAULT 0 NOT NULL CHECK ("coach_level" >= 0)
);

CREATE TABLE skills_data(
    id SERIAL PRIMARY KEY,
    dribbling INT DEFAULT 0 CHECK ("dribbling" >= 0),
    pace INT DEFAULT 0 CHECK ("pace" >= 0),
    passing INT DEFAULT 0 CHECK ("passing" >= 0),
    shooting INT DEFAULT 0 CHECK ("shooting" >= 0),
    speed INT DEFAULT 0 CHECK ("speed" >= 0),
    strength INT DEFAULT 0 CHECK ("strength" >= 0)
);

CREATE TABLE players(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    age INT DEFAULT 0 NOT NULL CHECK ("age" >= 0),
    position CHAR(1) NOT NULL ,
    salary NUMERIC(10,2) DEFAULT 0 NOT NULL CHECK ("salary" >= 0),
    hire_date TIMESTAMP,
    skills_data_id INT NOT NULL,
    team_id INT,
    CONSTRAINT fk_players_skills_data
        FOREIGN KEY(skills_data_id)
            REFERENCES skills_data(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE ,
    CONSTRAINT fk_players_teams
        FOREIGN KEY(team_id)
            REFERENCES teams(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
);

CREATE TABLE players_coaches(
    player_id INT,
    coach_id INT,
    CONSTRAINT fk_players_coaches_players
        FOREIGN KEY(player_id)
            REFERENCES players(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE,
    CONSTRAINT fk_players_coaches_coaches
        FOREIGN KEY(coach_id)
            REFERENCES coaches(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
);

-- 2.2. Insert

INSERT INTO coaches(first_name, last_name, salary, coach_level)
SELECT first_name, last_name, salary * 2, LENGTH(first_name) FROM players
WHERE hire_date < '2013-12-13 07:18:46';

-- 2.3. Update

UPDATE coaches
SET salary = salary * coach_level
WHERE first_name LIKE 'C%'
  AND
    EXISTS (
        SELECT COUNT(coach_id)
        FROM players_coaches
        GROUP BY coach_id
        HAVING COUNT(coach_id) > 1
    );

-- 2.4. Delete

DELETE FROM players_coaches
WHERE player_id IN (
    SELECT id
    FROM players
    WHERE hire_date < '2013-12-13 07:18:46'
);

DELETE FROM players
WHERE hire_date < '2013-12-13 07:18:46';

-- 3.5. Players

SELECT
    CONCAT(first_name, ' ', last_name) as full_name,
    age,
    hire_date
FROM players
WHERE first_name LIKE 'M%'
ORDER BY age DESC, full_name ASC;

-- 3.6. Offensive Players without Team

SELECT p.id,
       CONCAT(p.first_name, ' ', p.last_name) AS full_name,
       p.age,
       p.position,
       p.salary,
       sd.pace,
       sd.shooting
FROM players AS p
JOIN skills_data sd on sd.id = p.skills_data_id
WHERE team_id IS NULL
        AND
    p.position = 'A'
        AND
    (sd.pace + sd.shooting) > 130;

-- 3.7. Teams with Player Count and Fan Base

SELECT
    teams.id AS team_id,
    teams.name AS team_name,
    COUNT(p.id) AS player_count,
    teams.fan_base
FROM teams
LEFT JOIN players p on teams.id = p.team_id
WHERE fan_base > 30000
GROUP BY teams.id, teams.name, teams.fan_base
ORDER BY COUNT(p.id)  DESC, teams.fan_base DESC;

-- 3.8. Coaches, Players Skills and Teams Overview

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS coach_full_name,
    CONCAT(p.first_name, ' ', p.last_name) AS player_full_name,
    t.name AS team_name,
    sd.passing,
    sd.shooting,
    sd.speed
FROM coaches AS c
JOIN players_coaches pc on c.id = pc.coach_id
JOIN players p on pc.player_id = p.id
JOIN skills_data sd on sd.id = p.skills_data_id
JOIN teams t on t.id = p.team_id
ORDER BY coach_full_name ASC, player_full_name DESC;

-- 4.9. Stadium Teams Information

CREATE OR REPLACE FUNCTION fn_stadium_team_name(
    stadium_name VARCHAR(30)
)
RETURNS TABLE (team_name VARCHAR(50))
AS $$
BEGIN
    RETURN QUERY (
            SELECT t.name FROM teams t
            JOIN stadiums s on s.id = t.stadium_id
            WHERE s.name = stadium_name
            ORDER BY t.name
            );
END;
$$ LANGUAGE PLPGSQL;

SELECT fn_stadium_team_name('BlogXS');
SELECT fn_stadium_team_name('Quaxo');
SELECT fn_stadium_team_name('Jaxworks');

-- 4.10. Player Team Finder

CREATE OR REPLACE PROCEDURE sp_players_team_name (
    IN player_name VARCHAR(50),
	OUT result TEXT )
AS $$
BEGIN
    SELECT
        COALESCE(t.name, 'The player currently has no team')
    INTO result FROM players
    LEFT JOIN teams t on t.id = players.team_id
    WHERE CONCAT(first_name, ' ', last_name) = player_name;
END
$$ LANGUAGE plpgsql;

CALL sp_players_team_name('Thor Serrels', '');
CALL sp_players_team_name('Walther Olenchenko', '');
CALL sp_players_team_name('Isaak Duncombe', '');
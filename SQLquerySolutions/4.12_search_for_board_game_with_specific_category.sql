-- Stored Procedure which return NOTICE:
CREATE OR REPLACE PROCEDURE usp_search_by_category_1(
	category VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    game_record RECORD;
    min_players_str TEXT;
    max_players_str TEXT;
BEGIN
    -- Create a temporary table for the session
    CREATE TEMP TABLE IF NOT EXISTS temp_results (
        "name" TEXT,
        release_year INTEGER,
        rating NUMERIC,
        category_name TEXT,
        publisher_name TEXT,
        min_players INTEGER,
        max_players INTEGER
    ) ON COMMIT DROP;

    -- Insert relevant data into temporary table
    INSERT INTO temp_results (
        "name", 
		release_year, 
		rating, 
		category_name, 
		publisher_name, 
		min_players, max_players
    )
    SELECT
        bg."name", 
		bg.release_year, 
		bg.rating, 
		c."name",
        p."name", 
		pr.min_players, 
		pr.max_players
    FROM
        board_games AS bg
    INNER JOIN
        categories AS c 
		ON 
		bg.category_id = c."id"
    INNER JOIN
        publishers AS p 
		ON
		bg.publisher_id = p."id"
	INNER JOIN 
		players_ranges AS pr 
		ON
		bg.players_range_id = pr."id"
    WHERE
        c."name" = category;

    -- Iterate over the records and print the information
    FOR 
		game_record 
		IN SELECT * 
		FROM 
			temp_results
		ORDER BY 
			publisher_name, 
			release_year DESC
			LOOP
				-- Convert min_players and max_players to strings
				min_players_str = game_record.min_players || ' people';
				max_players_str = game_record.max_players || ' people';

				-- Print the game information
				RAISE NOTICE 
					'Name: %, 
					Release Year: %, 
					Rating: %, 
					Category: %, 
					Publisher: %, 
					Min Players: %, 
					Max Players: %',
					game_record."name", 
					game_record.release_year, 
					game_record.rating,
					game_record.category_name, 
					game_record.publisher_name,
					min_players_str, 
					max_players_str;
			END LOOP;

END;
$$;

CALL usp_search_by_category_1('Wargames');


-- Stored Procedure which return the results as a table:
CREATE TABLE search_results (
	"id" SERIAL PRIMARY KEY,
    "name" VARCHAR(50),
    release_year INT,
    rating FLOAT,
    category_name VARCHAR(50),
    publisher_name VARCHAR(50),
    min_players VARCHAR(50),
    max_players VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE usp_search_by_category(
	IN category VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Clear previous results from the table
    TRUNCATE TABLE search_results;
    
    -- Insert new results into the table
    INSERT INTO search_results (
		"name", 
		release_year, 
		rating, 
		category_name, 
		publisher_name, 
		min_players, 
		max_players
	)
    SELECT 
        bg."name",
        bg.release_year,
        bg.rating,
        c."name" AS category_name,
        p."name" AS publisher_name,
        CONCAT(pr.min_players, ' people'),
        CONCAT(pr.max_players, ' people')
    FROM 
		board_games AS bg
    JOIN 
		publishers AS p 
		ON 
		bg.publisher_id = p.id
    JOIN 
		categories AS c 
		ON 
		bg.category_id = c."id"
    JOIN 
		players_ranges AS pr 
		ON 
		bg.players_range_id = pr."id"
    WHERE 
		c."name" = category
    ORDER BY 
		publisher_name, 
		release_year DESC;
END;
$$;

CALL usp_search_by_category_2('Wargames');

SELECT * FROM search_results;
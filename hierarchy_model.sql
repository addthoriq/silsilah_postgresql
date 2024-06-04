CREATE TABLE teams (
    name   TEXT
           UNIQUE NOT NULL
           PRIMARY KEY,
    parent TEXT
           REFERENCES teams (name)
);

CREATE MATERIALIZED VIEW team_structure AS
    WITH RECURSIVE teams_cte(name, parent, path) AS (
        SELECT teams.name, teams.parent, ARRAY [teams.name]
            FROM teams
            WHERE teams.parent IS NULL
        UNION ALL
        SELECT teams.name, teams.parent, array_append(teams_cte.path, teams.name)
            FROM teams_cte,
                 teams
            WHERE teams.parent = teams_cte.name
    )
    SELECT *
        FROM teams_cte;

CREATE FUNCTION refresh_team_structure() RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW team_structure;
    RETURN new;
END;
$$;

CREATE TRIGGER trigger_update_team_structure
    AFTER UPDATE OR INSERT OR DELETE OR TRUNCATE
    ON teams
EXECUTE PROCEDURE refresh_team_structure();

INSERT INTO teams (name, parent)
    VALUES ('Engineering', NULL),
           ('Geschäftstätigkeit', 'Engineering'),
           ('Product', 'Engineering'),
           ('Interns', 'Product'),
           ('Administration', NULL),
           ('Human Resources', 'Administration'),
           ('Finance', 'Administration'),
           ('Marketing', NULL),
           ('Logistics', NULL),
           ('国际化', NULL);

-- List All Hierarchies
SELECT * FROM team_structure ORDER BY path;

-- A specific one
SELECT * FROM team_structure WHERE name = 'Finance';

-- Finding all subteams (deep) of a team
SELECT * FROM team_structure WHERE 'Product' = ANY(path);

-- Analyze
EXPLAIN ANALYZE SELECT * FROM team_structure WHERE 'Product' = ANY(path);
CREATE TABLE public.family (
    name    TEXT
            PRIMARY KEY,
    spouse  TEXT
            REFERENCES public.family (name),
    father  TEXT
            REFERENCES public.family (name),
    mother  TEXT
            REFERENCES public.family (name)
);

CREATE MATERIALIZED VIEW family_tree AS
    WITH RECURSIVE
        father_cte(name, father, father_path) AS (
        SELECT  public.family.name,
                public.family.father,
                ARRAY [public.family.name]
        FROM public.family
        WHERE public.family.father IS NULL
        UNION ALL
        SELECT  public.family.name,
            public.family.father,
            array_append(father_cte.father_path, public.family.name)
        FROM father_cte, public.family
        WHERE public.family.father = father_cte.name
    )
--         mother_cte(name, mother, mother_path) AS (
--         SELECT  public.family.name,
--                 public.family.mother,
--                 ARRAY [public.family.name]
--         FROM public.family
--         WHERE public.family.mother IS NULL
--         UNION ALL
--         SELECT  public.family.name,
--                 public.family.mother,
--                 array_append(mother_cte.mother_path, public.family.name)
--         FROM mother_cte, public.family
--         WHERE public.family.mother = mother_cte.name
--         )
    SELECT * FROM father_cte;
--         (SELECT father_path FROM father_cte) AS nasab_ayah;
--         (SELECT mother_path FROM mother_cte) AS nasab_ibu;


CREATE FUNCTION refresh_family_structure() RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW family_tree;
    RETURN new;
end;
$$;

CREATE TRIGGER trigger_update_family_structure
    AFTER UPDATE OR INSERT OR DELETE OR TRUNCATE
    ON public.family
EXECUTE PROCEDURE refresh_family_structure();

INSERT INTO public.family (name, spouse, father, mother)
VALUES ('Somo Pawiro', 'Kirkinah', NULL, NULL),
       ('Kirkinah', 'Somo Pawiro',NULL, NULL),
       ('Tukino', 'Suyatmi', 'Somo Pawiro', 'Kirkinah'),
       ('Kasiran', 'Fatimah', NULL, NULL),
       ('Fatimah', 'Kasiran', NULL, NULL),
       ('Suyatmi', 'Tukino', 'Kasiran', 'Fatimah'),
       ('Emmy Raraswati', 'Masliansyah', 'Tukino', 'Suyatmi'),
       ('Masran', 'Masrumi', NULL, NULL),
       ('Masrumi', 'Masran', NULL, NULL),
       ('Muhammad Sani', 'Nazeli', 'Masran', 'Masrumi'),
       ('Taher', 'Senah Riani', NULL, NULL),
       ('Senah Riani', 'Taher', NULL, NULL),
       ('Nazeli', 'Muhammad Sani', 'Taher', 'Senah Riani'),
       ('Masliansyah', 'Emmy Raraswati', 'Muhammad Sani', 'Nazeli'),
       ('Thoriq', NULL, 'Masliansyah', 'Emmy Raraswati')
;
SELECT * FROM family;
TRUNCATE TABLE family;
DROP TABLE public.family;
DROP MATERIALIZED VIEW family_tree;
SELECT * FROM family_tree ORDER BY father_path;

DROP TRIGGER trigger_update_family_structure ON public.family;

WITH RECURSIVE
--         family_cte(name, father, mother, path) AS (
            family_cte(name, father, path) AS (
        SELECT  public.family.name,
                public.family.father,
--                 public.family.mother,
                ARRAY [public.family.name]
        FROM public.family
        WHERE public.family.father IS NULL
        UNION ALL
        SELECT  public.family.name,
            public.family.father,
--             public.family.mother,
            array_append(family_cte.path, public.family.name)
        FROM family_cte, public.family
        WHERE public.family.father = family_cte.name
--         AND public.family.mother = family_cte.name
    ),
mother_cte(name, father, path) AS (SELECT public.family.name,
                                          public.family.father,
--                 public.family.mother,
                                          ARRAY [public.family.name]
                                   FROM public.family
                                   WHERE public.family.father IS NULL
                                   UNION ALL
                                   SELECT public.family.name,
                                          public.family.father,
--             public.family.mother,
                                          array_append(family_cte.path, public.family.name)
                                   FROM family_cte,
                                        public.family
                                   WHERE public.family.father = family_cte.name
--         AND public.family.mother = family_cte.name
)
SELECT
(SELECT * FROM family_cte)
;


WITH RECURSIVE
    family_cte (name, spouse, father, mother, path) AS (
        SELECT
            public.family.name,
            public.family.spouse,
                public.family.father,
                public.family.mother,
                ARRAY [concat(family.name, '&', family.spouse)]
        FROM public.family
        WHERE public.family.father IS NULL
        AND public.family.mother IS NULL
        GROUP BY
        UNION ALL
        SELECT
                public.family.name,
                public.family.spouse,
                public.family.father,
                family.mother,
                array_append(family_cte.path, family.name)
        FROM family_cte, public.family
        WHERE public.family.father = family_cte.name
        OR public.family.mother = family_cte.name
    )
SELECT * FROM family_cte;

SELECT
    public.family.name,
    public.family.spouse,
    public.family.father,
    public.family.mother,
    ARRAY [concat(family.name, '&', family.spouse)]
FROM public.family
WHERE public.family.father IS NULL
  AND public.family.mother IS NULL

SELECT
    CONCAT(public.family.name, ' & ', public.family.spouse)
FROM public.family
WHERE public.family.spouse IS NOT NULL
;
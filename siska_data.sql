CREATE OR REPLACE FUNCTION register_user()
   RETURNS TRIGGER
   LANGUAGE PLPGSQL
AS
$$
BEGIN
    INSERT INTO authentication_schema.user_logins (user_id)
    VALUES (NEW.user_id);
   RETURN NEW;
END;
$$

CREATE TRIGGER tr_regis_user
    AFTER INSERT ON person_schema.users
    FOR EACH ROW
    EXECUTE FUNCTION register_user();

INSERT INTO person_schema.users (user_id, nama_depan, jenis_kelamin)
VALUES ('1', 'Somo Pawiro', 'L'),
       ('2', 'Kirkinah', 'P'),
       ('3', 'Tukino', 'L'),
       ('4', 'Kasiran', 'L'),
       ('5', 'Fatimah', 'P'),
       ('6', 'Suyatmi', 'P'),
       ('7', 'Emmy Raraswati', 'P'),
       ('8', 'Masran', 'L'),
       ('9', 'Masrumi', 'P'),
       ('10', 'Muhammad Sani', 'L'),
       ('11', 'Taher', 'L'),
       ('12', 'Senah Riani', 'P'),
       ('13', 'Nazeli', 'L'),
       ('14', 'Masliansyah', 'L'),
       ('15', 'Muhammad Thoriq', 'L')
;


CREATE ROLE user_register WITH LOGIN ENCRYPTED PASSWORD '123';
GRANT SELECT, INSERT
    ON ALL TABLES IN SCHEMA "authentication_schema"
    TO user_register;
GRANT USAGE ON SCHEMA authentication_schema TO user_register;
GRANT USAGE ON SCHEMA person_schema TO user_register;
GRANT USAGE ON SCHEMA person_schema TO relation_activity;
GRANT SELECT, INSERT
    ON person_schema.users
    TO user_register;

CREATE USER user_login WITH ENCRYPTED PASSWORD '123';
GRANT SELECT
    ON TABLE authentication_schema.user_logins
TO user_login;
GRANT SELECT, UPDATE
    ON TABLE authentication_schema.login_activites
TO user_login;

CREATE USER person_update WITH ENCRYPTED PASSWORD '123';
GRANT SELECT
    ON TABLE authentication_schema.user_logins, person_schema.users
TO person_update;
GRANT UPDATE (email, username, password)
ON TABLE authentication_schema.user_logins
TO person_update;
GRANT UPDATE (
    nik, nomor_kk, nama_depan, nama_belakang, nama_panggilan,
    tempat_lahir, tanggal_lahir, jenis_kelamin, status_sipil
    )
ON TABLE person_schema.users
TO person_update;

CREATE USER relation_activity WITH ENCRYPTED PASSWORD '123';
GRANT USAGE ON SCHEMA relation_schema TO relation_activity;
GRANT SELECT, INSERT, DELETE
ON ALL TABLES IN SCHEMA relation_schema
TO relation_activity;
GRANT UPDATE(anak_id, orang_tua_kandung)
ON TABLE relation_schema.silsilah
TO relation_activity;
GRANT UPDATE ON TABLE relation_schema.pernikahan
TO relation_activity;
GRANT SELECT ON TABLE person_schema.users TO relation_activity;


CREATE USER keluarga_update WITH ENCRYPTED PASSWORD '123';
GRANT SELECT
ON TABLE person_schema.users, relation_schema.pernikahan, relation_schema.silsilah
TO keluarga_update;
GRANT UPDATE
ON TABLE relation_schema.pernikahan
TO keluarga_update;
GRANT UPDATE (
    nik, nomor_kk, nama_depan, nama_belakang, nama_panggilan,
    tempat_lahir, tanggal_lahir, jenis_kelamin, status_sipil
    )
ON person_schema.users
TO keluarga_update;
GRANT UPDATE(anak_id, orang_tua_kandung)
ON relation_schema.silsilah
TO keluarga_update;

SELECT silsilah_id, users.nama_depan AS anak,
FROM relation_schema.silsilah
JOIN person_schema.users ON silsilah.anak_id = users.user_id
JOIN relation_schema.pernikahan ON relation_schema.silsilah.orang_tua_kandung = relation_schema.pernikahan.nomor_akta_nikah
;

SELECT relation_schema.pernikahan.nomor_akta_nikah, person_schema.users.nama_depan AS ayah, person_schema.users.nama_depan AS ibu
FROM relation_schema.pernikahan
CROSS JOIN lateral (values (relation_schema.pernikahan.suami_id, '1'), (relation_schema.pernikahan.istri_id, '2'))
AS users(ayah, ibu);

WITH keturunan AS (
    SELECT person_schema.users.nama_depan AS ayah, person_schema.users.nama_depan AS ibu
    FROM relation_schema.pernikahan
    CROSS JOIN person_schema.users;
)

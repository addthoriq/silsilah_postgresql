CREATE SCHEMA authentication_schema;
CREATE SCHEMA person_schema;
CREATE SCHEMA relation_schema;

CREATE TABLE authentication_schema.login_activites (
    user_id CHAR(5) PRIMARY KEY ,
    start_login TIMESTAMP DEFAULT(CURRENT_TIMESTAMP),
    last_login  TIMESTAMP DEFAULT(CURRENT_TIMESTAMP)
);

CREATE TABLE person_schema.users (
    user_id CHAR(5) PRIMARY KEY,
    nik CHAR(16) UNIQUE,
    nomor_kk CHAR(16),
    nama_depan VARCHAR(50) NOT NULL,
    nama_belakang VARCHAR(50),
    nama_panggilan VARCHAR(50),
    tempat_lahir VARCHAR(30),
    tanggal_lahir DATE,
    jenis_kelamin CHAR(1) NOT NULL,
    status_sipil VARCHAR(30)
);

CREATE TABLE authentication_schema.user_logins (
   user_id CHAR(5) PRIMARY KEY,
   email VARCHAR(50) UNIQUE,
   username VARCHAR(10) UNIQUE,
   password VARCHAR(255),
   FOREIGN KEY (user_id) REFERENCES person_schema.users(user_id)
);

CREATE TABLE relation_schema.pernikahan (
    nomor_akta_nikah CHAR(20) PRIMARY KEY,
    suami_id CHAR(5) NOT NULL,
    istri_id CHAR(5) NOT NULL,
    tanggal_nikah DATE NOT NULL,
    tanggal_cerai DATE,
    sub CHAR(3),
    FOREIGN KEY (suami_id) REFERENCES person_schema.users(user_id),
    FOREIGN KEY (istri_id) REFERENCES person_schema.users(user_id)
);

CREATE TABLE relation_schema.silsilah (
    silsilah_id CHAR(30) PRIMARY KEY,
    anak_id CHAR(5),
    orang_tua_kandung CHAR(20) NOT NULL,
    FOREIGN KEY (anak_id) REFERENCES person_schema.users(user_id),
    FOREIGN KEY (orang_tua_kandung) REFERENCES relation_schema.pernikahan(nomor_akta_nikah)
);
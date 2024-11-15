-- Tabla empresa para Postgres
CREATE TABLE contabilidad.empresa (
    E_RFC CHAR(13) NOT NULL,
    E_Nombre CHAR(40) NOT NULL,
    PRIMARY KEY (E_RFC)
);


-- Tabla empresa para MySQL
CREATE TABLE empresa (
    E_RFC CHAR(13) NOT NULL,
    E_Nombre CHAR(40) NOT NULL,
    PRIMARY KEY (E_RFC)
);
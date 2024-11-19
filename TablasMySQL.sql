-- Inicio del script
-- Eliminar BASE DE DATOS y TABLAS si es que existe:
DROP DATABASE IF EXISTS CONTABILIDAD;
CREATE DATABASE CONTABILIDAD;
USE CONTABILIDAD;

DROP TABLE IF EXISTS Movimientos;
DROP TABLE IF EXISTS Polizas, Cuentas, Bitacora;

-- Creación de tabla Cuentas
CREATE TABLE Cuentas (
    C_numCta SMALLINT(3),
    C_numSubCta SMALLINT(1),
    C_nomCta CHAR(30),
    C_nomSubCta CHAR(30),
    PRIMARY KEY (C_numCta, C_numSubCta)
);

-- Creación de tabla Polizas
CREATE TABLE Polizas (
    P_anio SMALLINT(4),
    P_mes SMALLINT(2),
    P_dia SMALLINT(2),
    P_tipo CHAR(1), -- Cambio de Tipo SMALLINT(1) -> CHAR(1)
    P_folio SMALLINT(6),
    P_concepto VARCHAR(40),
    P_hechoPor VARCHAR(40),
    P_revisadoPor VARCHAR(40),
    P_autorizadoPor VARCHAR(40),
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio)
);

-- Creación de tablas Movimientos
CREATE TABLE Movimientos (
    M_P_anio SMALLINT(4) NOT NULL,
    M_P_mes SMALLINT(2) NOT NULL,
    M_P_dia SMALLINT(2) NOT NULL,
    M_P_tipo CHAR(1) NOT NULL,
    M_P_folio SMALLINT(6) NOT NULL,
    M_numMov INT AUTO_INCREMENT UNIQUE,
    M_C_numCta SMALLINT(3) NOT NULL,
    M_C_numSubCta SMALLINT(1) NOT NULL,
    M_monto DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio, M_numMov),

    -- Restricción de claves foráneas
    CONSTRAINT FK_Polizas FOREIGN KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio) REFERENCES Contabilidad.Polizas(P_anio, P_mes, P_tipo, P_folio),
    CONSTRAINT FK_Cuentas FOREIGN KEY (M_C_numCta, M_C_numSubCta) REFERENCES Contabilidad.Cuentas(C_numCta, C_numSubCta),

    -- Restricción de valores permitidos para M_P_tipo
    CONSTRAINT CHK_M_P_tipo CHECK (M_P_tipo IN ('I', 'D', 'E')) --pinche mauricio me caes mal al chile
);




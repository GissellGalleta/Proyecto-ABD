-- Eliminar la base de datos si existe (debes desconectarte primero antes de ejecutar este comando)
-- DROP DATABASE IF EXISTS proyecto_equipo1;
-- CREATE DATABASE proyecto_equipo1;
-- Conéctate a la base de datos recién creada antes de ejecutar las siguientes tablas

-- Cosas útiles:
-- Usuario de Bitácora: auditor, password = auditor

\c proyecto_equipo1;

-- Eliminar Vistas
DROP VIEW IF EXISTS contabilidad.polizas_2023_ingresos, contabilidad.polizas_2010_2020, contabilidad.poliza_diario,
    contabilidad.poliza_egreso, contabilidad.polizas_2020, contabilidad.polizas_2010_2020,
    contabilidad.poliza_ingreso, contabilidad.polizas_2010_2020_egresos;

-- Eliminar tablas
DROP TABLE IF EXISTS contabilidad.Movimientos;
DROP TABLE IF EXISTS contabilidad.Polizas, contabilidad.Cuentas, registros_bitacora.Bitacora;
DROP SCHEMA IF EXISTS contabilidad, registros_bitacora CASCADE ; -- Eliminar DB
CREATE SCHEMA contabilidad;
CREATE SCHEMA registros_bitacora;

-- Creación de Tabla Empresa
CREATE TABLE contabilidad.empresa (
    E_RFC CHAR(13) NOT NULL,
    E_Nombre CHAR(40) NOT NULL,
    PRIMARY KEY (E_RFC)
);

-- Creación de tabla Cuentas
CREATE TABLE contabilidad.Cuentas (
    C_tipoCta SMALLINT,
    C_numSubCta SMALLINT,
    C_nomCta CHAR(30),
    C_nomSubCta CHAR(30),
    PRIMARY KEY (C_tipoCta, C_numSubCta)
);

-- Creación de tabla Polizas
CREATE TABLE contabilidad.Polizas (
    P_anio SMALLINT NOT NULL,
    P_mes SMALLINT NOT NULL,
    P_dia SMALLINT NOT NULL,
    P_tipo CHAR(1), -- Tipo cambiado a CHAR(1)
    P_folio SMALLINT NOT NULL,
    P_concepto VARCHAR(40) NOT NULL,
    P_hechoPor VARCHAR(40) NOT NULL,
    P_revisadoPor VARCHAR(40) NOT NULL,
    P_autorizadoPor VARCHAR(40) NOT NULL,
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio)
);

-- Creación de tabla Movimientos
CREATE TABLE contabilidad.Movimientos (
    M_P_anio SMALLINT NOT NULL,
    M_P_mes SMALLINT NOT NULL,
    M_P_dia SMALLINT NOT NULL,
    M_P_tipo CHAR(1) NOT NULL,
    M_P_folio SMALLINT NOT NULL,
    M_numMov SERIAL UNIQUE,
    M_C_tipoCta SMALLINT NOT NULL,
    M_C_numSubCta SMALLINT NOT NULL,
    M_monto DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio, M_numMov),

    -- Restricción de claves foráneas
    CONSTRAINT FK_Polizas FOREIGN KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio)
        REFERENCES contabilidad.Polizas(P_anio, P_mes, P_tipo, P_folio),
    CONSTRAINT FK_Cuentas FOREIGN KEY (M_C_tipoCta, M_C_numSubCta)
        REFERENCES contabilidad.Cuentas(C_tipoCta, C_numSubCta),

    -- Restricción de valores permitidos para M_P_tipo
    CONSTRAINT CHK_M_P_tipo CHECK (M_P_tipo IN ('I', 'D', 'E'))
);
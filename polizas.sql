CREATE TABLE Polizas (
    P_anio SMALLINT(4),
    P_mes SMALLINT(2),
    P_dia SMALLINT(2),
    P_tipo SMALLINT(1),
    P_folio SMALLINT(6),
    P_concepto VARCHAR(40),
    P_hechoPor VARCHAR(40),
    P_revisadoPor VARCHAR(40),
    P_autorizadoPor VARCHAR(40),
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio)
);

--- postgresql
CREATE TABLE contabilidad.polizas (
    P_anio SMALLINT,
    P_mes SMALLINT,
    P_dia SMALLINT,
    P_tipo CHAR(1),
    P_folio SMALLINT,
    P_concepto VARCHAR(40),
    P_hechoPor VARCHAR(40),
    P_revisadoPor VARCHAR(40),
    P_autorizadoPor VARCHAR(40),
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio)
);
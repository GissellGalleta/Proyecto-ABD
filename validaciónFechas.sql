--PostgreSQL
CREATE TABLE Contabilidad.Polizas (
    P_anio SMALLINT,
    P_mes SMALLINT,
    P_dia SMALLINT,
    P_tipo CHAR(1), -- Tipo cambiado a CHAR(1)
    P_folio SMALLINT, 
    P_concepto VARCHAR(40),
    P_hechoPor VARCHAR(40),
    P_revisadoPor VARCHAR(40),
    P_autorizadoPor VARCHAR(40),
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio),
    -- Restricción CHECK para validar fechas existentes y no futuras
    CONSTRAINT chk_fecha_valida CHECK (
        P_mes BETWEEN 1 AND 12 AND 
        P_dia BETWEEN 1 AND 31 AND 
        -- Validar fecha existente
        (P_dia <= EXTRACT(DAY FROM TO_DATE(P_anio::TEXT || '-' || P_mes::TEXT || '-' || '01', 'YYYY-MM-DD') + INTERVAL '1 MONTH - 1 DAY')) AND
        -- Validar que no sea una fecha futura
        (TO_DATE(P_anio::TEXT || '-' || P_mes::TEXT || '-' || P_dia::TEXT, 'YYYY-MM-DD') <= CURRENT_DATE)
    )
);



-- MySQL

CREATE TABLE Polizas (
    P_anio SMALLINT,
    P_mes TINYINT, -- TINYINT es suficiente para meses (1-12)
    P_dia TINYINT, -- TINYINT es suficiente para días (1-31)
    P_tipo CHAR(1), -- Tipo cambiado a CHAR(1)
    P_folio SMALLINT,
    P_concepto VARCHAR(40),
    P_hechoPor VARCHAR(40),
    P_revisadoPor VARCHAR(40),
    P_autorizadoPor VARCHAR(40),
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio)
);


DELIMITER //

CREATE TRIGGER validar_fecha_poliza
BEFORE INSERT ON Polizas
FOR EACH ROW
BEGIN
    -- Validar que el mes esté en el rango correcto
    IF NEW.P_mes < 1 OR NEW.P_mes > 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El mes debe estar entre 1 y 12';
    END IF;

    -- Validar que el día esté dentro del mes válido
    IF NEW.P_dia < 1 OR NEW.P_dia > DAY(LAST_DAY(CONCAT(NEW.P_anio, '-', LPAD(NEW.P_mes, 2, '0'), '-01'))) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El día no es válido para el mes proporcionado';
    END IF;

    -- Validar que la fecha no sea futura
    IF STR_TO_DATE(CONCAT(NEW.P_anio, '-', LPAD(NEW.P_mes, 2, '0'), '-', LPAD(NEW.P_dia, 2, '0')), '%Y-%m-%d') > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se permiten fechas futuras';
    END IF;
END;
//

DELIMITER ;

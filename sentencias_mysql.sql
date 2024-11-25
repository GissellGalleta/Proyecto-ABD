-- Inicio del script
-- Eliminar BASE DE DATOS y TABLAS si es que existe:
DROP DATABASE IF EXISTS CONTABILIDAD;
CREATE DATABASE CONTABILIDAD;
USE CONTABILIDAD;

DROP VIEW IF EXISTS activos, pasivos, gastos, costos, ingresos, capital;

DROP TABLE IF EXISTS Movimientos;
DROP TABLE IF EXISTS Polizas, Cuentas, Bitacora, empresa;


CREATE TABLE empresa (
    E_RFC CHAR(13) NOT NULL,
    E_Nombre CHAR(40) NOT NULL,
    PRIMARY KEY (E_RFC)
);


CREATE TABLE Cuentas (
    C_numCta SMALLINT(3) NOT NULL,
    C_numSubCta SMALLINT(1) NOT NULL,
    C_nomCta CHAR(30) NOT NULL,
    C_nomSubCta CHAR(30) NOT NULL,
    PRIMARY KEY (C_numCta, C_numSubCta)
);

-- Tabla Polizas
CREATE TABLE Polizas (
    P_anio SMALLINT(4) NOT NULL,
    P_mes SMALLINT(2) NOT NULL,
    P_dia SMALLINT(2) NOT NULL,
    P_tipo CHAR(1) NOT NULL, -- Cambio de Tipo SMALLINT(1) -> CHAR(1)
    P_folio SMALLINT(6) NOT NULL,
    P_concepto VARCHAR(40) NOT NULL,
    P_hechoPor VARCHAR(40) NOT NULL,
    P_revisadoPor VARCHAR(40) NOT NULL,
    P_autorizadoPor VARCHAR(40) NOT NULL,
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio),
    -- Restricción de valores permitidos para M_P_tipo
    CONSTRAINT CHK_P_tipo CHECK (P_tipo IN ('I', 'D', 'E'))
);


-- Tabla Movimientos
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
    CONSTRAINT FK_Cuentas FOREIGN KEY (M_C_numCta, M_C_numSubCta) REFERENCES Contabilidad.Cuentas(C_numCta, C_numSubCta)



);
Drop tablespace bitacora_ts;
CREATE TABLESPACE bitacora_ts
ADD DATAFILE 'C:\\ProyectoBD\\MySQL\\Tablespaces\\bitacora_ts.ibd'
-- ADD DATAFILE 'C:\\bitacora_ts\\bitacora_ts.ibd'
ENGINE = InnoDB;


-- Creación de tabla bitácora
CREATE TABLE bitacora (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
) TABLESPACE bitacora_ts ENGINE=InnoDB;


DELIMITER //
CREATE TRIGGER trigger_insert_cuentas
AFTER INSERT ON Cuentas
FOR EACH ROW
BEGIN
    DECLARE exit HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, inserta en la bitacora el fallo
        INSERT INTO bitacora (accion, detalle)
        VALUES ('INSERT ERROR', CONCAT('El usuario: ', current_user, ', intentó realizar una inserción con cuenta con ID: ', NEW.C_numCta, '-', NEW.C_numSubCta, ', con Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
    END;

    -- Si la inserción es exitosa, ejecuta esta acción
    INSERT INTO bitacora (accion, detalle)
    VALUES ('INSERT', CONCAT('El usuario: ', current_user, ', insertó una cuenta con ID: ', NEW.C_numCta, '-', NEW.C_numSubCta, ', con Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_cuentas
AFTER UPDATE ON Cuentas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE', CONCAT('El usuario: ',current_user,', actualizó la cuenta con ID: ', NEW.C_numCta, '-', NEW.C_numSubCta, ' Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_cuentas
AFTER DELETE ON Cuentas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE', CONCAT('El usuario: ',current_user, ', eliminó la cuenta con ID: ', OLD.C_numCta, '-', OLD.C_numSubCta, ' Nombre: ', OLD.C_nomCta, ' Subcuenta: ', OLD.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_insert_polizas
AFTER INSERT ON Polizas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('INSERT', CONCAT('El usuario ', current_user, ' insertó una póliza con ID: ', NEW.P_anio, '-', NEW.P_mes, '-', NEW.P_tipo, '-', NEW.P_folio, ', Concepto: ', NEW.P_concepto, ', hecho por: ', NEW.P_hechoPor,
               ', revisado por: ', NEW.P_revisadoPor, ', autorizado por: ', NEW.P_autorizadoPor, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_polizas
AFTER UPDATE ON Polizas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE',
        CONCAT('El usuario ', current_user, ' actualizó la póliza con ID: ', NEW.P_anio, '-', NEW.P_mes, '-', NEW.P_tipo, '-', NEW.P_folio, ', Concepto: ', NEW.P_concepto, ', hecho por: ', NEW.P_hechoPor,
               ', revisado por: ', NEW.P_revisadoPor, ', autorizado por: ',NEW.P_autorizadoPor, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_polizas
AFTER DELETE ON Polizas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE',CONCAT('El usuario ', current_user, ' eliminó la póliza con ID: ',OLD.P_anio, '-', OLD.P_mes, '-', OLD.P_tipo, '-', OLD.P_folio,', Concepto: ', OLD.P_concepto, ', hecho por: ', OLD.P_hechoPor,
               ', revisado por: ', OLD.P_revisadoPor, ', autorizado por: ',OLD.P_autorizadoPor, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_insert_movimientos
AFTER INSERT ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('INSERT', CONCAT('El usuario ', current_user, ' insertó un movimiento con ID: ',
               NEW.M_numMov, ', Cuenta: ', NEW.M_C_numCta, '-', NEW.M_C_numSubCta,
               ', Monto: ', NEW.M_monto, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_movimientos
AFTER UPDATE ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE',
        CONCAT('El usuario ', current_user, ' actualizó el movimiento con ID: ',
               NEW.M_numMov, ', Cuenta: ', NEW.M_C_numCta, '-', NEW.M_C_numSubCta,
               ', Monto: ', NEW.M_monto, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_movimientos
AFTER DELETE ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE',
        CONCAT('El usuario ', current_user, ' eliminó el movimiento con ID: ',
               OLD.M_numMov, ', Cuenta: ', OLD.M_C_numCta, '-', OLD.M_C_numSubCta,
               ', Monto: ', OLD.M_monto, ', a fecha de: ', SYSDATE()));
END//

DELIMITER ;
-- PArte inidices
CREATE UNIQUE INDEX idx_Pfolio_unico_anio ON polizas (P_anio, P_folio);

DROP TABLE Movimientos;
CREATE TABLE Movimientos (
    M_P_anio SMALLINT(4) NOT NULL,
    M_P_mes SMALLINT(2) NOT NULL,
    M_P_dia SMALLINT(2) NOT NULL,
    M_P_tipo CHAR(1) NOT NULL,
    M_P_folio SMALLINT(6) NOT NULL,
    M_numMov INT AUTO_INCREMENT,
    M_C_numCta SMALLINT(3) NOT NULL,
    M_C_numSubCta SMALLINT(1) NOT NULL,
    M_monto DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (M_numMov, M_P_anio)
)
PARTITION BY RANGE (M_P_anio) (
    PARTITION Mov2010_2015 VALUES LESS THAN (2015),
    PARTITION Mov2015_2020 VALUES LESS THAN (2020),
    PARTITION Mov2020_2025 VALUES LESS THAN (2025)
);

SELECT PARTITION_NAME, TABLE_NAME, TABLE_SCHEMA
FROM information_schema.PARTITIONS
WHERE TABLE_NAME = 'Movimientos';

-- Insert para Activo y subcategorías
INSERT INTO contabilidad.Cuentas (C_numCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (101, 0, 'Caja', ''),
    (101, 1, 'Caja', 'Efectivo'),
    (102, 0, 'Bancos', ''),
    (102, 1, 'Bancos', 'Bancos Nacionales'),
    (102, 2, 'Bancos', 'Bancos Extrangeros'),
    (103, 0, 'Inversiones', ''),
    (103, 1, 'Inversiones', 'Inversiones Temporales'),
    (103, 2, 'Inversiones', 'Inversiones de fideicomisos'),
    (104, 0, 'Clientes', ''),
    (104, 1, 'Clientes', 'Clientes Nacionales'),
    (104, 2, 'CLientes', 'Clientes Extrangeros'),
    (105, 0, 'Cuentas por cobrar', ''),
    (105, 1, 'Cuentas por cobrar', 'Cuentas Nacionales'),
    (105, 2, 'Cuentas por cobrar', 'Cuentas Extranjeros'),
    (106, 0, 'Propiedades', ''),
    (106, 1, 'Propiedades', 'Terreno'),
    (106, 2, 'Propiedades', 'Edificios'),
    (106, 3, 'Propiedades', 'Equipo de Transporte'),
    (106, 4, 'Propiedades', 'Mobiliario y equipo'),
    (107, 0, 'Herramientas y Seguros', ''),
    (107, 1, 'Herramientas y Seguros', 'Papelería y útiles de oficina'),
    (107, 2, 'Herramientas y Seguros', 'Seguros pagados por adelantado');

-- Insert para Pasivo y subcategorías
INSERT INTO contabilidad.Cuentas (C_numCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (201, 0, 'Proovedores', ''),
    (201, 1, 'Proovedores', 'Proovedores Locales'),
    (201, 2, 'Proovedores', 'Proovedores Extrajeros'),
    (202, 0, 'Cuentas por pagar', ''),
    (202, 1, 'Cuentas por pagar', 'Cuentas Nacionales'),
    (202, 2, 'Cuentas por pagar', 'Cuentas Extranjeros'),
    (203, 0, 'Impuestos por pagar', ''),
    (203, 1, 'Impuestos por pagar', 'IVA por acreditar'),
    (203, 2, 'Impuestos por pagar', 'ISR por acreditar'),
    (204, 0, 'Prestamos', ''),
    (204, 1, 'Prestamos', 'Prestamo Bancario'),
    (204, 2, 'Prestamos', 'Prestamo Empresa');

-- Insert para Capital Contable y subcategorías
INSERT INTO contabilidad.Cuentas (C_numCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (301, 0, 'Capital Suscrito', ''),
    (301, 1, 'Capital Suscrito', 'Capital Social Pagado'),
    (301, 2, 'Capital Suscrito', 'Capital Social No Pagado'),
    (302, 0, 'Reservas de Capital', ''),
    (302, 1, 'Reservas de Capital', 'Reserva legal'),
    (302, 2, 'Reservas de Capital', 'Otra Reresva'),
    (303, 0, 'Resultados acumulados ', ''),
    (303, 1, 'Resultados acumulados', 'Utilidades Retenidad'),
    (303, 2, 'Resultados acumulados', 'Obligaciones Financieras');

-- Insert para Ingreso y subcategorías
INSERT INTO contabilidad.Cuentas (C_numCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (401, 0, 'Ingresos por ventas', ''),
    (401, 1, 'Ingresos por ventas', 'Ventas nacionales'),
    (401, 2, 'Ingresos por ventas', 'Ventas internacionales'),
    (402, 0, 'Otros ingresos', ''),
    (402, 1, 'Otros ingresos', 'Ingresos por interes'),
    (402, 2, 'Otros ingresos', 'Ingresos por dividendos');

-- Insert para Costos y subcategorías
INSERT INTO contabilidad.Cuentas (C_numCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (501, 0, 'Costos de ventas', ''),
    (501, 1, 'Costos de ventas', 'Costo de transporte'),
    (501, 2, 'Costos de ventas', 'Costo de los fletes entrantes'),
    (501, 3, 'Costos de ventas', 'Mano de obra directa');

-- Insert para Gastos y subcategorías
INSERT INTO contabilidad.Cuentas (C_numCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (601, 0, 'Gastos de venta', ''),
    (601, 1, 'Gastos de venta', 'Publicidad'),
    (601, 2, 'Gastos de venta', 'Comisiones de Ventas'),
    (602, 0, 'Gastos administrativos', ''),
    (602, 1, 'Gastos administrativos', 'Pago de Servicios Públicos'),
    (602, 2, 'Gastos administrativos', 'Sueldo de Personal '),
    (602, 3, 'Gastos administrativos', 'Impuestos sobre Sueldos'),
    (602, 4, 'Gastos administrativos', 'Gasto de Energia Electrica'),
    (603, 0, 'Gastos Financieros', ''),
    (603, 1, 'Gastos Financieros', 'Intereses Bancarios'),
    (603, 2, 'Gastos Financieros', 'Cargos por Servicios Bancarios');

-- Inserción Polizas
-- INSERTS POLIZAS // Agregar restrigcion en los polizas diarias pero que solo se pueda ingresar una con la misma fecha
INSERT INTO contabilidad.Polizas
    (P_anio, P_mes, P_dia, P_tipo, P_folio, P_concepto, P_hechoPor, P_revisadoPor, P_autorizadoPor)
VALUES
    (2013, 12, 1, 'I', 1, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2013, 12, 2, 'E', 2, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2013, 12, 3, 'D', 3, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2013, 12, 1, 'I', 4, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2013, 12, 2, 'E', 5, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2017, 12, 1, 'I', 6, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2017, 12, 2, 'E', 7, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2017, 12, 3, 'D', 8, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2017, 12, 1, 'I', 9, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2017, 12, 2, 'E', 10, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2024, 12, 1, 'I', 11, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2024, 12, 2, 'E', 12, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2024, 12, 3, 'D', 13, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2024, 12, 1, 'I', 14, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2024, 12, 2, 'E', 15, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia');

-- Inserción Movimientos: MOV. INGRESO
INSERT INTO contabilidad.Movimientos
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES
    (2013, 12, 1, 'I', 1, 401, 1, 15000),
    (2013, 12, 1, 'I', 4, 401, 1, 15000),
    (2017, 12, 1, 'I', 6, 402, 1, 8000),
    (2017, 12, 1, 'I', 9, 402, 1, 7500),
    (2024, 12, 1, 'I', 11, 402, 2, 6500),
    (2024, 12, 1, 'I', 14, 402, 2, 5000);

-- Costo de Ventas Netas (Costos) MOV. EGRESO
INSERT INTO contabilidad.Movimientos
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES

    (2013, 12, 2, 'E', 2, 501, 1, -1000),
    (2013, 12, 2, 'E', 5, 501, 2, -200),
    (2017, 12, 2, 'E', 7, 501, 3, -350),
    (2017, 12, 2, 'E', 10, 501, 1, -700),
    (2024, 12, 2, 'E', 12, 501, 2, -250),
    (2024, 12, 2, 'E', 15, 501, 3, -750);


-- MOV. DIARIOS
INSERT INTO contabilidad.Movimientos
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES
    (2013, 12, 3, 'D', 3, 601, 2, -8000),
    (2017, 12, 3, 'D', 8, 601, 1, -500),
    (2024, 12, 3, 'D', 13, 602, 1, -100);

-- Consulta de catálogo de cuentas
SELECT 
    CASE 
        WHEN C_numSubCta = 0 THEN CONCAT(C_numCta, '-0')
        ELSE CONCAT(C_numCta, '-', C_numSubCta)
    END AS Codigo,
    CASE 
        WHEN C_numSubCta = 0 THEN C_nomCta
        ELSE C_nomSubCta
    END AS Nombre
FROM contabilidad.cuentas
ORDER BY 
    CAST(C_numCta AS UNSIGNED), 
    CASE 
        WHEN C_numSubCta = 0 THEN 0 ELSE 1 
    END, 
    CAST(C_numSubCta AS UNSIGNED);

SELECT * FROM MOVIMIENTOS PARTITION (Mov2010_2015);
SELECT * FROM MOVIMIENTOS PARTITION (Mov2015_2020);
SELECT * FROM MOVIMIENTOS PARTITION (Mov2020_2025);

DELIMITER $$

CREATE TRIGGER validacionInsert_fk_polizas
BEFORE INSERT ON Movimientos
FOR EACH ROW
BEGIN
    -- Verificar que el año exista
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El año especificado no existe en la tabla Polizas.';
    END IF;

    -- Verificar que el mes exista para el año especificado
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El mes especificado no existe para el año proporcionado en la tabla Polizas.';
    END IF;

    -- Verificar que el tipo de póliza exista para el año y mes especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El tipo de póliza especificado no existe para el año y mes proporcionados en la tabla Polizas.';
    END IF;

    -- Verificar que el folio exista para el año, mes y tipo de póliza especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
          AND P_folio = NEW.M_P_folio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El folio especificado no existe para el año, mes y tipo de póliza proporcionados en tabla Polizas.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER validacionUpdate_fk_polizas
BEFORE UPDATE ON Movimientos
FOR EACH ROW
BEGIN

    -- Verificar que el año exista
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El año especificado no existe en la tabla Polizas.';
    END IF;

    -- Verificar que el mes exista para el año especificado
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El mes especificado no existe para el año proporcionado en la Polizas.';
    END IF;

    -- Verificar que el tipo de póliza exista para el año y mes especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El tipo de póliza especificado no existe para el año y mes proporcionados en la tabla Polizas.';
    END IF;

    -- Verificar que el folio exista para el año, mes y tipo de póliza especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
          AND P_folio = NEW.M_P_folio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El folio especificado no existe para el año, mes y tipo de póliza proporcionados en la tabla Polizas.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER validacionInsert_fk_cuentas
BEFORE INSERT ON Movimientos
FOR EACH ROW
BEGIN
    DECLARE error_message VARCHAR(255); -- Declarar una variable para almacenar el mensaje

    -- Validar si M_C_numCta no existe en la tabla Cuentas
    IF NOT EXISTS (
        SELECT 1
        FROM Cuentas
        WHERE C_numCta = NEW.M_C_numCta
    ) THEN
        SET error_message = CONCAT('Error: El valor de M_C_numCta = ', NEW.M_C_numCta, ' no existe en la tabla Cuentas.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = error_message;
    END IF;

    -- Validar si M_C_numSubCta no existe en combinación con M_C_numCta
    IF NOT EXISTS (
        SELECT 1
        FROM Cuentas
        WHERE C_numCta = NEW.M_C_numCta
          AND C_numSubCta = NEW.M_C_numSubCta
    ) THEN
        SET error_message = CONCAT('Error: La combinación de M_C_numCta = ', NEW.M_C_numCta, ' y M_C_numSubCta = ', NEW.M_C_numSubCta, ' no existe en la tabla Cuentas.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = error_message;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER validacionUpdate_fk_cuentas
BEFORE UPDATE ON Movimientos
FOR EACH ROW
BEGIN
    -- Validar que la combinación de M_C_numCta y M_C_numSubCta exista en la tabla Cuentas
    IF NOT EXISTS (
        SELECT 1
        FROM Cuentas
        WHERE C_numCta = NEW.M_C_numCta
          AND C_numSubCta = NEW.M_C_numSubCta
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La combinación de M_C_numCta y M_C_numSubCta no existe en la tabla Cuentas.';
    END IF;
END$$

DELIMITER ;


CREATE VIEW poliza_ingreso AS
SELECT * FROM polizas WHERE P_tipo = 'I';

CREATE VIEW poliza_egreso AS
SELECT * FROM polizas WHERE P_tipo = 'E';

CREATE VIEW poliza_diario AS
SELECT * FROM polizas WHERE P_tipo = 'D';

-- Segmentación de Cuentas
-- Vista para Activos (Cuentas 100s)
CREATE VIEW contabilidad.activos AS
SELECT
    CONCAT(C_numCta, '-', C_numSubCta) AS Codigo,
    CASE
        WHEN C_numSubCta = 0 THEN C_nomCta
        ELSE C_nomSubCta
    END AS Nombre
FROM contabilidad.cuentas
WHERE C_numCta BETWEEN 100 AND 199;

-- Vista para Pasivos (Cuentas 200s)
CREATE VIEW contabilidad.pasivos AS
SELECT
    CONCAT(C_numCta, '-', C_numSubCta) AS Codigo,
    CASE
        WHEN C_numSubCta = 0 THEN C_nomCta
        ELSE C_nomSubCta
    END AS Nombre
FROM contabilidad.cuentas
WHERE C_numCta BETWEEN 200 AND 299;

-- Vista para Capital (Cuentas 300s)
CREATE VIEW contabilidad.capital AS
SELECT
    CONCAT(C_numCta, '-', C_numSubCta) AS Codigo,
    CASE
        WHEN C_numSubCta = 0 THEN C_nomCta
        ELSE C_nomSubCta
    END AS Nombre
FROM contabilidad.cuentas
WHERE C_numCta BETWEEN 300 AND 399;

-- Vista para Ingresos (Cuentas 400s)
CREATE VIEW contabilidad.ingresos AS
SELECT
    CONCAT(C_numCta, '-', C_numSubCta) AS Codigo,
    CASE
        WHEN C_numSubCta = 0 THEN C_nomCta
        ELSE C_nomSubCta
    END AS Nombre
FROM contabilidad.cuentas
WHERE C_numCta BETWEEN 400 AND 499;

-- Vista para Costos (Cuentas 500s)
CREATE VIEW contabilidad.costos AS
SELECT
    CONCAT(C_numCta, '-', C_numSubCta) AS Codigo,
    CASE
        WHEN C_numSubCta = 0 THEN C_nomCta
        ELSE C_nomSubCta
    END AS Nombre
FROM contabilidad.cuentas
WHERE C_numCta BETWEEN 500 AND 599;

-- Vista para Gastos (Cuentas 600s)
CREATE VIEW contabilidad.gastos AS
SELECT
    CONCAT(C_numCta, '-', C_numSubCta) AS Codigo,
    CASE
        WHEN C_numSubCta = 0 THEN C_nomCta
        ELSE C_nomSubCta
    END AS Nombre
FROM contabilidad.cuentas
WHERE C_numCta BETWEEN 600 AND 699;


-- Creación de usuarios después de generar las tablas correspondientes:
    -- usuario Maestro

DROP USER IF EXISTS 'maestro'@'%';
CREATE USER 'maestro'@'%' IDENTIFIED BY 'maestro';
REVOKE ALL PRIVILEGES on *.* from 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.cuentas To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.polizas To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.empresa To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.movimientos To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.activos to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.capital to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.costos to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.gastos to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.ingresos to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.pasivos to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.poliza_diario to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.poliza_egreso to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.poliza_ingreso to 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.bitacora to 'maestro'@'%';
REVOKE ALL PRIVILEGES ON contabilidad.bitacora from 'maestro'@'%';
FLUSH PRIVILEGES;



-- Creación del usuario Auditor:
DROP USER IF EXISTS 'auditor'@'%';
CREATE USER 'auditor'@'%' IDENTIFIED BY 'auditor';
REVOKE ALL PRIVILEGES ON *.* FROM 'auditor'@'%';
GRANT SELECT ON contabilidad.Bitacora TO 'auditor'@'%';
FLUSH PRIVILEGES;

-- Creación de usuario promedio
DROP USER IF EXISTS 'usuario'@'%';
CREATE USER 'usuario'@'%' IDENTIFIED BY 'usuario';
REVOKE ALL PRIVILEGES ON *.* FROM 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.cuentas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.empresa to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.polizas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.movimientos to 'usuario'@'%';
-- esta sería la versión ya completa
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.activos to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.capital to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.costos to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.gastos to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.ingresos to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.pasivos to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.poliza_diario to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.poliza_egreso to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE ON contabilidad.poliza_ingreso to 'usuario'@'%';
GRANT ALL PRIVILEGES ON contabilidad.bitacora to 'usuario'@'%';
REVOKE ALL PRIVILEGES ON contabilidad.bitacora from 'usuario'@'%';

FLUSH PRIVILEGES;

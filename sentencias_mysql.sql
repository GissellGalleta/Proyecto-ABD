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
--TRIGGER PARA VALIDAR EL CARÁCTER INSERTADO EN P_Tipo de la tabla “Pólizas”
DELIMITER $$
 
CREATE TRIGGER validarInsert_tipo_polizas
BEFORE INSERT ON Polizas
FOR EACH ROW
BEGIN
    -- Verificar que el valor de P_tipo sea válido
    IF NEW.P_tipo NOT IN ('I', 'D', 'E') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Valor no permitido para M_P_tipo. Debe ser I (Ingresos) | D (Diario) | E (Egresos).';
 
    END IF;
END$$

--TRIGGER PARA VALIDAR EL CARÁCTER ACTUALIZADO EN P_Tipo de la tabla “Pólizas”
DELIMITER $$
 
CREATE TRIGGER validarUpdate_tipo_polizas
BEFORE UPDATE ON Polizas
FOR EACH ROW
BEGIN
    -- Verificar que el valor de P_tipo sea válido
    IF NEW.P_tipo NOT IN ('I', 'D', 'E') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Valor no permitido para M_P_tipo. Debe ser I (Ingresos) | D (Diario) | E (Egresos).';
 
    END IF;
END$$

--TRIGGER PARA VALIDAR LA FECHA INGRESADA EN P_Tipo de la tabla “Pólizas”
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

-- PArte inidices
CREATE UNIQUE INDEX idx_Pfolio_unico_anio ON polizas (P_anio, P_folio);

---========PARTICION=======---

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

----CONSULTA PARA MOSTRAR LOS DATOS DENTRO DE CADA PARTICIÓN:
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

----======SEGMENTACIÖN=====------
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

---========BITACORA=====------
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

--=====USUARIOS===-----
--MAESTROS
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


-- Auditor
DROP USER IF EXISTS 'auditor'@'%';
CREATE USER 'auditor'@'%' IDENTIFIED BY 'auditor';
REVOKE ALL PRIVILEGES ON *.* FROM 'auditor'@'%';
GRANT SELECT ON contabilidad.Bitacora TO 'auditor'@'%';
FLUSH PRIVILEGES;

-- Usuario
DROP USER IF EXISTS 'usuario'@'%';
CREATE USER 'usuario'@'%' IDENTIFIED BY 'usuario';
REVOKE ALL PRIVILEGES ON *.* FROM 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.cuentas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.empresa to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.polizas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.movimientos to 'usuario'@'%';
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

---=====INSERTS=====-----
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


--======SELECTS OBJETIVOS ESPECIFICOS =====----
-- CATALOGO CUENTAS
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

---POLIZA POR AÑO, MES, TIPO Y FOLIO
SET @c_poliza_anio = 2024;
SET @c_poliza_mes = 11;
SET @c_poliza_tipo = 'E';
SET @c_poliza_folio = 6;
SELECT * FROM (
    SELECT
        M.M_C_numCta AS numero_cuenta,
        M.M_C_numSubCta AS numero_subcuenta,
        C.C_nomSubCta AS concepto_subcuenta,
 
        CASE 
            WHEN M.M_monto >= 0 THEN M.M_monto
            ELSE 0
        END AS debe,
 
        CASE 
            WHEN M.M_monto < 0 THEN -M.M_monto
            ELSE 0
        END AS haber
 
    FROM 
        Polizas AS P
    JOIN 
        Movimientos AS M ON P.P_anio = M.M_P_anio 
                         AND P.P_mes = M.M_P_mes 
                         AND P.P_dia = M.M_P_dia 
                         AND P.P_tipo = M.M_P_tipo 
                         AND P.P_folio = M.M_P_folio
    JOIN 
        Cuentas AS C ON M.M_C_numCta = C.C_numCta 
                     AND M.M_C_numSubCta = C.C_numSubCta
    WHERE 
        P.P_anio = @c_poliza_anio
        AND P.P_mes = @c_poliza_mes
        AND P.P_tipo = @c_poliza_tipo
        AND P.P_folio = @c_poliza_folio
    ORDER BY 
        M.M_numMov
) AS consulta1
UNION
SELECT 
    '' AS numero_cuenta,
    '' AS numero_subcuenta,
    'Total' AS concepto_subcuenta,
    SUM(CASE 
            WHEN M.M_monto >= 0 THEN M.M_monto
            ELSE 0
        END) AS debe,
    SUM(CASE 
            WHEN M.M_monto < 0 THEN -M.M_monto
            ELSE 0
        END) AS haber
FROM 
    Polizas AS P
JOIN 
    Movimientos AS M ON P.P_anio = M.M_P_anio 
                     AND P.P_mes = M.M_P_mes 
                     AND P.P_dia = M.M_P_dia 
                     AND P.P_tipo = M.M_P_tipo 
                     AND P.P_folio = M.M_P_folio
WHERE 
    P.P_anio = @c_poliza_anio
    AND P.P_mes = @c_poliza_mes
    AND P.P_tipo = @c_poliza_tipo
    AND P.P_folio = @c_poliza_folio
UNION
SELECT
    "Fecha" AS numero_cuenta,
    "Folio" AS numero_subcuenta,
    "Hecho Por" AS concepto_subcuenta,
    "Revisado por" AS debe,
    "Autorizado por" AS haber
FROM 
    Polizas AS P
WHERE 
    P.P_anio = 2023
    AND P.P_mes = 12
    AND P.P_tipo = 'E'
    AND P.P_folio = 9
UNION
    SELECT
        DISTINCT CONCAT(P.P_anio, '-', LPAD(P.P_mes, 2, '0'), '-', LPAD(P.P_dia, 2, '0')) AS numero_cuenta,
        P.P_folio AS numero_subcuenta,
        P.P_hechoPor AS concepto_subcuenta,
        P.P_revisadoPor AS debe,
        P.P_autorizadoPor AS haber
    FROM 
        Polizas AS P
    WHERE 
        P.P_anio = @c_poliza_anio
        AND P.P_mes = @c_poliza_mes
        AND P.P_tipo = @c_poliza_tipo
        AND P.P_folio = @c_poliza_folio;


---BALANCE DE COMPROBACIÓN
SELECT 
    C.C_numCta AS numero_cuenta,
    C.C_NomCta AS nombre_cuenta,
    C.C_nomSubCta AS concepto_subcuenta,
    SUM(CASE  
        WHEN M.M_monto >= 0 THEN M.M_monto
        ELSE 0
    END) AS debe,
    SUM(CASE  
        WHEN M.M_monto < 0 THEN -M.M_monto
        ELSE 0
    END) AS haber,
    SUM(CASE  
        WHEN M.M_monto >= 0 THEN M.M_monto
        ELSE 0
    END) - SUM(CASE  
        WHEN M.M_monto < 0 THEN -M.M_monto
        ELSE 0
    END) AS diferencia,
    CASE  
        WHEN (SUM(CASE WHEN M.M_monto >= 0 THEN M.M_monto ELSE 0 END) -  
              SUM(CASE WHEN M.M_monto < 0 THEN -M.M_monto ELSE 0 END)) > 0  
        THEN 'Deudora'
        WHEN (SUM(CASE WHEN M.M_monto >= 0 THEN M.M_monto ELSE 0 END) -  
              SUM(CASE WHEN M.M_monto < 0 THEN -M.M_monto ELSE 0 END)) < 0  
        THEN 'Acreedora'
        ELSE 'Balanceado'
    END AS tipo
FROM  
    Cuentas AS C
LEFT JOIN  
    Movimientos AS M ON C.C_numCta = M.M_C_numCta AND C.C_numSubCta = M.M_C_numSubCta
GROUP BY 
    C.C_numCta, C.C_NomCta, C.C_nomSubCta
UNION ALL
SELECT
    '' AS numero_cuenta,
    'Total' AS nombre_cuenta,
    '' AS concepto_subcuenta,
    SUM(CASE  
        WHEN M.M_monto >= 0 THEN M.M_monto
        ELSE 0
    END) AS debe,
    SUM(CASE  
        WHEN M.M_monto < 0 THEN -M.M_monto
        ELSE 0
    END) AS haber,
    '' AS diferencia,
    '' AS tipo
FROM
    Cuentas AS C
LEFT JOIN  
Movimientos AS M ON C.C_numCta = M.M_C_numCta AND C.C_numSubCta = M.M_C_numSubCta;


---LIBRO DIARIO
SELECT  
    CONCAT(M.M_P_anio, '-', LPAD(M.M_P_mes, 2, '0'), '-', LPAD(M.M_P_dia, 2, '0')) AS fecha, 
    M.M_C_numCta AS numero_cuenta, 
    C.C_NomCta AS nombre_cuenta, 
    M.M_C_numSubCta AS numero_subcuenta, 
    C.C_nomSubCta AS nombre_subcuenta, 
    CASE  
        WHEN M.M_monto >= 0 THEN M.M_monto 
        ELSE 0 
    END AS debe, 
    CASE  
        WHEN M.M_monto < 0 THEN -M.M_monto 
        ELSE 0 
    END AS haber, 
    P.P_concepto AS concepto 
FROM  
    Movimientos AS M 
JOIN  
    Cuentas AS C ON M.M_C_numCta = C.C_numCta  
                AND M.M_C_numSubCta = C.C_numSubCta 
JOIN  
    Polizas AS P ON M.M_P_anio = P.P_anio  
                AND M.M_P_mes = P.P_mes  
                AND M.M_P_dia = P.P_dia  
                AND M.M_P_tipo = P.P_tipo  
                AND M.M_P_folio = P.P_folio 
UNION ALL
SELECT  
    'Total' AS fecha, 
    '' AS numero_cuenta, 
    '' AS nombre_cuenta, 
    '' AS numero_subcuenta, 
    '' AS nombre_subcuenta, 
    SUM(CASE  
        WHEN M.M_monto >= 0 THEN M.M_monto 
        ELSE 0 
    END) AS debe, 
    SUM(CASE  
        WHEN M.M_monto < 0 THEN -M.M_monto 
        ELSE 0 
    END) AS haber, 
    '' AS concepto 
FROM  
    Movimientos AS M 
JOIN  
    Cuentas AS C ON M.M_C_numCta = C.C_numCta  
                AND M.M_C_numSubCta = C.C_numSubCta 
JOIN  
    Polizas AS P ON M.M_P_anio = P.P_anio  
                AND M.M_P_mes = P.P_mes  
                AND M.M_P_dia = P.P_dia  
                AND M.M_P_tipo = P.P_tipo  
                AND M.M_P_folio = P.P_folio 
GROUP BY
    'Total'
ORDER BY  
    fecha, numero_cuenta, numero_subcuenta;

---BALANCE GENERAL 
SELECT
    ' ' AS Categoria,
    CONCAT('GRUPO ', E_Nombre, ' SA de CV') AS Cuenta,
    '' AS SubCuenta,
    '' AS Total
FROM
    contabilidad.Empresa
WHERE
    E_Nombre = 'CICE'
UNION ALL
SELECT
    ' ' AS Categoria,
    CONCAT('Al ',
           DATE_FORMAT(LAST_DAY(STR_TO_DATE(CONCAT(2023, '-', 12, '-01'), '%Y-%m-%d')), '%d de %M del %Y')
    ) AS Cuenta,
    '' AS SubCuenta,
    '' AS Total
FROM
    contabilidad.empresa
WHERE
    E_Nombre = 'CICE'
 
UNION ALL
 SELECT
    ' ' AS Categoria,
    ' BALANCE GENERAL' AS Cuenta,
    '' AS SubCuenta,
    '' AS Total
FROM
    contabilidad.empresa
WHERE
    E_Nombre = 'CICE'
UNION ALL
SELECT
    'Activos' AS Categoria,
    C_nomCta AS Cuenta,
    C_nomSubCta AS SubCuenta,
    SUM(M_monto) AS Total
FROM
    contabilidad.movimientos
INNER JOIN
    contabilidad.cuentas
ON
    Movimientos.M_C_numCta = Cuentas.C_numCta
AND
    Movimientos.M_C_numSubCta = Cuentas.C_numSubCta
WHERE
    Cuentas.C_numCta BETWEEN 101 AND 199 
    AND M_P_anio = 2023
    AND M_P_mes = 12
    AND M_P_dia BETWEEN 1 AND 31 
GROUP BY
    C_nomCta, C_nomSubCta
UNION ALL
SELECT
    'Pasivos' AS Categoria,
    C_nomCta AS Cuenta,
    C_nomSubCta AS SubCuenta,
    SUM(M_monto) AS Total
FROM
    contabilidad.movimientos
INNER JOIN
    contabilidad.cuentas
ON
    Movimientos.M_C_numCta = Cuentas.C_numCta
AND
    Movimientos.M_C_numSubCta = Cuentas.C_numSubCta
WHERE
    Cuentas.C_numCta BETWEEN 201 AND 299 
    AND M_P_anio = 2023
    AND M_P_mes = 12
    AND M_P_dia BETWEEN 1 AND 31 
GROUP BY
    C_nomCta, C_nomSubCta
UNION ALL
SELECT
    'Capital' AS Categoria,
    C_nomCta AS Cuenta,
    C_nomSubCta AS SubCuenta,
    SUM(M_monto) AS Total
FROM
    contabilidad.movimientos
INNER JOIN
    contabilidad.cuentas
ON
    Movimientos.M_C_numCta = Cuentas.C_numCta
AND
    Movimientos.M_C_numSubCta = Cuentas.C_numSubCta
WHERE
    Cuentas.C_numCta BETWEEN 301 AND 399 
    AND M_P_anio = 2023
    AND M_P_mes = 12
    AND M_P_dia BETWEEN 1 AND 31 
GROUP BY
    C_nomCta, C_nomSubCta
UNION ALL
SELECT
    'Totales Generales' AS Categoria,
    'Total Activos' AS Cuenta,
    '' AS SubCuenta,
    SUM(M_monto) AS Total
FROM
    Movimientos
INNER JOIN
    contabilidad.cuentas
ON
    Movimientos.M_C_numCta = Cuentas.C_numCta
AND
    Movimientos.M_C_numSubCta = Cuentas.C_numSubCta
WHERE
    Cuentas.C_numCta BETWEEN 101 AND 199 
    AND M_P_anio = 2023
    AND M_P_mes = 12
    AND M_P_dia BETWEEN 1 AND 31 
UNION ALL
SELECT
    'Totales Generales' AS Categoria,
    'Total Pasivos + Capital' AS Cuenta,
    '' AS SubCuenta,
    SUM(M_monto) AS Total
FROM
    contabilidad.movimientos
INNER JOIN
    contabilidad.cuentas
ON
    Movimientos.M_C_numCta = Cuentas.C_numCta
AND
    Movimientos.M_C_numSubCta = Cuentas.C_numSubCta
WHERE
    Cuentas.C_numCta BETWEEN 201 AND 399 
    AND M_P_anio = 2023
    AND M_P_mes = 12
    AND M_P_dia BETWEEN 1 AND 31;

-- Inicio del script
-- Eliminar BASE DE DATOS y TABLAS si es que existe:
DROP DATABASE IF EXISTS CONTABILIDAD;
CREATE DATABASE CONTABILIDAD;
USE CONTABILIDAD;

DROP VIEW IF EXISTS activos, pasivos, gastos, costos, ingresos, capital;

DROP TABLE IF EXISTS Movimientos;
DROP TABLE IF EXISTS Polizas, Cuentas, Bitacora;


-- Tabla empresa para MySQL
CREATE TABLE empresa (
    E_RFC CHAR(13) NOT NULL,
    E_Nombre CHAR(40) NOT NULL,
    PRIMARY KEY (E_RFC)
);

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
    CONSTRAINT CHK_M_P_tipo CHECK (M_P_tipo IN ('I', 'D', 'E'))
);

-- Creación de tabla bitácora
CREATE TABLE bitacora (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
);


-- Creación de usuarios después de generar las tablas correspondientes:
    -- usuario Maestro
-- CREATE USER 'maestro'@'%' IDENTIFIED BY 'maestro';
REVOKE ALL PRIVILEGES on *.* from 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.cuentas To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.polizas To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.empresa To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.movimientos To 'maestro'@'%';

-- Creación del usuario Auditor:
-- CREATE USER 'auditor'@'%' IDENTIFIED BY 'auditor';
GRANT SELECT ON contabilidad.Bitacora TO 'auditor'@'%';
REVOKE ALL PRIVILEGES ON *.* FROM 'auditor'@'%';

-- Creación de usuario promedio
-- CREATE USER 'usuario'@'%' IDENTIFIED BY 'usuario';
REVOKE ALL PRIVILEGES ON *.* FROM 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.cuentas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.empresa to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.polizas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.movimientos to 'usuario'@'%';
FLUSH PRIVILEGES;


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

-- Inserción de datos:
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
---INSERTS POLIZAS // Agregar restrigcion en los polizas diarias pero que solo se pueda ingresar una con la misma fecha
INSERT INTO contabilidad.Polizas 
    (P_anio, P_mes, P_dia, P_tipo, P_folio, P_concepto, P_hechoPor, P_revisadoPor, P_autorizadoPor)
VALUES 
    (2023, 12, 1, 'I', 8, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 2, 'E', 9, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 3, 'E', 11, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 6, 'E', 13, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 3, 'D', 10, 'Póliza de diario diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 4, 'I', 12, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 6, 'I', 7, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 12, 5, 'E', 5, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 12, 6, 'D', 6, 'Póliza de diario diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 11, 3, 'D', 3, 'Póliza de diario diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 11, 4, 'I', 4, 'Póliza de ingresos noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2021, 11, 5, 'E', 1, 'Póliza de egresos noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2021, 11, 6, 'D', 2, 'Póliza de diario noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia');

-- Inserción Movimientos:
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 1, 'I', 8, 401, 1, 15000), -- Ventas nacionales (positivo)
    (2023, 12, 1, 'I', 8, 401, 1, 15000), -- Ventas nacionales (positivo)
    (2023, 12, 1, 'I', 8, 401, 2, 2000); -- Ventas internacionales (positivo)

-- Costo de Ventas Netas (Costos)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    
    (2023, 12, 2, 'E', 9, 501, 1, -1000), -- Costo de transporte (negativo)
    (2023, 12, 2, 'E', 9, 501, 2, -200), -- Costo de los fletes entrantes (negativo)
    (2023, 12, 3, 'E', 11, 501, 3, -300); -- Mano de obra directa (negativo)

-- Gastos de Operación (Costos de venta y administración)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 2, 'E', 9, 601, 2, -8000), -- Comisiones de venta (negativo)
    (2023, 12, 2, 'E', 9, 601, 1, -500), -- Publicidad (negativo)
    (2023, 12, 6, 'E', 13, 602, 1, -100),  -- Gasto de Servicios Públicos (negativo)
    (2023, 12, 3, 'E', 11, 602, 4, -350), -- Energía eléctrica (negativo)
    (2023, 12, 6, 'E', 13, 602, 3, -1000), -- Impuestos sobre sueldos (negativo)
    (2023, 12, 3, 'E', 11, 602, 2, -5000); -- Sueldos de personal (negativo)

-- Costo Integral de Financiamiento // pendiente de ingresar
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 11, 'E', 14, 6300, 1, -5550),    -- Interés bancario (negativo)
    (2023, 12, 12, 'I', 15, 6400, 1, 12000),    -- Utilidad bancaria (positivo)
    (2023, 12, 13, 'E', 16, 6300, 2, -4500);    -- Comisiones bancarias (negativo)

-- Devoluciones y Descuentos (Egresos)  //pendiente de ingresar
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2022, 11, 5 'E', 4, 4100, 1, -200), -- Devolución sobre ventas (negativo)
    (2022, 11, 5, 'E', 5, 4100, 2, -500); -- Descuento sobre ventas (negativo)




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



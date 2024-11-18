-- Inicio del script
-- Eliminar BASE DE DATOS y TABLAS si es que existe:
DROP DATABASE IF EXISTS CONTABILIDAD;
CREATE DATABASE CONTABILIDAD;
USE CONTABILIDAD;

DROP TABLE IF EXISTS Movimientos;
DROP TABLE IF EXISTS Polizas, Cuentas, Bitacora;


-- Creación de tabla Cuentas
CREATE TABLE Cuentas (
    C_tipoCta SMALLINT(3),
    C_numSubCta SMALLINT(1),
    C_nomCta CHAR(30),
    C_nomSubCta CHAR(30),
    PRIMARY KEY (C_tipoCta, C_numSubCta)
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
    M_C_tipoCta SMALLINT(3) NOT NULL,
    M_C_numSubCta SMALLINT(1) NOT NULL,
    M_monto DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio, M_numMov),

    -- Restricción de claves foráneas
    CONSTRAINT FK_Polizas FOREIGN KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio) REFERENCES Contabilidad.Polizas(P_anio, P_mes, P_tipo, P_folio),
    CONSTRAINT FK_Cuentas FOREIGN KEY (M_C_tipoCta, M_C_numSubCta) REFERENCES Contabilidad.Cuentas(C_tipoCta, C_numSubCta),

    -- Restricción de valores permitidos para M_P_tipo
    CONSTRAINT CHK_M_P_tipo CHECK (M_P_tipo IN ('I', 'D', 'E')),
);


-- Cuenta Bitácora
CREATE TABLE bitacora (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
);

DELIMITER //

DELIMITER //

CREATE TRIGGER trigger_insert_cuentas
AFTER INSERT ON Cuentas
FOR EACH ROW
BEGIN
    DECLARE exit HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, inserta en la bitacora el fallo
        INSERT INTO bitacora (accion, detalle)
        VALUES ('INSERT ERROR', CONCAT('El usuario: ', current_user, ', intentó realizar una inserción con cuenta con ID: ', NEW.C_tipoCta, '-', NEW.C_numSubCta, ', con Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
    END;

    -- Si la inserción es exitosa, ejecuta esta acción
    INSERT INTO bitacora (accion, detalle)
    VALUES ('INSERT', CONCAT('El usuario: ', current_user, ', insertó una cuenta con ID: ', NEW.C_tipoCta, '-', NEW.C_numSubCta, ', con Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_cuentas
AFTER UPDATE ON Cuentas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE', CONCAT('El usuario: ',current_user,', actualizó la cuenta con ID: ', NEW.C_tipoCta, '-', NEW.C_numSubCta, ' Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_cuentas
AFTER DELETE ON Cuentas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE', CONCAT('El usuario: ',current_user, ', eliminó la cuenta con ID: ', OLD.C_tipoCta, '-', OLD.C_numSubCta, ' Nombre: ', OLD.C_nomCta, ' Subcuenta: ', OLD.C_nomSubCta, ', a fecha de: ', SYSDATE()));
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
               NEW.M_numMov, ', Cuenta: ', NEW.M_C_tipoCta, '-', NEW.M_C_numSubCta,
               ', Monto: ', NEW.M_monto, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_movimientos
AFTER UPDATE ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE',
        CONCAT('El usuario ', current_user, ' actualizó el movimiento con ID: ',
               NEW.M_numMov, ', Cuenta: ', NEW.M_C_tipoCta, '-', NEW.M_C_numSubCta,
               ', Monto: ', NEW.M_monto, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_movimientos
AFTER DELETE ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE',
        CONCAT('El usuario ', current_user, ' eliminó el movimiento con ID: ',
               OLD.M_numMov, ', Cuenta: ', OLD.M_C_tipoCta, '-', OLD.M_C_numSubCta,
               ', Monto: ', OLD.M_monto, ', a fecha de: ', SYSDATE()));
END//

DELIMITER ;


-- Inserción de datos
-- Inserción cuenta
INSERT INTO Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
(101, 1, 'Activo', 'Caja y Bancos'),
(101, 2, 'Activo', 'Cuentas por Cobrar'),
(101, 3, 'Activo', 'Inventarios'),
(101, 4, 'Activo', 'Activos Fijos'),
(101, 5, 'Activo', 'Inversiones'),
(102, 1, 'Pasivo', 'Cuentas por Pagar'),
(102, 2, 'Pasivo', 'Proveedores'),
(102, 3, 'Pasivo', 'Acreedores Diversos'),
(102, 4, 'Pasivo', 'Préstamos Bancarios'),
(102, 5, 'Pasivo', 'Obligaciones'),
(201, 1, 'Capital', 'Capital Social'),
(201, 2, 'Capital', 'Resultados Acumulados'),
(201, 3, 'Capital', 'Reserva Legal'),
(202, 1, 'Ingresos', 'Ventas'),
(202, 2, 'Ingresos', 'Ingresos Diversos'),
(203, 1, 'Costos', 'Costo de Ventas'),
(203, 2, 'Costos', 'Costos de Producción'),
(204, 1, 'Gastos', 'Gastos Administrativos'),
(204, 2, 'Gastos', 'Gastos de Ventas'),
(204, 3, 'Gastos', 'Gastos Financieros');
-- Inserción erronea
-- (101,1,'Activo_mal','Caja y Bancos');

    -- Ejemplo inserción:
--    INSERT INTO Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
  --  (205, 1, 'Activo', 'Caja y Bancos');

-- Inserción Polizas
INSERT INTO Polizas (P_anio, P_mes, P_dia, P_tipo, P_folio, P_concepto, P_hechoPor, P_revisadoPor, P_autorizadoPor) VALUES
(2023, 1, 15, 'I', 1001, 'Ingreso por venta', 'Carlos Pérez', 'Ana López', 'Juan Martínez'),
(2023, 2, 10, 'E', 1002, 'Pago a proveedores', 'María García', 'Pedro Sánchez', 'Laura Gómez'),
(2023, 3, 20, 'D', 1003, 'Ajuste contable', 'Jorge Díaz', 'Sofía Fernández', 'Roberto Castro'),
(2024, 4, 5, 'I', 1004, 'Venta de activos', 'Claudia Ortiz', 'Lucía Hernández', 'José Ramírez'),
(2024, 5, 12, 'E', 1005, 'Pago de servicios', 'Miguel Torres', 'Carmen Morales', 'David Romero'),
(2024, 6, 25, 'D', 1006, 'Ajuste de inventario', 'Raúl Herrera', 'Sara Jiménez', 'Tomás Vega'),
(2022, 7, 8, 'I', 1007, 'Cobro de cuentas', 'Elena Vázquez', 'Manuel Ríos', 'Diana Salazar'),
(2022, 8, 18, 'E', 1008, 'Gastos de viaje', 'Pablo Ruiz', 'Gloria Campos', 'Isabel Flores'),
(2022, 9, 30, 'D', 1009, 'Ajuste de cierre', 'Daniel García', 'Verónica Medina', 'Oscar Navarro'),
(2021, 10, 22, 'I', 1010, 'Ingreso extraordinario', 'Luis Álvarez', 'Eva Paredes', 'Hugo León'),
(2021, 11, 11, 'E', 1011, 'Pago de nómina', 'Adriana Núñez', 'Victor Silva', 'Ricardo Montes'),
(2021, 12, 3, 'D', 1012, 'Depreciación', 'Fernando Vargas', 'Teresa Cruz', 'Paola Méndez'),
(2023, 1, 6, 'I', 10013, 'Recuperación de cartera', 'Marta Reyes', 'Eduardo Santos', 'Ángela Peña'),
(2023, 2, 27, 'E', 1014, 'Compra de insumos', 'Andrés Robles', 'Felicia Valencia', 'Clara Cabrera'),
(2024, 3, 14, 'D', 1015, 'Corrección de saldo', 'Gabriel Suárez', 'Rosa Villanueva', 'Emilio Correa'),
(2024, 4, 19, 'I', 1016, 'Pago por servicios', 'Patricia Morales', 'José Luis Domínguez', 'Liliana Soto'),
(2024, 5, 2, 'E', 1017, 'Mantenimiento de equipo', 'Rodrigo Fuentes', 'Monica Lozano', 'Samuel Aguirre'),
(2022, 6, 7, 'D', 1018, 'Rectificación de cuentas', 'Julieta Ramírez', 'Arturo Palacios', 'Esteban Salinas'),
(2022, 7, 16, 'I', 1019, 'Venta al contado', 'Francisco Sánchez', 'Lorena Vargas', 'Berenice Tapia'),
(2022, 8, 23, 'E', 1020, 'Reembolso de gastos', 'Alberto Espinoza', 'Leticia Carrillo', 'Natalia Domínguez');
-- Inserción erronea
-- (2023, 1, 15, 'I', 1001, 'Ingreso por venta', 'Carlos Pérez', 'Ana López', 'Juan Martínez');

-- Inserción Movimientos:
INSERT INTO Movimientos (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto) VALUES
(2023, 1, 15, 'I', 1001, 101, 1, 1500.00),  -- Ingreso por venta
(2023, 2, 10, 'E', 1002, 102, 2, 300.00),   -- Pago a proveedores
(2023, 3, 20, 'D', 1003, 101, 3, 200.00),   -- Ajuste contable
(2024, 4, 5, 'I', 1004, 101, 4, 5000.00),   -- Venta de activos
(2024, 5, 12, 'E', 1005, 102, 1, 1200.00),  -- Pago de servicios
(2024, 6, 25, 'D', 1006, 101, 5, 750.00),   -- Ajuste de inventario
(2022, 7, 8, 'I', 1007, 101, 1, 800.00),    -- Cobro de cuentas
(2022, 8, 18, 'E', 1008, 102, 3, 950.00),   -- Gastos de viaje
(2022, 9, 30, 'D', 1009, 101, 2, 430.00),   -- Ajuste de cierre
(2021, 10, 22, 'I', 1010, 101, 2, 3000.00);
-- Inserción erronea
-- (2021, 10, 22, 'I', 1010, 101, 2, 3000.00);  -- Ingreso extraordinario


-- Actualización de información
-- Segmentación
-- Segmentación por dato fijo
CREATE VIEW polizas_2020 AS
    SELECT * FROM polizas WHERE P_anio = 2020;

-- Segmentación por rangos
CREATE VIEW polizas_2010_2020 AS
    SELECT * FROM polizas WHERE P_anio BETWEEN 2010 AND 2020;

-- Segmentación por tipos
CREATE VIEW poliza_ingreso AS
    SELECT * FROM polizas WHERE P_tipo = 'I';

CREATE VIEW poliza_egreso AS
    SELECT * FROM polizas WHERE P_tipo = 'E';

CREATE VIEW poliza_diario AS
    SELECT * FROM polizas WHERE P_tipo = 'D';

-- Segmentación por vistas combinadas
    -- Año en específico
CREATE VIEW polizas_2023_ingresos AS
    SELECT * FROM polizas WHERE P_anio = 2023 AND P_tipo = 'I';
    -- Por rango de años
CREATE VIEW polizas_2010_2020_egresos AS
    SELECT * FROM polizas
        WHERE P_anio BETWEEN 2010 AND 2020
            AND P_tipo = 'E';


-- CREATE USER 'auditor'@'localhost' IDENTIFIED BY 'auditor';
GRANT SELECT ON contabilidad.Bitacora TO 'auditor'@'%';
REVOKE ALL PRIVILEGES ON *.* FROM 'auditor'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'auditor'@'%';
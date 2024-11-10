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

    -- Restricción para asegurar que M_monto sea positivo
    CONSTRAINT CHK_M_monto CHECK (M_monto >= 0)
);


-- Cuenta Bitácora
CREATE TABLE bitacora (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
);

DELIMITER //

CREATE PROCEDURE generar_triggers_bitacoras()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE nombre_tabla VARCHAR(255);
    DECLARE cursor_tablas CURSOR FOR
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor_tablas;

    repetir: LOOP
        FETCH cursor_tablas INTO nombre_tabla;
        IF done THEN
            LEAVE repetir;
        END IF;

        -- Crear trigger para INSERT
        SET @insert_trigger = CONCAT('
            CREATE TRIGGER ', nombre_tabla, '_insert AFTER INSERT ON ', nombre_tabla, '
            FOR EACH ROW
            BEGIN
                INSERT INTO bitacora (accion, detalle)
                VALUES ("INSERT", CONCAT("El usuario ", USER(), " el día ", DATE_FORMAT(NOW(), "%d/%m/%Y"),
                ", creó un registro en la tabla: ', nombre_tabla, ' con ID: ", NEW.id));
            END;');
        PREPARE stmt FROM @insert_trigger;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Crear trigger para UPDATE
        SET @update_trigger = CONCAT('
            CREATE TRIGGER ', nombre_tabla, '_update AFTER UPDATE ON ', nombre_tabla, '
            FOR EACH ROW
            BEGIN
                INSERT INTO bitacora (accion, detalle)
                VALUES ("UPDATE", CONCAT("El usuario ", USER(), " el día ", DATE_FORMAT(NOW(), "%d/%m/%Y"),
                ", modificó un registro en la tabla: ', nombre_tabla, ' con ID: ", NEW.id));
            END;');
        PREPARE stmt FROM @update_trigger;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Crear trigger para DELETE
        SET @delete_trigger = CONCAT('
            CREATE TRIGGER ', nombre_tabla, '_delete AFTER DELETE ON ', nombre_tabla, '
            FOR EACH ROW
            BEGIN
                INSERT INTO bitacora (accion, detalle)
                VALUES ("DELETE", CONCAT("El usuario ", USER(), " el día ", DATE_FORMAT(NOW(), "%d/%m/%Y"),
                ", borró un registro en la tabla: ', nombre_tabla, ' con ID: ", OLD.id));
            END;');
        PREPARE stmt FROM @delete_trigger;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE cursor_tablas;
END //

CREATE PROCEDURE generar_triggers_tipo()
BEGIN
    -- Declaramos las variables y el cursor
    DECLARE done INT DEFAULT 0;
    DECLARE nombre_tabla VARCHAR(255);
    DECLARE cursor_tablas CURSOR FOR
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor_tablas;

    repetir: LOOP
        FETCH cursor_tablas INTO nombre_tabla;
        IF done THEN
            LEAVE repetir;
        END IF;

        -- Crear trigger para INSERT en Polizas (validación de M_P_Tipo)
        IF nombre_tabla = 'Polizas' THEN
            SET @insert_trigger = CONCAT('
                CREATE TRIGGER ', nombre_tabla, '_insert AFTER INSERT ON ', nombre_tabla, '
                FOR EACH ROW
                BEGIN
                    IF NOT (NEW.P_tipo IN ("I", "D", "E")) THEN
                        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El valor de P_tipo debe ser "I", "D" o "E".";
                    END IF;
                END;');
            PREPARE stmt FROM @insert_trigger;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;

        -- Crear trigger para UPDATE en Polizas (validación de P_Tipo)
        IF nombre_tabla = 'Polizas' THEN
            SET @update_trigger = CONCAT('
                CREATE TRIGGER ', nombre_tabla, '_update AFTER UPDATE ON ', nombre_tabla, '
                FOR EACH ROW
                BEGIN
                    IF NOT (NEW.P_tipo IN ("I", "D", "E")) THEN
                        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El valor de P_tipo debe ser "I", "D" o "E".";
                    END IF;
                END;');
            PREPARE stmt FROM @update_trigger;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;

        -- Crear trigger para INSERT en Movimientos (validación de M_P_Tipo)
        IF nombre_tabla = 'Movimientos' THEN
            SET @insert_trigger = CONCAT('
                CREATE TRIGGER ', nombre_tabla, '_insert AFTER INSERT ON ', nombre_tabla, '
                FOR EACH ROW
                BEGIN
                    IF NOT (NEW.M_P_tipo IN ("I", "D", "E")) THEN
                        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El valor de M_P_tipo debe ser "I", "D" o "E".";
                    END IF;
                END;');
            PREPARE stmt FROM @insert_trigger;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;

        -- Crear trigger para UPDATE en Movimientos (validación de M_P_Tipo)
        IF nombre_tabla = 'Movimientos' THEN
            SET @update_trigger = CONCAT('
                CREATE TRIGGER ', nombre_tabla, '_update AFTER UPDATE ON ', nombre_tabla, '
                FOR EACH ROW
                BEGIN
                    IF NOT (NEW.M_P_tipo IN ("I", "D", "E")) THEN
                        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El valor de M_P_tipo debe ser "I", "D" o "E".";
                    END IF;
                END;');
            PREPARE stmt FROM @update_trigger;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;

    END LOOP;

    CLOSE cursor_tablas;
END //

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
(2021, 10, 22, 'I', 1010, 101, 2, 3000.00);  -- Ingreso extraordinario


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





-- Cuenta Bitácora
CREATE TABLE bitacora (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
);

DELIMITER //

DELIMITER //




-- Inserción de datos

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
(2023, 1, 6, 'I', 1013, 'Recuperación de cartera', 'Marta Reyes', 'Eduardo Santos', 'Ángela Peña'),
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
INSERT INTO Movimientos (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto) VALUES
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
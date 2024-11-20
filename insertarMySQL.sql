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
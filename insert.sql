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
    (501, 1, 'Costos de ventas', 'Ventas nacionales'),
    (501, 2, 'Costos de ventas', 'Ventas internacionales');

-- Insert para Gastos y subcategorías
INSERT INTO contabilidad.Cuentas (C_numCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (601, 0, 'Gastos de venta', ''),
    (601, 1, 'Gastos de venta', 'Publicidad y Marketing'),
    (601, 2, 'Gastos de venta', 'Comisiones de Ventas'),
    (602, 0, 'Gastos administrativos', ''),
    (602, 1, 'Gastos administrativos', 'Pago de Servicios Públicos'),
    (602, 2, 'Gastos administrativos', 'Sueldo de Personal '),
    (603, 0, 'Gastos Financieros', ''),
    (603, 1, 'Gastos Financieros', 'Intereses Bancarios'),
    (603, 2, 'Gastos Financieros', 'Cargos por Servicios Bancarios');

---INSERTS POLIZAS
INSERT INTO contabilidad.Polizas 
    (P_anio, P_mes, P_dia, P_tipo, P_folio, P_concepto, P_hechoPor, P_revisadoPor, P_autorizadoPor)
VALUES 
    (2023, 12, 1, 'I', 1, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 2, 'E', 1, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 3, 'D', 1, 'Póliza de diario diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 11, 1, 'I', 1, 'Póliza de ingresos noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 11, 2, 'E', 1, 'Póliza de egresos noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 11, 3, 'D', 1, 'Póliza de diario noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia');


--- Insert en MOVIMIENTOS

-- Ventas (Ingresos)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 1, 'I', 1, 400, 1, 12000000.00), -- Ventas generales (positivo)
    (2023, 12, 2, 'I', 2, 4000, 2, 3000000.00);  -- Ingreso adicional (positivo)

-- Devoluciones y Descuentos (Egresos)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 3, 'E', 3, 4100, 1, -200000.00), -- Devolución sobre ventas (negativo)
    (2023, 12, 4, 'E', 4, 4100, 2, -500000.00); -- Descuento sobre ventas (negativo)

-- Costo de Ventas Netas (Costos)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 5, 'E', 5, 5000, 1, -200000.00), -- Costo de mercadería (negativo)
    (2023, 12, 6, 'E', 6, 5000, 2, -150000.00), -- Costo de transporte (negativo)
    (2023, 12, 7, 'E', 7, 5000, 3, -190000.00); -- Costo de almacenamiento (negativo)

-- Gastos de Operación (Costos de venta y administración)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 8, 'E', 8, 6000, 1, -1200000.00), -- Sueldos y salarios (negativo)
    (2023, 12, 9, 'E', 9, 6200, 1, -800000.00),  -- Sueldos y salarios administrativos (negativo)
    (2023, 12, 10, 'E', 10, 6200, 2, -400000.00); -- Energía eléctrica (negativo)

-- Costo Integral de Financiamiento
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 11, 'E', 11, 6300, 1, -5550.00),    -- Interés bancario (negativo)
    (2023, 12, 12, 'I', 12, 6400, 1, 12000.00),    -- Utilidad bancaria (positivo)
    (2023, 12, 13, 'E', 13, 6300, 2, -4500.00);    -- Comisiones bancarias (negativo)

-- Ingresos y Egresos por Partidas Extraordinarias
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 14, 'I', 14, 7000, 1, 6000.00),    -- Otros ingresos extraordinarios (positivo)
    (2023, 12, 15, 'E', 15, 6500, 1, -6000.00);   -- Otros gastos extraordinarios (negativo)

-- Impuestos
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 16, 'E', 16, 6600, 1, -12000.00), -- Impuesto al valor agregado (IVA) (negativo)
    (2023, 12, 17, 'E', 17, 6600, 2, -24000.00); -- Impuesto al consumo (negativo)

-- Utilidad del ejercicio
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 31, 'I', 18, 3200, 1, 5424600.00); -- Utilidad del ejercicio final (positivo)



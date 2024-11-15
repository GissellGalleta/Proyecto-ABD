-- Insert para Activo y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (1000, 0, 'Activo', ''),
    (1100, 0, 'Activo circulante', ''),
    (1100, 1, 'Activo circulante', 'Caja'),
    (1100, 2, 'Activo circulante', 'Bancos'),
    (1100, 3, 'Activo circulante', 'Clientes'),
    (1100, 4, 'Activo circulante', 'Mercancías/ Inventarios'),
    (1100, 5, 'Activo circulante', 'Documentos por cobrar'),
    (1100, 6, 'Activo circulante', 'Deudores diversos'),
    (1100, 7, 'Activo circulante', 'IVA acreditable pagado'),
    (1100, 8, 'Activo circulante', 'IVA a favor'),
    (1200, 0, 'Activo fijo', ''),
    (1200, 1, 'Activo fijo', 'Terreno'),
    (1200, 2, 'Activo fijo', 'Mobiliario y equipo'),
    (1200, 3, 'Activo fijo', 'Equipo de transporte'),
    (1200, 4, 'Activo fijo', 'Edificio'),
    (1200, 5, 'Activo fijo', 'Depósitos en garantía'),
    (1200, 6, 'Activo fijo', 'Equipo de cómputo'),
    (1300, 0, 'Activo diferido', ''),
    (1300, 1, 'Activo diferido', 'Gastos de instalación'),
    (1300, 2, 'Activo diferido', 'Papelería y útiles de oficina'),
    (1300, 3, 'Activo diferido', 'Rentas pagadas por adelantado'),
    (1300, 4, 'Activo diferido', 'Seguros pagados por adelantado');

-- Insert para Pasivo y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (2000, 0, 'Pasivo', ''),
    (2100, 0, 'Pasivo circulante', ''),
    (2100, 1, 'Pasivo circulante', 'Documentos por pagar'),
    (2100, 2, 'Pasivo circulante', 'Proveedores'),
    (2100, 3, 'Pasivo circulante', 'Acreedores diversos'),
    (2100, 4, 'Pasivo circulante', 'Sueldos por pagar'),
    (2100, 5, 'Pasivo circulante', 'Impuestos por pagar'),
    (2100, 6, 'Pasivo circulante', 'IVA por acreditar'),
    (2100, 7, 'Pasivo circulante', 'IVA trasladado cobrado'),
    (2100, 8, 'Pasivo circulante', 'IVA por trasladar'),
    (2200, 0, 'Pasivo fijo', ''),
    (2200, 1, 'Pasivo fijo', 'Hipotecas por pagar'),
    (2300, 0, 'Pasivo diferido', ''),
    (2300, 1, 'Pasivo diferido', 'Rentas cobradas por anticipado'),
    (2300, 2, 'Pasivo diferido', 'Intereses cobrados por anticipado');

-- Insert para Capital Contable y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (3000, 0, 'Capital Contable', ''),
    (3100, 0, 'Capital contribuido', ''),
    (3100, 1, 'Capital contribuido', 'Capital social'),
    (3200, 0, 'Capital ganado', ''),
    (3200, 1, 'Capital ganado', 'Utilidades del ejercicio'),
    (3200, 2, 'Capital ganado', 'Pérdidas del ejercicio');

-- Insert para Cuentas de ingreso y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (4000, 0, 'Cuentas de ingreso', ''),
    (4100, 0, 'Cuentas de resultados acreedoras', ''),
    (4101, 1, 'Cuentas de resultados acreedoras', 'Ventas'),
    (4102, 1, 'Cuentas de resultados acreedoras', 'Devoluciones sobre compras'),
    (4103, 1, 'Cuentas de resultados acreedoras', 'Rebajas sobre compras');

--- Insert en MOVIMIENTOS

-- Ventas (Ingresos)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 1, 'I', 1, 4000, 1, 12000000.00), -- Ventas generales (positivo)
    (2023, 12, 2, 'I', 2, 4000, 2, 3000000.00);  -- Ingreso adicional (positivo)

-- Devoluciones y Descuentos (Egresos)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 3, 'E', 3, 4100, 1, -200000.00), -- Devolución sobre ventas (negativo)
    (2023, 12, 4, 'E', 4, 4100, 2, -500000.00); -- Descuento sobre ventas (negativo)

-- Costo de Ventas Netas (Costos)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 5, 'E', 5, 5000, 1, -200000.00), -- Costo de mercadería (negativo)
    (2023, 12, 6, 'E', 6, 5000, 2, -150000.00), -- Costo de transporte (negativo)
    (2023, 12, 7, 'E', 7, 5000, 3, -190000.00); -- Costo de almacenamiento (negativo)

-- Gastos de Operación (Costos de venta y administración)
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 8, 'E', 8, 6000, 1, -1200000.00), -- Sueldos y salarios (negativo)
    (2023, 12, 9, 'E', 9, 6200, 1, -800000.00),  -- Sueldos y salarios administrativos (negativo)
    (2023, 12, 10, 'E', 10, 6200, 2, -400000.00); -- Energía eléctrica (negativo)

-- Costo Integral de Financiamiento
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 11, 'E', 11, 6300, 1, -5550.00),    -- Interés bancario (negativo)
    (2023, 12, 12, 'I', 12, 6400, 1, 12000.00),    -- Utilidad bancaria (positivo)
    (2023, 12, 13, 'E', 13, 6300, 2, -4500.00);    -- Comisiones bancarias (negativo)

-- Ingresos y Egresos por Partidas Extraordinarias
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 14, 'I', 14, 7000, 1, 6000.00),    -- Otros ingresos extraordinarios (positivo)
    (2023, 12, 15, 'E', 15, 6500, 1, -6000.00);   -- Otros gastos extraordinarios (negativo)

-- Impuestos
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 16, 'E', 16, 6600, 1, -12000.00), -- Impuesto al valor agregado (IVA) (negativo)
    (2023, 12, 17, 'E', 17, 6600, 2, -24000.00); -- Impuesto al consumo (negativo)

-- Utilidad del ejercicio
INSERT INTO contabilidad.Movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES 
    (2023, 12, 31, 'I', 18, 3200, 1, 5424600.00); -- Utilidad del ejercicio final (positivo)

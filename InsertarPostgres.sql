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
    (2021, 11, 6, 'D', 2, 'Póliza de diario noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2021, 10, 5, 'E', 14, 'Póliza de egresos octubre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),--
    (2021, 10, 6, 'D', 15, 'Póliza de diario octubre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia');--


--- Insert en MOVIMIENTOS

-- Ventas (Ingresos)
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
    (2022, 11, 5, 'E', 4, 4100, 1, -200), -- Devolución sobre ventas (negativo)
    (2022, 11, 5, 'E', 5, 4100, 2, -500); -- Descuento sobre ventas (negativo)


INSERT INTO contabilidad.movimientos 
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto) 
    VALUES 
    (2023, 12, 2, 'E', 9, 601, 1, 800);


-- Parte principal de la consulta con la UNION
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
        contabilidad.Polizas AS P
    JOIN 
        contabilidad.Movimientos AS M ON P.P_anio = M.M_P_anio 
                         AND P.P_mes = M.M_P_mes 
                         AND P.P_dia = M.M_P_dia 
                         AND P.P_tipo = M.M_P_tipo 
                         AND P.P_folio = M.M_P_folio
    JOIN 
        contabilidad.Cuentas AS C ON M.M_C_numCta = C.C_numCta 
                     AND M.M_C_numSubCta = C.C_numSubCta
    WHERE 
        P.P_anio = 2023
        AND P.P_mes = 12
        AND P.P_tipo = 'E'
        AND P.P_folio = 9
    ORDER BY 
        M.M_numMov
) AS consulta1

UNION ALL

-- Parte para el total de debe y haber
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
    contabilidad.Polizas AS P
JOIN 
    contabilidad.Movimientos AS M ON P.P_anio = M.M_P_anio 
                     AND P.P_mes = M.M_P_mes 
                     AND P.P_dia = M.M_P_dia 
                     AND P.P_tipo = M.M_P_tipo 
                     AND P.P_folio = M.M_P_folio
WHERE 
    P.P_anio = 2023
    AND P.P_mes = 12
    AND P.P_tipo = 'E'
    AND P.P_folio = 9

UNION ALL

-- Parte para mostrar la fila con textos estáticos
SELECT
    'Fecha' AS numero_cuenta,
    'Folio' AS numero_subcuenta,
    'Hecho Por' AS concepto_subcuenta,
    'Revisado por' AS debe,
    'Autorizado por' AS haber

UNION ALL

-- Parte para mostrar la fecha, folio, y personas responsables
SELECT
    DISTINCT CONCAT(P.P_anio, '-', LPAD(P.P_mes::TEXT, 2, '0'), '-', LPAD(P.P_dia::TEXT, 2, '0')) AS numero_cuenta,
    P.P_folio::TEXT AS numero_subcuenta,
    P.P_hechoPor AS concepto_subcuenta,
    P.P_revisadoPor AS debe,
    P.P_autorizadoPor AS haber
FROM 
    contabilidad.Polizas AS P
WHERE 
    P.P_anio = 2023
    AND P.P_mes = 12
    AND P.P_tipo = 'E'
    AND P.P_folio = 9;

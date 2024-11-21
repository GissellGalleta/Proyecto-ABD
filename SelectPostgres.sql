--CATALOGO CUENTAS POSTGRES
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
    CAST(C_numCta AS INTEGER), -- Ordenar por el número de cuenta principal
    CASE 
        WHEN C_numSubCta = 0 THEN 0 ELSE 1 
    END, -- Cuentas principales antes que subcuentas
    CAST(C_numSubCta AS INTEGER); -- Ordenar subcuentas por su número


--Generación de póliza 
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
        P.P_anio = 2023
        AND P.P_mes = 12
        AND P.P_tipo = 'E'
        AND P.P_folio = 9
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
    P.P_anio = 2023
    AND P.P_mes = 12
    AND P.P_tipo = 'E'
    AND P.P_folio = 9
UNION
SELECT
    '' AS numero_cuenta,
    '' AS numero_subcuenta,
    'Fecha' AS concepto_subcuenta,
    'Folio' AS debe,
    'Hecho Por' AS haber
FROM 
    Polizas AS P
WHERE 
    P.P_anio = 2023
    AND P.P_mes = 12
    AND P.P_tipo = 'E'
    AND P.P_folio = 9
UNION
SELECT
    DISTINCT P.P_anio || '-' || LPAD(P.P_mes::TEXT, 2, '0') || '-' || LPAD(P.P_dia::TEXT, 2, '0') AS numero_cuenta,
    P.P_folio::TEXT AS numero_subcuenta,
    P.P_hechoPor AS concepto_subcuenta,
    P.P_revisadoPor AS debe,
    P.P_autorizadoPor AS haber
FROM 
    Polizas AS P
WHERE 
    P.P_anio = 2023
    AND P.P_mes = 12
    AND P.P_tipo = 'E'
    AND P.P_folio = 9;




-- Estado de resultados POSTGRES TENGO DUDAS SOBRE COMO SACARLO
WITH
-- Parámetros: ajusta el año y mes según necesites
params AS (
    SELECT 2023 AS anio, 12 AS mes
),

-- Movimientos filtrados por el período especificado
movimientos_periodo AS (
    SELECT m.*, c.C_nomCta, c.C_nomSubCta
    FROM contabilidad.movimientos m
    JOIN contabilidad.cuentas c
        ON m.M_C_numCta = c.C_numCta AND m.M_C_numSubCta = c.C_numSubCta
    JOIN params p
        ON m.M_P_anio = p.anio AND m.M_P_mes = p.mes
),

-- Cálculo de Ventas Brutas
ventas_brutas AS (
    SELECT
        SUM(CASE WHEN M_C_numCta = 401 AND M_C_numSubCta = 1 THEN M_monto ELSE 0 END) AS ventas_nacionales,
        SUM(CASE WHEN M_C_numCta = 401 AND M_C_numSubCta = 2 THEN M_monto ELSE 0 END) AS ventas_internacionales
    FROM movimientos_periodo
),

-- Cálculo de Comisiones por Ventas
comisiones_ventas AS (
    SELECT
        SUM(M_monto) AS total_comisiones
    FROM movimientos_periodo
    WHERE M_C_numCta = 601 AND M_C_numSubCta = 2
),

-- Ventas Netas
ventas_netas AS (
    SELECT
        (vb.ventas_nacionales + vb.ventas_internacionales) - cv.total_comisiones AS total_ventas_netas
    FROM ventas_brutas vb, comisiones_ventas cv
),

-- Cálculo de Costos de Ventas
costos_ventas AS (
    SELECT
        SUM(CASE WHEN M_C_numCta = 501 AND M_C_numSubCta = 1 THEN M_monto ELSE 0 END) AS costo_transporte,
        SUM(CASE WHEN M_C_numCta = 501 AND M_C_numSubCta = 2 THEN M_monto ELSE 0 END) AS costo_fletes,
        SUM(CASE WHEN M_C_numCta = 501 AND M_C_numSubCta = 3 THEN M_monto ELSE 0 END) AS mano_obra_directa
    FROM movimientos_periodo
),

-- Ganancia Bruta
ganancia_bruta AS (
    SELECT
        vn.total_ventas_netas - (cv.costo_transporte + cv.costo_fletes + cv.mano_obra_directa) AS total_ganancia_bruta
    FROM ventas_netas vn, costos_ventas cv
),

-- Cálculo de Gastos
gastos AS (
    SELECT
        SUM(CASE WHEN M_C_numCta = 601 AND M_C_numSubCta = 1 THEN M_monto ELSE 0 END) AS publicidad,
        SUM(CASE WHEN M_C_numCta = 602 AND M_C_numSubCta = 1 THEN M_monto ELSE 0 END) AS servicios_publicos,
        SUM(CASE WHEN M_C_numCta = 602 AND M_C_numSubCta = 4 THEN M_monto ELSE 0 END) AS energia_electrica,
        SUM(CASE WHEN M_C_numCta = 602 AND M_C_numSubCta = 3 THEN M_monto ELSE 0 END) AS impuestos_sueldos,
        SUM(CASE WHEN M_C_numCta = 602 AND M_C_numSubCta = 2 THEN M_monto ELSE 0 END) AS sueldos_personal
    FROM movimientos_periodo
),

-- Total de Gastos
total_gastos AS (
    SELECT
        publicidad + servicios_publicos + energia_electrica + impuestos_sueldos + sueldos_personal AS total_gastos
    FROM gastos
),

-- Ganancia Neta
ganancia_neta AS (
    SELECT
        gb.total_ganancia_bruta - tg.total_gastos AS total_ganancia_neta
    FROM ganancia_bruta gb, total_gastos tg
)

-- Selección y formateo final
SELECT 'Ingresos' AS "Sección", NULL AS "Concepto", NULL AS "Monto"

UNION ALL

SELECT
    NULL,
    'Ventas brutas',
    ventas_nacionales + ventas_internacionales
FROM ventas_brutas

UNION ALL

SELECT
    NULL,
    'Comisiones por ventas',
    total_comisiones
FROM comisiones_ventas

UNION ALL

SELECT
    NULL,
    'Ventas netas',
    total_ventas_netas
FROM ventas_netas

UNION ALL

SELECT 'Costo de Ventas', NULL, NULL

UNION ALL

SELECT
    NULL,
    'Costo de transporte',
    costo_transporte
FROM costos_ventas

UNION ALL

SELECT
    NULL,
    'Costo de los fletes entrantes',
    costo_fletes
FROM costos_ventas

UNION ALL

SELECT
    NULL,
    'Mano de obra directa',
    mano_obra_directa
FROM costos_ventas

UNION ALL

SELECT
    NULL,
    'Costos de las ventas',
    costo_transporte + costo_fletes + mano_obra_directa
FROM costos_ventas

UNION ALL

SELECT
    NULL,
    'Ganancia bruta',
    total_ganancia_bruta
FROM ganancia_bruta

UNION ALL

SELECT 'Gastos', NULL, NULL

UNION ALL

SELECT
    NULL,
    'Publicidad',
    publicidad
FROM gastos

UNION ALL

SELECT
    NULL,
    'Gasto de Servicios Públicos',
    servicios_publicos
FROM gastos

UNION ALL

SELECT
    NULL,
    'Gasto de Energía Eléctrica',
    energia_electrica
FROM gastos

UNION ALL

SELECT
    NULL,
    'Impuestos sobre sueldos',
    impuestos_sueldos
FROM gastos

UNION ALL

SELECT
    NULL,
    'Sueldos de personal',
    sueldos_personal
FROM gastos

UNION ALL

SELECT
    NULL,
    'Total de gastos',
    total_gastos
FROM total_gastos

UNION ALL

SELECT
    NULL,
    'Ganancia neta',
    total_ganancia_neta
FROM ganancia_neta;



-- generar la poliza 1001 de tipo ingreso, para MYSQL
SELECT 
    CONCAT(P.P_anio, '-', LPAD(P.P_mes, 2, '0'), '-', LPAD(P.P_dia, 2, '0')) AS fecha, -- Fecha en formato YYYY-MM-DD
    M.M_C_tipoCta AS numero_cuenta,
    M.M_C_numSubCta AS numero_subcuenta,
    C.C_nomSubCta AS concepto_subcuenta,

    -- Determinar si el monto está en debe o haber
    CASE 
        WHEN M.M_monto >= 0 THEN M.M_monto -- Montos positivos van al debe
        ELSE 0                            -- Montos negativos no van al debe
    END AS debe,

    CASE 
        WHEN M.M_monto < 0 THEN -M.M_monto -- Montos negativos van al haber
        ELSE 0                            -- Montos positivos no van al haber
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
    Cuentas AS C ON M.M_C_tipoCta = C.C_tipoCta 
                 AND M.M_C_numSubCta = C.C_numSubCta

WHERE 
    P.P_folio = 1001 -- Folio específico de la póliza, podemos utilizar aquí una variable

ORDER BY 
    fecha, M.M_numMov;


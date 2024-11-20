-- Consulta de catálogo de cuentas
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

-- Consulta de una póliza por año, mes y tipo, falta de darle formato y que concuerde con el documento
SELECT 
    CONCAT(P.P_anio, '-', LPAD(P.P_mes, 2, '0'), '-', LPAD(P.P_dia, 2, '0')) AS fecha, -- Fecha en formato YYYY-MM-DD
    M.M_C_numCta AS numero_cuenta,
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
    Cuentas AS C ON M.M_C_numCta = C.C_numCta 
                 AND M.M_C_numSubCta = C.C_numSubCta

WHERE 
    P.P_anio = 2023
    AND P.P_mes = 12
    AND P.P_tipo = 'I'

ORDER BY 
    fecha, M.M_numMov;



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
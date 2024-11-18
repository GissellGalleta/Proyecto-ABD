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



--Catálogo de cuentas para MySQL



-- Estado de resultados POSTGRES TENGO DUDAS SOBRE COMO SACARLO

SELECT 
    'Ventas' AS "Concepto",
    SUM(M.M_monto) AS "Total"
FROM 
    contabilidad.Movimientos M
JOIN 
    contabilidad.Cuentas C ON M.M_C_tipoCta = C.C_tipoCta AND M.M_C_numSubCta = C.C_numSubCta
WHERE 
    C.C_tipoCta = 110000 -- Suponiendo que 4000 corresponde a "Ingresos" (ventas)
    
UNION ALL

SELECT 
    'Devoluciones y descuentos' AS "Concepto",
    SUM(M.M_monto) AS "Total"
FROM 
    contabilidad.Movimientos M
JOIN 
    contabilidad.Cuentas C ON M.M_C_tipoCta = C.C_tipoCta AND M.M_C_numSubCta = C.C_numSubCta
WHERE 
    C.C_tipoCta = 21000 -- Suponiendo que 4100 corresponde a "Devoluciones y descuentos"

UNION ALL

SELECT 
    'Costo de ventas netas' AS "Concepto",
    SUM(M.M_monto) AS "Total"
FROM 
    contabilidad.Movimientos M
JOIN 
    contabilidad.Cuentas C ON M.M_C_tipoCta = C.C_tipoCta AND M.M_C_numSubCta = C.C_numSubCta
WHERE 
    C.C_tipoCta = 5000 -- Suponiendo que 5000 corresponde a "Costos"
    

-- generar la poliza 1001 de tipo ingreso, para MYSQL hay que quitarle lo de tipo ingreso y solamente buscar por folio
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
    P.P_tipo = 'D'    -- Filtrar únicamente pólizas de tipo Diario
    AND P.P_folio = 1001 -- Folio específico de la póliza, podemos utilizar aquí una variable

ORDER BY 
    fecha, M.M_numMov;
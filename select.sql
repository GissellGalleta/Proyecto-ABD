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
    


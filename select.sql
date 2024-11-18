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

WITH movimientos_agrupados AS (
    SELECT 
        CASE 
            WHEN c.C_numCta = 401 THEN 'Ingresos'
            WHEN c.C_numCta = 501 THEN 'Costo de ventas'
            WHEN c.C_numCta BETWEEN 601 AND 602 THEN 'Gastos'
            ELSE 'Otros'
        END AS Categoria,
        CASE 
            WHEN c.C_numCta = 401 AND c.C_numSubCta = 0 THEN 'Ventas brutas'
            WHEN c.C_numCta = 601 AND c.C_numSubCta = 2 THEN 'Comisiones de Ventas'
            WHEN c.C_numCta = 501 AND c.C_numSubCta = 1 THEN 'Costo de transporte'
            WHEN c.C_numCta = 501 AND c.C_numSubCta = 2 THEN 'Costo de los fletes entrantes'
            WHEN c.C_numCta = 501 AND c.C_numSubCta = 3 THEN 'Mano de obra directa'
            WHEN c.C_numCta = 601 AND c.C_numSubCta = 1 THEN 'Publicidad'
            WHEN c.C_numCta = 602 AND c.C_numSubCta = 1 THEN 'Gasto de Servicios Públicos'
            WHEN c.C_numCta = 602 AND c.C_numSubCta = 4 THEN 'Gasto de Energía Eléctrica'
            WHEN c.C_numCta = 602 AND c.C_numSubCta = 3 THEN 'Impuestos sobre sueldos'
            WHEN c.C_numCta = 602 AND c.C_numSubCta = 2 THEN 'Sueldos de personal'
            ELSE 'Otros'
        END AS Concepto,
        SUM(m.M_monto) AS Monto
    FROM contabilidad.movimientos m
    JOIN contabilidad.cuentas c ON m.M_C_tipoCta = c.C_numCta AND m.M_C_numSubCta = c.C_numSubCta
    WHERE m.M_P_anio = 2023 AND m.M_P_mes = 12
    GROUP BY Categoria, Concepto
),

totales AS (
    SELECT 
        'Ventas netas' AS Concepto, 
        SUM(CASE WHEN Categoria = 'Ingresos' THEN Monto ELSE 0 END) - 
        SUM(CASE WHEN Concepto = 'Comisiones de Ventas' THEN Monto ELSE 0 END) AS Monto
    FROM movimientos_agrupados
    UNION ALL
    SELECT 
        'Costo de las ventas', 
        SUM(CASE WHEN Categoria = 'Costo de ventas' THEN Monto ELSE 0 END)
    FROM movimientos_agrupados
    UNION ALL
    SELECT 
        'Ganancia (pérdida) bruta', 
        (SELECT Monto FROM totales WHERE Concepto = 'Ventas netas') - 
        (SELECT Monto FROM totales WHERE Concepto = 'Costo de las ventas')
    UNION ALL
    SELECT 
        'Total de gastos', 
        SUM(CASE WHEN Categoria = 'Gastos' THEN Monto ELSE 0 END)
    FROM movimientos_agrupados
    UNION ALL
    SELECT 
        'Ganancia (pérdida) neta', 
        (SELECT Monto FROM totales WHERE Concepto = 'Ganancia (pérdida) bruta') - 
        (SELECT Monto FROM totales WHERE Concepto = 'Total de gastos')
)

SELECT Categoria, Concepto, Monto
FROM movimientos_agrupados
UNION ALL
SELECT NULL, Concepto, Monto FROM totales
ORDER BY Categoria NULLS FIRST, Concepto;

    


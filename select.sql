--CATALOGO CUENTAS
SELECT 
    C_tipoCta * 100 + C_numSubCta AS "Código Completo",
    CASE 
        WHEN C_numSubCta = 0 THEN C_tipoCta::text || '00'  -- Código de cuenta principal (sin subcuenta)
        ELSE NULL
    END AS "Código de Cuenta",
    CASE 
        WHEN C_numSubCta != 0 THEN LPAD(C_numSubCta::text, 2, '0')  -- Código de subcuenta (cuando no es cuenta principal)
        ELSE NULL
    END AS "Código de Subcuenta",
    CASE 
        WHEN C_numSubCta = 0 THEN C_nomCta      -- Mostrar solo la cuenta principal en esta columna
        ELSE NULL
    END AS "Nombre de la Cuenta",
    CASE 
        WHEN C_numSubCta != 0 THEN C_nomSubCta  -- Mostrar solo las subcuentas en esta columna
        ELSE NULL
    END AS "Nombre de la Subcuenta"
FROM 
    contabilidad.Cuentas
ORDER BY 
    C_tipoCta, C_numSubCta;

--polizas

-- generar la poliza 1001 de tipo ingreso
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
    AND P.P_folio = 1001 -- Folio específico de la póliza

ORDER BY 
    fecha, M.M_numMov;
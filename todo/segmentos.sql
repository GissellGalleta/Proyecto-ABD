-- vistas para rango de años
CREATE VIEW polizas_2023 AS
SELECT * FROM polizas WHERE anio = 2023;

CREATE VIEW polizas_2010_2020 AS
SELECT * FROM polizas 
WHERE P_anio BETWEEN 2010 AND 2020;

---vistas para lista de los tipos de polizas
CREATE VIEW poliza_ingreso AS
SELECT * FROM polizas WHERE P_tipo = 'I';

CREATE VIEW poliza_egreso AS
SELECT * FROM polizas WHERE P_tipo = 'E';

CREATE VIEW poliza_diario AS
SELECT * FROM polizas WHERE P_tipo = 'D';


-- vistas combinadas del tipo de poliza y el año en el que se realizo
CREATE VIEW polizas_2023_ingreso AS
SELECT * FROM polizas WHERE anio = 2023 AND P_tipo = 'I';

CREATE VIEW polizas_2010_2020_egreso AS
SELECT * FROM polizas 
WHERE P_anio BETWEEN 2010 AND 2020 
  AND P_tipo = 'E';

-- ============= =========== MYSQL =========== ===========

-- Segmentación por dato fijo
CREATE VIEW polizas_2020 AS
    SELECT * FROM polizas WHERE P_anio = 2020;

-- Segmentación por rangos
CREATE VIEW polizas_2010_2020 AS
    SELECT * FROM polizas WHERE P_anio BETWEEN 2010 AND 2020;

-- Segmentación por tipos
CREATE VIEW poliza_ingreso AS
    SELECT * FROM polizas WHERE P_tipo = 'I';

CREATE VIEW poliza_egreso AS
    SELECT * FROM polizas WHERE P_tipo = 'E';

CREATE VIEW poliza_diario AS
    SELECT * FROM polizas WHERE P_tipo = 'D';

-- Segmentación por vistas combinadas
    -- Año en específico
CREATE VIEW polizas_2023_ingresos AS
    SELECT * FROM polizas WHERE P_anio = 2023 AND P_tipo = 'I';
    -- Por rango de años
CREATE VIEW polizas_2010_2020_egresos AS
    SELECT * FROM polizas
        WHERE P_anio BETWEEN 2010 AND 2020
            AND P_tipo = 'E';


--- Segmentación de Cuentas
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

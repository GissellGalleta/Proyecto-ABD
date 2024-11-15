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
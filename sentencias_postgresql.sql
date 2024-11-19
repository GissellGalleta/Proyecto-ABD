-- DROP DATABASE IF EXISTS proyecto_equipo1;
-- CREATE DATABASE proyecto_equipo1;

\c proyecto_equipo1;

-- Eliminar Vistas
DROP VIEW IF EXISTS contabilidad.polizas_2023_ingresos, contabilidad.polizas_2010_2020, contabilidad.poliza_diario,
    contabilidad.poliza_egreso, contabilidad.polizas_2020, contabilidad.polizas_2010_2020,
    contabilidad.poliza_ingreso, contabilidad.polizas_2010_2020_egresos;

-- Eliminar tablas
DROP TABLE IF EXISTS contabilidad.Movimientos;
DROP TABLE IF EXISTS contabilidad.Polizas, contabilidad.Cuentas, registros_bitacora.Bitacora;
DROP SCHEMA IF EXISTS contabilidad, registros_bitacora CASCADE ; -- Eliminar DB
CREATE SCHEMA contabilidad;
CREATE SCHEMA registros_bitacora;

-- Creación de Tabla Empresa
CREATE TABLE contabilidad.empresa (
    E_RFC CHAR(13) NOT NULL,
    E_Nombre CHAR(40) NOT NULL,
    PRIMARY KEY (E_RFC)
);

-- Creación de tabla Cuentas
CREATE TABLE contabilidad.Cuentas (
    C_numCta SMALLINT,
    C_numSubCta SMALLINT,
    C_nomCta CHAR(30),
    C_nomSubCta CHAR(30),
    PRIMARY KEY (C_numCta, C_numSubCta)
);

-- Creación de tabla Polizas
CREATE TABLE contabilidad.Polizas (
    P_anio SMALLINT NOT NULL,
    P_mes SMALLINT NOT NULL,
    P_dia SMALLINT NOT NULL,
    P_tipo CHAR(1), -- Tipo cambiado a CHAR(1)
    P_folio SMALLINT NOT NULL,
    P_concepto VARCHAR(40) NOT NULL,
    P_hechoPor VARCHAR(40) NOT NULL,
    P_revisadoPor VARCHAR(40) NOT NULL,
    P_autorizadoPor VARCHAR(40) NOT NULL,
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio)
);

-- Creación de tabla Movimientos
CREATE TABLE contabilidad.Movimientos (
    M_P_anio SMALLINT NOT NULL,
    M_P_mes SMALLINT NOT NULL,
    M_P_dia SMALLINT NOT NULL,
    M_P_tipo CHAR(1) NOT NULL,
    M_P_folio SMALLINT NOT NULL,
    M_numMov SERIAL UNIQUE,
    M_C_numCta SMALLINT NOT NULL,
    M_C_numSubCta SMALLINT NOT NULL,
    M_monto DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio, M_numMov),

    -- Restricción de claves foráneas
    CONSTRAINT FK_Polizas FOREIGN KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio)
        REFERENCES contabilidad.Polizas(P_anio, P_mes, P_tipo, P_folio),
    CONSTRAINT FK_Cuentas FOREIGN KEY (M_C_numCta, M_C_numSubCta)
        REFERENCES contabilidad.Cuentas(C_numCta, C_numSubCta),

    -- Restricción de valores permitidos para M_P_tipo
    CONSTRAINT CHK_M_P_tipo CHECK (M_P_tipo IN ('I', 'D', 'E'))
);

-- Creación de la tabla Bitácora
CREATE TABLE registros_bitacora.Bitacora (
    id SERIAL PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
);


-- Usuarios
-- Crear los usuarios
-- CREATE USER maestro WITH PASSWORD 'maestro';
GRANT ALL PRIVILEGES ON SCHEMA contabilidad TO maestro;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA contabilidad TO maestro;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA contabilidad TO maestro;
ALTER DEFAULT PRIVILEGES IN SCHEMA contabilidad GRANT ALL PRIVILEGES ON TABLES TO maestro;
ALTER DEFAULT PRIVILEGES IN SCHEMA contabilidad GRANT ALL PRIVILEGES ON SEQUENCES TO maestro;


-- CREATE USER usuario WITH PASSWORD 'usuario';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA contabilidad TO usuario;
ALTER DEFAULT PRIVILEGES IN SCHEMA contabilidad GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO usuario;


-- CREATE USER auditor WITH PASSWORD 'auditor';
-- Asignación de permisos de lectura al usuario "auditor" para poder ingresar a la visibilidad de la tabla:
REVOKE ALL ON SCHEMA registros_bitacora FROM auditor;
REVOKE ALL ON ALL TABLES IN SCHEMA registros_bitacora FROM auditor;
GRANT USAGE ON SCHEMA registros_bitacora TO auditor; -- Conceder acceso al esquema
GRANT SELECT ON registros_bitacora.Bitacora TO auditor; -- Conceder permisos de solo lectura a la tabla
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA registros_bitacora FROM auditor;




-- Trigger function para Polizas
-- En caso de que sea un tipo diferente al especificado, deberá enviar Error
CREATE OR REPLACE FUNCTION validar_P_tipo()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que P_tipo sea 'I', 'D', o 'E'
    IF NEW.P_tipo NOT IN ('I', 'D', 'E') THEN
        RAISE EXCEPTION 'El valor de P_tipo debe ser "I", "D", o "E".';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers Insert y Update
CREATE TRIGGER trigger_validar_P_tipo
BEFORE INSERT OR UPDATE ON contabilidad.Polizas
FOR EACH ROW
EXECUTE PROCEDURE validar_P_tipo();

-- Trigger function para Movimientos
CREATE OR REPLACE FUNCTION validar_M_P_tipo()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que M_P_tipo sea 'I', 'D', o 'E'
    IF NEW.M_P_tipo NOT IN ('I', 'D', 'E') THEN
        RAISE EXCEPTION 'El valor de M_P_tipo debe ser "I", "D", o "E".';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers Insert y Update
CREATE TRIGGER trigger_validar_M_P_tipo
BEFORE INSERT OR UPDATE ON contabilidad.Movimientos
FOR EACH ROW
EXECUTE PROCEDURE validar_M_P_tipo();

-- ============ BITACORA ==============

-- Bitacora para Cuentas
CREATE OR REPLACE FUNCTION registrar_bitacora_cuentas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('INSERT',
                'El usuario: ' || current_user ||
                ' realizó una inserción en la tabla cuentas con el id: ' || NEW.C_numCta ||
                '-' || NEW.c_numsubcta ||
                ' el día: ' || current_timestamp);

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user ||
                ' realizó una modificación en la cuenta: ' || NEW.C_numCta ||
                '-' || NEW.c_numsubcta ||
                ' en la fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('DELETE',
                'El usuario: ' || current_user ||
                ' realizó la eliminación de la cuenta: ' || OLD.C_numCta ||
                '-' || OLD.c_numsubcta ||
                ' en la fecha de: ' || current_timestamp);
    END IF;

    -- En un trigger AFTER, debes usar RETURN NEW para INSERT/UPDATE y RETURN OLD para DELETE
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger para la bitácora de Cuentas
CREATE TRIGGER trigger_registrar_bitacora_cuentas
AFTER INSERT OR UPDATE OR DELETE  ON contabilidad.Cuentas
FOR EACH ROW EXECUTE PROCEDURE registrar_bitacora_cuentas();


-- Bitacora para Polizas
CREATE OR REPLACE FUNCTION registrar_bitacora_polizas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('INSERT',
                'EL usuario: ' || current_user || ' realizó una inserción en la tabla Polizas con el nuevo registro: '
                    || NEW.P_folio || ' en la fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user || ', realizó un cambio de datos en la tabla Polizas en el registro: '
                    || NEW.P_folio || ', con fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('DELETE',
                   --'Se eliminó un registro en Polizas con ID: ' || OLD.P_folio);
               'El usuario: ' || current_user || ', realizó una eliminación de datos en la tabla Polizas en el registro: '
                    || OLD.P_folio || ', con fecha de: ' || current_timestamp);
    END IF;

    -- Retorno adecuado para triggers AFTER
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_registrar_bitacora_polizas
AFTER INSERT OR UPDATE OR DELETE  ON contabilidad.Polizas
FOR EACH ROW EXECUTE PROCEDURE registrar_bitacora_Polizas();


-- Bitacora para Movimientos
CREATE OR REPLACE FUNCTION registrar_bitacora_movimientos()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('INSERT',
                'EL usuario: ' || current_user || ' realizó una inserción en la tabla Movimientos con el nuevo registro: '
                    || NEW.m_nummov || ' en la fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user || ', realizó un cambio de datos en la tabla Movimientos en el registro: '
                    || NEW.m_nummov || ', con fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('DELETE',
                   --'Se eliminó un registro en Polizas con ID: ' || OLD.P_folio);
               'El usuario: ' || current_user || ', realizó una eliminación de datos en la tabla Movimientos en el registro: '
                    || OLD.m_nummov || ', con fecha de: ' || current_timestamp);
    END IF;

    -- Retorno adecuado para triggers AFTER
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_registrar_bitacora_movimientos
AFTER INSERT OR UPDATE OR DELETE  ON contabilidad.Movimientos
FOR EACH ROW EXECUTE PROCEDURE registrar_bitacora_movimientos();

-- =========== DATOS ================
-- Inserción de datos
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
    (2021, 11, 6, 'D', 2, 'Póliza de diario noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia');


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
-- INSERT INTO contabilidad.Movimientos
--     (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
-- VALUES
--     (2023, 12, 11, 'E', 14, 6300, 1, -5550),    -- Interés bancario (negativo)
--     (2023, 12, 12, 'I', 15, 6400, 1, 12000),    -- Utilidad bancaria (positivo)
--     (2023, 12, 13, 'E', 16, 6300, 2, -4500);    -- Comisiones bancarias (negativo)

-- Devoluciones y Descuentos (Egresos)  //pendiente de ingresar
-- INSERT INTO contabilidad.Movimientos
--     (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
-- VALUES
--     (2022, 11, 5 ,'E', 4, 4100, 1, -200), -- Devolución sobre ventas (negativo)
--     (2022, 11, 5, 'E', 5, 4100, 2, -500); -- Descuento sobre ventas (negativo)

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



-- ================== SELECTS

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

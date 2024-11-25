-- DROP DATABASE IF EXISTS contabilidad_abd;
-- CREATE DATABASE contabilidad_abd;

--\c contabilidad_abd;

-- Eliminar Vistas
DROP VIEW IF EXISTS contabilidad.polizas_2023_ingresos, contabilidad.polizas_2010_2020, contabilidad.poliza_diario,
    contabilidad.poliza_egreso, contabilidad.polizas_2020, contabilidad.polizas_2010_2020,
    contabilidad.poliza_ingreso, contabilidad.polizas_2010_2020_egresos;

-- Eliminar tablas
DROP TABLE IF EXISTS contabilidad.Movimientos CASCADE;
DROP TABLE IF EXISTS contabilidad.Polizas, contabilidad.Cuentas, contabilidad.Bitacora CASCADE ;
DROP SCHEMA IF EXISTS contabilidad, contabilidad CASCADE ; -- Eliminar DB
\c contabilidad_abd
CREATE SCHEMA contabilidad;

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
     -- Restricción de valores permitidos para M_P_tipo
    CONSTRAINT CHK_P_tipo CHECK (P_tipo IN ('I', 'D', 'E'))
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
);

DROP TABLESPACE IF EXISTS Bitacora;
CREATE TABLESPACE Bitacora LOCATION 'C:/ProyectoBD/PostgreSQL/Tablespaces';

CREATE TABLE contabilidad.Bitacora (
    id SERIAL PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
)TABLESPACE Bitacora;



-- Eliminar triggers relacionados con Polizas
DROP TRIGGER IF EXISTS trigger_validar_P_tipo ON contabilidad.Polizas;
DROP TRIGGER IF EXISTS trigger_registrar_bitacora_polizas ON contabilidad.Polizas;

-- Eliminar triggers relacionados con Movimientos
DROP TRIGGER IF EXISTS trigger_validar_M_P_tipo ON contabilidad.Movimientos;
DROP TRIGGER IF EXISTS trigger_registrar_bitacora_movimientos ON contabilidad.Movimientos;

-- Eliminar trigger relacionado con Cuentas
DROP TRIGGER IF EXISTS trigger_registrar_bitacora_cuentas ON contabilidad.Cuentas;

DROP TABLE if exists Contabilidad.Movimientos;
CREATE TABLE Contabilidad.Movimientos (
    M_P_anio SMALLINT NOT NULL,
    M_P_mes SMALLINT NOT NULL,
    M_P_dia SMALLINT NOT NULL,
    M_P_tipo CHAR(1) NOT NULL,
    M_P_folio SMALLINT NOT NULL,
    M_numMov SERIAL NOT NULL,
    M_C_numCta SMALLINT NOT NULL,
    M_C_numSubCta SMALLINT NOT NULL,
    M_monto DECIMAL(10,2) NOT NULL
) PARTITION BY RANGE (M_P_anio);
CREATE TABLE contabilidad.Mov2010_2015 PARTITION OF Contabilidad.Movimientos
FOR VALUES FROM (2010) TO (2015);

CREATE TABLE contabilidad.Mov2015_2020 PARTITION OF Contabilidad.Movimientos
FOR VALUES FROM (2015) TO (2020);

CREATE TABLE contabilidad.Mov2020_2025 PARTITION OF Contabilidad.Movimientos
FOR VALUES FROM (2020) TO (2025);


CREATE OR REPLACE FUNCTION validar_fk_movimientos()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que M_C_numCta y M_C_numSubCta existen en Contabilidad.Cuentas
    IF NOT EXISTS (
        SELECT 1
        FROM Contabilidad.Cuentas
        WHERE C_numCta = NEW.M_C_numCta
          AND C_numSubCta = NEW.M_C_numSubCta
    ) THEN
        RAISE EXCEPTION 'Error: La combinación de M_C_numCta = %, M_C_numSubCta = % no existe en Cuentas.',
            NEW.M_C_numCta, NEW.M_C_numSubCta;
    END IF;

    -- Validar que M_P_anio, M_P_mes, M_P_tipo y M_P_folio existen en contabilidad.Polizas
    IF NOT EXISTS (
        SELECT 1
        FROM Contabilidad.Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
          AND P_folio = NEW.M_P_folio
    ) THEN
        RAISE EXCEPTION 'Error: La combinación de M_P_anio = %, M_P_mes = %, M_P_tipo = %, M_P_folio = % no existe en Polizas.',
            NEW.M_P_anio, NEW.M_P_mes, NEW.M_P_tipo, NEW.M_P_folio;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_relaciones_movimientos_2010_2015
BEFORE INSERT OR UPDATE ON contabilidad.Mov2010_2015
FOR EACH ROW
EXECUTE PROCEDURE validar_fk_movimientos();

CREATE TRIGGER validar_relaciones_movimientos_2015_2020
BEFORE INSERT OR UPDATE ON contabilidad.Mov2015_2020
FOR EACH ROW
EXECUTE PROCEDURE validar_fk_movimientos();

CREATE TRIGGER validar_relaciones_movimientos_2020_2025
BEFORE INSERT OR UPDATE ON contabilidad.Mov2020_2025
FOR EACH ROW
EXECUTE PROCEDURE validar_fk_movimientos();

CREATE OR REPLACE FUNCTION validar_numMov_unico()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar si M_numMov ya existe en la tabla o particiones
    IF EXISTS (
        SELECT 1
        FROM contabilidad.Movimientos
        WHERE M_numMov = NEW.M_numMov
    ) THEN
        RAISE EXCEPTION 'Error: El numero de movimiento % ya existe.', NEW.M_numMov;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_numMov_trigger_2010_2015
BEFORE INSERT OR UPDATE ON contabilidad.Mov2010_2015
FOR EACH ROW
EXECUTE PROCEDURE validar_numMov_unico();

CREATE TRIGGER validar_numMov_trigger_2015_2020
BEFORE INSERT OR UPDATE ON contabilidad.Mov2015_2020
FOR EACH ROW
EXECUTE PROCEDURE validar_numMov_unico();

CREATE TRIGGER validar_numMov_trigger_2020_2025
BEFORE INSERT OR UPDATE ON contabilidad.Mov2020_2025
FOR EACH ROW
EXECUTE PROCEDURE validar_numMov_unico();




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
-- CREATE TRIGGER trigger_validar_M_P_tipo
-- BEFORE INSERT OR UPDATE ON contabilidad.Movimientos
-- FOR EACH ROW
-- EXECUTE PROCEDURE validar_M_P_tipo();

CREATE TRIGGER trigger_validar_M_P_tipo_mov2010_2015
BEFORE INSERT OR UPDATE ON contabilidad.Mov2010_2015
FOR EACH ROW
EXECUTE PROCEDURE validar_M_P_tipo();

CREATE TRIGGER trigger_validar_M_P_tipo_mov2015_2020
BEFORE INSERT OR UPDATE ON contabilidad.Mov2015_2020
FOR EACH ROW
EXECUTE PROCEDURE validar_M_P_tipo();

CREATE TRIGGER trigger_validar_M_P_tipo_mov2020_2025
BEFORE INSERT OR UPDATE ON contabilidad.Mov2020_2025
FOR EACH ROW
EXECUTE PROCEDURE validar_M_P_tipo();

-- ============ BITACORA ==============

-- Bitacora para Cuentas
CREATE OR REPLACE FUNCTION registrar_bitacora_cuentas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO contabilidad.Bitacora (accion, detalle)
        VALUES ('INSERT',
                'El usuario: ' || current_user ||
                ' realizó una inserción en la tabla cuentas con el id: ' || NEW.C_numCta ||
                '-' || NEW.c_numsubcta ||
                ' el día: ' || current_timestamp);

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO contabilidad.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user ||
                ' realizó una modificación en la cuenta: ' || NEW.C_numCta ||
                '-' || NEW.c_numsubcta ||
                ' en la fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO contabilidad.Bitacora (accion, detalle)
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
        INSERT INTO contabilidad.Bitacora (accion, detalle)
        VALUES ('INSERT',
                'EL usuario: ' || current_user || ' realizó una inserción en la tabla Polizas con el nuevo registro: '
                    || NEW.P_folio || ' en la fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO contabilidad.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user || ', realizó un cambio de datos en la tabla Polizas en el registro: '
                    || NEW.P_folio || ', con fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO contabilidad.Bitacora (accion, detalle)
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
        INSERT INTO contabilidad.Bitacora (accion, detalle)
        VALUES ('INSERT',
                'EL usuario: ' || current_user || ' realizó una inserción en la tabla Movimientos con el nuevo registro: '
                    || NEW.m_nummov || ' en la fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO contabilidad.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user || ', realizó un cambio de datos en la tabla Movimientos en el registro: '
                    || NEW.m_nummov || ', con fecha de: ' || current_timestamp);

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO contabilidad.Bitacora (accion, detalle)
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

-- CREATE TRIGGER trigger_registrar_bitacora_movimientos
-- AFTER INSERT OR UPDATE OR DELETE  ON contabilidad.Movimientos
-- FOR EACH ROW EXECUTE PROCEDURE registrar_bitacora_movimientos();

CREATE TRIGGER trigger_registrar_bitacora_mov2010_2015
AFTER INSERT OR UPDATE OR DELETE ON contabilidad.Mov2010_2015
FOR EACH ROW
EXECUTE PROCEDURE registrar_bitacora_movimientos();

CREATE TRIGGER trigger_registrar_bitacora_mov2015_2020
AFTER INSERT OR UPDATE OR DELETE ON contabilidad.Mov2015_2020
FOR EACH ROW
EXECUTE PROCEDURE registrar_bitacora_movimientos();

CREATE TRIGGER trigger_registrar_bitacora_mov2020_2025
AFTER INSERT OR UPDATE OR DELETE ON contabilidad.Mov2020_2025
FOR EACH ROW
EXECUTE PROCEDURE registrar_bitacora_movimientos();
-- =========== DATOS ================
-- Inserción de datos
-- Insert para Activo y subcategorías
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

-- Inserción Polizas
---INSERTS POLIZAS // Agregar restrigcion en los polizas diarias pero que solo se pueda ingresar una con la misma fecha
INSERT INTO contabilidad.Polizas
    (P_anio, P_mes, P_dia, P_tipo, P_folio, P_concepto, P_hechoPor, P_revisadoPor, P_autorizadoPor)
VALUES
    (2023, 12, 1, 'I', 8, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 2, 'E', 9, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 3, 'E', 11, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 6, 'E', 13, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 11, 'E', 14, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 12, 'I', 15, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 13, 'E', 16, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 3, 'D', 10, 'Póliza de diario diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 4, 'I', 12, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2023, 12, 6, 'I', 7, 'Póliza de ingresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 12, 5, 'E', 5, 'Póliza de egresos diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 12, 6, 'D', 6, 'Póliza de diario diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 11, 3, 'D', 3, 'Póliza de diario diciembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2022, 11, 4, 'I', 4, 'Póliza de ingresos noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2021, 11, 5, 'E', 1, 'Póliza de egresos noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2021, 11, 6, 'D', 2, 'Póliza de diario noviembre', 'Juan Perez', 'Maria Lopez', 'Carlos Garcia'),
    (2012, 1, 12, 'I', 1, 'Póliza de ingresos de enero', 'Daniel Lopez', 'Mauricio Romero', 'Orlando Rivera'),
    (2012, 1, 13, 'E', 2, 'Póliza de egresos de enero', 'Daniel Lopez', 'Mauricio Romero', 'Orlando Rivera'),
    (2019, 7, 14, 'E', 3, 'Póliza de egresos de julio', 'Daniel Lopez', 'Mauricio Romero', 'Orlando Rivera'),
    (2019, 7, 19, 'I', 4, 'Póliza de ingresos de julio', 'Daniel Lopez', 'Mauricio Romero', 'Orlando Rivera'),
    (2024, 11, 24, 'I', 5, 'Póliza de ingresos de noviembre', 'Daniel Lopez', 'Mauricio Romero', 'Orlando Rivera'),
    (2024, 11, 15, 'E', 6, 'Póliza de egresos de noviembre', 'Daniel Lopez', 'Mauricio Romero', 'Orlando Rivera');

-- Inserción Movimientos: MOV. INGRESO
INSERT INTO contabilidad.Movimientos
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES
    (2023, 12, 1, 'I', 8, 401, 1, 15000), -- Ventas nacionales (positivo)
    (2023, 12, 1, 'I', 8, 401, 1, 15000), -- Ventas nacionales (positivo)
    (2023, 12, 1, 'I', 8, 401, 2, 2000),
    (2012, 1, 12, 'I', 1, 101, 1, 100),
    (2012, 1, 12, 'I', 1, 102, 2, 400),
    (2012, 1, 13, 'E', 2, 101, 1, 500),
    (2012, 1, 13, 'E', 2, 104, 1, -500),
    (2012, 1, 13, 'E', 2, 106, 1, 600),
    (2012, 1, 13, 'E', 2, 107, 2, -600),
    (2019, 7, 14, 'E', 3, 101, 1, 700),
    (2019, 7, 14, 'E', 3, 202, 1, -700),
    (2019, 7, 19, 'I', 4, 203, 1, 1000),
    (2019, 7, 19, 'I', 4, 204, 1, -1000),
    (2019, 7, 19, 'I', 4, 102, 2, 5000),
    (2019, 7, 19, 'I', 4, 105, 2, -5000),
    (2024, 11, 24, 'I', 5, 105, 1, 600),
    (2024, 11, 24, 'I', 5, 202, 1, -600),
    (2024, 11, 15, 'E', 6, 106, 2, 5000),
    (2024, 11, 15, 'E', 6, 202, 1, -5000),
    (2024, 11, 15, 'E', 6, 102, 2, 9000),
    (2024, 11, 15, 'E', 6, 204, 2, -9000);

-- Costo de Ventas Netas (Costos)
INSERT INTO contabilidad.Movimientos
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES

    --(2013, 12, 2, 'E', 2, 501, 1, -1000),
    (2013, 12, 2, 'E', 5, 501, 2, -200),
    (2017, 12, 2, 'E', 7, 501, 3, -350),
    (2017, 12, 2, 'E', 10, 501, 1, -700),
    (2024, 12, 2, 'E', 12, 501, 2, -250),
    (2024, 12, 2, 'E', 15, 501, 3, -750);


-- MOV. DIARIOS
INSERT INTO contabilidad.Movimientos
    (M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_numCta, M_C_numSubCta, M_monto)
VALUES
    --(2013, 12, 3, 'D', 3, 601, 2, -8000),
    (2017, 12, 3, 'D', 8, 601, 1, -500),
    (2024, 12, 3, 'D', 13, 602, 1, -100);

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

-- Segmentación
CREATE VIEW poliza_ingreso AS
SELECT * FROM contabilidad.polizas WHERE P_tipo = 'I';

CREATE VIEW poliza_egreso AS
SELECT * FROM contabilidad.polizas WHERE P_tipo = 'E';

CREATE VIEW poliza_diario AS
SELECT * FROM contabilidad.polizas WHERE P_tipo = 'D';

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


-- Usuarios
REVOKE ALL PRIVILEGES ON contabilidad.cuentas FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.polizas FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.empresa FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.movimientos FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.activos FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.capital FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.costos FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.gastos FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.ingresos FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.pasivos FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.poliza_diario FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.poliza_egreso FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.poliza_ingreso FROM maestro;
REVOKE ALL PRIVILEGES ON contabilidad.bitacora FROM maestro;
REVOKE ALL PRIVILEGES ON SCHEMA contabilidad FROM maestro;
REVOKE ALL PRIVILEGES ON SEQUENCE contabilidad.bitacora_id_seq FROM maestro;
REVOKE ALL PRIVILEGES ON SEQUENCE contabilidad.movimientos_m_nummov_seq from maestro;

-- Crear los usuarios
DROP USER IF EXISTS maestro;
DROP ROLE IF EXISTS maestro;
CREATE USER maestro WITH PASSWORD 'maestro';
GRANT ALL PRIVILEGES ON contabilidad.cuentas TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.polizas TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.empresa TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.movimientos TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.activos TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.capital TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.costos TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.gastos TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.ingresos TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.pasivos TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.poliza_diario TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.poliza_egreso TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.poliza_ingreso TO maestro;
GRANT ALL PRIVILEGES ON contabilidad.bitacora TO maestro;
REVOKE ALL PRIVILEGES ON contabilidad.bitacora FROM maestro;
REVOKE SELECT ON contabilidad.bitacora FROM maestro;


-- CREATE USER usuario WITH PASSWORD 'usuario';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA contabilidad TO usuario;
REVOKE ALL PRIVILEGES ON contabilidad.Bitacora FROM usuario;
ALTER DEFAULT PRIVILEGES IN SCHEMA contabilidad GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO usuario;


-- CREATE USER auditor WITH PASSWORD 'auditor';
-- Asignación de permisos de lectura al usuario "auditor" para poder ingresar a la visibilidad de la tabla:
REVOKE ALL ON SCHEMA contabilidad FROM auditor;
REVOKE ALL ON ALL TABLES IN SCHEMA contabilidad FROM auditor;
GRANT USAGE ON SCHEMA contabilidad TO auditor; -- Conceder acceso al esquema
GRANT SELECT ON contabilidad.Bitacora TO auditor; -- Conceder permisos de solo lectura a la tabla
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA contabilidad FROM auditor;



-- Creación de la tabla Bitácora
CREATE TABLE registros_bitacora.Bitacora (
    id SERIAL PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
);

-- Trigger function para Polizas
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
-- Considerando los puntos es necesario eliminar registros
-- Bitacora para Cuentas
CREATE OR REPLACE FUNCTION registrar_bitacora_cuentas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('INSERT',
                'El usuario: ' || current_user ||
                ' realizó una inserción en la tabla cuentas con el id: ' || NEW.c_tipocta ||
                '-' || NEW.c_numsubcta ||
                ' el día: ' || NOW());

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user ||
                ' realizó una modificación en la cuenta: ' || NEW.c_tipocta ||
                '-' || NEW.c_numsubcta ||
                ' en la fecha de: ' || NOW());

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('DELETE',
                'El usuario: ' || current_user ||
                ' realizó la eliminación de la cuenta: ' || OLD.c_tipocta ||
                '-' || OLD.c_numsubcta ||
                ' en la fecha de: ' || NOW());
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
                    || NEW.P_folio || ' en la fecha de: ' || NOW());

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user || ', realizó un cambio de datos en la tabla Polizas en el registro: '
                    || NEW.P_folio || ', con fecha de: ' || NOW());

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('DELETE',
                   --'Se eliminó un registro en Polizas con ID: ' || OLD.P_folio);
               'El usuario: ' || current_user || ', realizó una eliminación de datos en la tabla Polizas en el registro: '
                    || OLD.P_folio || ', con fecha de: ' || NOW());
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
                    || NEW.m_nummov || ' en la fecha de: ' || NOW());

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('UPDATE',
                'El usuario: ' || current_user || ', realizó un cambio de datos en la tabla Movimientos en el registro: '
                    || NEW.m_nummov || ', con fecha de: ' || NOW());

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO registros_bitacora.Bitacora (accion, detalle)
        VALUES ('DELETE',
                   --'Se eliminó un registro en Polizas con ID: ' || OLD.P_folio);
               'El usuario: ' || current_user || ', realizó una eliminación de datos en la tabla Movimientos en el registro: '
                    || OLD.m_nummov || ', con fecha de: ' || NOW());
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
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
(101, 1, 'Activo', 'Caja y Bancos'),
(101, 2, 'Activo', 'Cuentas por Cobrar'),
(101, 3, 'Activo', 'Inventarios'),
(101, 4, 'Activo', 'Activos Fijos'),
(101, 5, 'Activo', 'Inversiones'),
(102, 1, 'Pasivo', 'Cuentas por Pagar'),
(102, 2, 'Pasivo', 'Proveedores'),
(102, 3, 'Pasivo', 'Acreedores Diversos'),
(102, 4, 'Pasivo', 'Préstamos Bancarios'),
(102, 5, 'Pasivo', 'Obligaciones'),
(201, 1, 'Capital', 'Capital Social'),
(201, 2, 'Capital', 'Resultados Acumulados'),
(201, 3, 'Capital', 'Reserva Legal'),
(202, 1, 'Ingresos', 'Ventas'),
(202, 2, 'Ingresos', 'Ingresos Diversos'),
(203, 1, 'Costos', 'Costo de Ventas'),
(203, 2, 'Costos', 'Costos de Producción'),
(204, 1, 'Gastos', 'Gastos Administrativos'),
(204, 2, 'Gastos', 'Gastos de Ventas'),
(204, 3, 'Gastos', 'Gastos Financieros');

INSERT INTO contabilidad.Polizas
(P_anio, P_mes, P_dia, P_tipo, P_folio, P_concepto, P_hechoPor, P_revisadoPor, P_autorizadoPor)
VALUES
(2023, 1, 15, 'I', 1001, 'Ingreso por venta', 'Carlos Pérez', 'Ana López', 'Juan Martínez'),
(2023, 2, 10, 'E', 1002, 'Pago a proveedores', 'María García', 'Pedro Sánchez', 'Laura Gómez'),
(2023, 3, 20, 'D', 1003, 'Ajuste contable', 'Jorge Díaz', 'Sofía Fernández', 'Roberto Castro'),
(2024, 4, 5, 'I', 1004, 'Venta de activos', 'Claudia Ortiz', 'Lucía Hernández', 'José Ramírez'),
(2024, 5, 12, 'E', 1005, 'Pago de servicios', 'Miguel Torres', 'Carmen Morales', 'David Romero'),
(2024, 6, 25, 'D', 1006, 'Ajuste de inventario', 'Raúl Herrera', 'Sara Jiménez', 'Tomás Vega'),
(2022, 7, 8, 'I', 1007, 'Cobro de cuentas', 'Elena Vázquez', 'Manuel Ríos', 'Diana Salazar'),
(2022, 8, 18, 'E', 1008, 'Gastos de viaje', 'Pablo Ruiz', 'Gloria Campos', 'Isabel Flores'),
(2022, 9, 30, 'D', 1009, 'Ajuste de cierre', 'Daniel García', 'Verónica Medina', 'Oscar Navarro'),
(2021, 10, 22, 'I', 1010, 'Ingreso extraordinario', 'Luis Álvarez', 'Eva Paredes', 'Hugo León'),
(2021, 11, 11, 'E', 1011, 'Pago de nómina', 'Adriana Núñez', 'Victor Silva', 'Ricardo Montes'),
(2021, 12, 3, 'D', 1012, 'Depreciación', 'Fernando Vargas', 'Teresa Cruz', 'Paola Méndez'),
(2023, 1, 6, 'I', 1013, 'Recuperación de cartera', 'Marta Reyes', 'Eduardo Santos', 'Ángela Peña'),
(2023, 2, 27, 'E', 1014, 'Compra de insumos', 'Andrés Robles', 'Felicia Valencia', 'Clara Cabrera'),
(2024, 3, 14, 'D', 1015, 'Corrección de saldo', 'Gabriel Suárez', 'Rosa Villanueva', 'Emilio Correa'),
(2024, 4, 19, 'I', 1016, 'Pago por servicios', 'Patricia Morales', 'José Luis Domínguez', 'Liliana Soto'),
(2024, 5, 2, 'E', 1017, 'Mantenimiento de equipo', 'Rodrigo Fuentes', 'Monica Lozano', 'Samuel Aguirre'),
(2022, 6, 7, 'D', 1018, 'Rectificación de cuentas', 'Julieta Ramírez', 'Arturo Palacios', 'Esteban Salinas'),
(2022, 7, 16, 'I', 1019, 'Venta al contado', 'Francisco Sánchez', 'Lorena Vargas', 'Berenice Tapia'),
(2022, 8, 23, 'E', 1020, 'Reembolso de gastos', 'Alberto Espinoza', 'Leticia Carrillo', 'Natalia Domínguez');

INSERT INTO contabilidad.Movimientos
(M_P_anio, M_P_mes, M_P_dia, M_P_tipo, M_P_folio, M_C_tipoCta, M_C_numSubCta, M_monto)
VALUES
(2023, 1, 15, 'I', 1001, 101, 1, 1500.00),   -- Ingreso por venta
(2023, 2, 10, 'E', 1002, 102, 2, 300.00),    -- Pago a proveedores
(2023, 3, 20, 'D', 1003, 101, 3, 200.00),    -- Ajuste contable
(2024, 4, 5, 'I', 1004, 101, 4, 5000.00),    -- Venta de activos
(2024, 5, 12, 'E', 1005, 102, 1, 1200.00),   -- Pago de servicios
(2024, 6, 25, 'D', 1006, 101, 5, 750.00),    -- Ajuste de inventario
(2022, 7, 8, 'I', 1007, 101, 1, 800.00),     -- Cobro de cuentas
(2022, 8, 18, 'E', 1008, 102, 3, 950.00),    -- Gastos de viaje
(2022, 9, 30, 'D', 1009, 101, 2, 430.00),    -- Ajuste de cierre
(2021, 10, 22, 'I', 1010, 101, 2, 3000.00);  -- Ingreso extraordinario

-- Segmentación
-- Segmentación por dato fijo
CREATE VIEW contabilidad.polizas_2020 AS
    SELECT * FROM contabilidad.Polizas WHERE P_anio = 2020;

-- Segmentación por rangos
CREATE VIEW contabilidad.polizas_2010_2020 AS
    SELECT * FROM contabilidad.Polizas WHERE P_anio BETWEEN 2010 AND 2020;

-- Segmentación por tipos
CREATE VIEW contabilidad.poliza_ingreso AS
    SELECT * FROM contabilidad.Polizas WHERE P_tipo = 'I';

CREATE VIEW contabilidad.poliza_egreso AS
    SELECT * FROM contabilidad.Polizas WHERE P_tipo = 'E';

CREATE VIEW contabilidad.poliza_diario AS
    SELECT * FROM contabilidad.Polizas WHERE P_tipo = 'D';

-- Segmentación por vistas combinadas
    -- Año en específico
CREATE VIEW contabilidad.polizas_2023_ingresos AS
    SELECT * FROM contabilidad.Polizas WHERE P_anio = 2023 AND P_tipo = 'I';
    -- Por rango de años
CREATE VIEW contabilidad.polizas_2010_2020_egresos AS
    SELECT * FROM contabilidad.Polizas
        WHERE P_anio BETWEEN 2010 AND 2020
            AND P_tipo = 'E';

-- Asignación de permisos de lectura al usuario "auditor" para poder ingresar a la visibilidad de la tabla:
REVOKE ALL ON SCHEMA registros_bitacora FROM auditor;
REVOKE ALL ON ALL TABLES IN SCHEMA registros_bitacora FROM auditor;
GRANT USAGE ON SCHEMA registros_bitacora TO auditor; -- Conceder acceso al esquema
GRANT SELECT ON registros_bitacora.Bitacora TO auditor; -- Conceder permisos de solo lectura a la tabla
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA registros_bitacora FROM auditor;


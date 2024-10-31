




---- POSTGRESQL
--funcion para la bitacora
CREATE OR REPLACE FUNCTION fn_registrar_auditoria()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario TEXT;
    v_sentencia TEXT;
BEGIN
    -- Obtener el nombre del usuario
    v_usuario := current_user;

    -- Obtener la sentencia SQL ejecutada
    v_sentencia := current_query();

    -- Insertar el registro en la tabla de bitácora
    INSERT INTO bitacora_auditoria (
        usuario, base_datos, sentencia_sql
    ) VALUES (
        v_usuario, current_database(), v_sentencia
    );

    -- Retornar las filas modificadas según la operación
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

--- funcion para la que solo ingresar I E D en tipo de poliza
CREATE OR REPLACE FUNCTION check_poliza_tipo()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que el valor de P_tipo sea uno de los valores permitidos
    IF NOT (NEW.P_tipo = 'I' OR NEW.P_tipo = 'E' OR NEW.P_tipo = 'D') THEN
        RAISE EXCEPTION 'Valor inválido', NEW.P_tipo;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


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

-- Trigger para la bitácora de Cuentas
CREATE TRIGGER trigger_registrar_bitacora_cuentas
AFTER INSERT OR UPDATE OR DELETE  ON contabilidad.Cuentas
FOR EACH ROW EXECUTE PROCEDURE registrar_bitacora_cuentas();
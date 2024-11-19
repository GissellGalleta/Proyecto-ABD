






----POSTGRESQL
---triggers para bitacoras por tabla
CREATE TRIGGER trg_auditoria_polizas
AFTER INSERT OR UPDATE OR DELETE ON contabilidad.polizas
FOR EACH ROW EXECUTE PROCEDURE fn_registrar_auditoria();

CREATE TRIGGER trg_auditoria_cuentas
AFTER INSERT OR UPDATE OR DELETE ON contabilidad.cuentas
FOR EACH ROW EXECUTE PROCEDURE fn_registrar_auditoria();

CREATE TRIGGER trg_auditoria_movimientos
AFTER INSERT OR UPDATE OR DELETE ON contabilidad.movimientos
FOR EACH ROW EXECUTE PROCEDURE fn_registrar_auditoria();

---- trigger para llamar a la función check_poliza_tipo
CREATE TRIGGER trigger_check_poliza_tipo
BEFORE INSERT OR UPDATE ON contabilidad.polizas
FOR EACH ROW
EXECUTE FUNCTION check_poliza_tipo();

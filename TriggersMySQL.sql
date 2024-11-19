CREATE TRIGGER trigger_insert_cuentas
AFTER INSERT ON Cuentas
FOR EACH ROW
BEGIN
    DECLARE exit HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, inserta en la bitacora el fallo
        INSERT INTO bitacora (accion, detalle)
        VALUES ('INSERT ERROR', CONCAT('El usuario: ', current_user, ', intentó realizar una inserción con cuenta con ID: ', NEW.C_numCta, '-', NEW.C_numSubCta, ', con Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
    END;

    -- Si la inserción es exitosa, ejecuta esta acción
    INSERT INTO bitacora (accion, detalle)
    VALUES ('INSERT', CONCAT('El usuario: ', current_user, ', insertó una cuenta con ID: ', NEW.C_numCta, '-', NEW.C_numSubCta, ', con Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_cuentas
AFTER UPDATE ON Cuentas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE', CONCAT('El usuario: ',current_user,', actualizó la cuenta con ID: ', NEW.C_numCta, '-', NEW.C_numSubCta, ' Nombre: ', NEW.C_nomCta, ' Subcuenta: ', NEW.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_cuentas
AFTER DELETE ON Cuentas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE', CONCAT('El usuario: ',current_user, ', eliminó la cuenta con ID: ', OLD.C_numCta, '-', OLD.C_numSubCta, ' Nombre: ', OLD.C_nomCta, ' Subcuenta: ', OLD.C_nomSubCta, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_insert_polizas
AFTER INSERT ON Polizas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('INSERT', CONCAT('El usuario ', current_user, ' insertó una póliza con ID: ', NEW.P_anio, '-', NEW.P_mes, '-', NEW.P_tipo, '-', NEW.P_folio, ', Concepto: ', NEW.P_concepto, ', hecho por: ', NEW.P_hechoPor,
               ', revisado por: ', NEW.P_revisadoPor, ', autorizado por: ', NEW.P_autorizadoPor, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_polizas
AFTER UPDATE ON Polizas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE',
        CONCAT('El usuario ', current_user, ' actualizó la póliza con ID: ', NEW.P_anio, '-', NEW.P_mes, '-', NEW.P_tipo, '-', NEW.P_folio, ', Concepto: ', NEW.P_concepto, ', hecho por: ', NEW.P_hechoPor,
               ', revisado por: ', NEW.P_revisadoPor, ', autorizado por: ',NEW.P_autorizadoPor, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_polizas
AFTER DELETE ON Polizas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE',CONCAT('El usuario ', current_user, ' eliminó la póliza con ID: ',OLD.P_anio, '-', OLD.P_mes, '-', OLD.P_tipo, '-', OLD.P_folio,', Concepto: ', OLD.P_concepto, ', hecho por: ', OLD.P_hechoPor,
               ', revisado por: ', OLD.P_revisadoPor, ', autorizado por: ',OLD.P_autorizadoPor, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_insert_movimientos
AFTER INSERT ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('INSERT', CONCAT('El usuario ', current_user, ' insertó un movimiento con ID: ',
               NEW.M_numMov, ', Cuenta: ', NEW.M_C_numCta, '-', NEW.M_C_numSubCta,
               ', Monto: ', NEW.M_monto, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_update_movimientos
AFTER UPDATE ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('UPDATE',
        CONCAT('El usuario ', current_user, ' actualizó el movimiento con ID: ',
               NEW.M_numMov, ', Cuenta: ', NEW.M_C_numCta, '-', NEW.M_C_numSubCta,
               ', Monto: ', NEW.M_monto, ', a fecha de: ', SYSDATE()));
END//

CREATE TRIGGER trigger_delete_movimientos
AFTER DELETE ON Movimientos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle)
    VALUES ('DELETE',
        CONCAT('El usuario ', current_user, ' eliminó el movimiento con ID: ',
               OLD.M_numMov, ', Cuenta: ', OLD.M_C_numCta, '-', OLD.M_C_numSubCta,
               ', Monto: ', OLD.M_monto, ', a fecha de: ', SYSDATE()));
END//

DELIMITER ;
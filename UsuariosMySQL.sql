-- Creación de usuarios después de generar las tablas correspondientes:
    -- usuario Maestro
CREATE USER 'maestro'@'%' IDENTIFIED BY 'maestro';
REVOKE ALL PRIVILEGES on *.* from 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.cuentas To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.polizas To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.empresa To 'maestro'@'%';
GRANT ALL PRIVILEGES ON contabilidad.movimientos To 'maestro'@'%';

-- Creación del usuario Auditor:
CREATE USER 'auditor'@'%' IDENTIFIED BY 'auditor';
GRANT SELECT ON contabilidad.Bitacora TO 'auditor'@'%';
REVOKE ALL PRIVILEGES ON *.* FROM 'auditor'@'%';

-- Creación de usuario promedio
CREATE USER 'usuario'@'%' IDENTIFIED BY 'usuario';
REVOKE ALL PRIVILEGES ON *.* FROM 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.cuentas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.empresa to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.polizas to 'usuario'@'%';
GRANT INSERT, SELECT, UPDATE, DELETE on contabilidad.movimientos to 'usuario'@'%';
FLUSH PRIVILEGES;
-- Esta es una lista con los comandos para la gestión de usuarios en mysql y postgres:
-- ==================== POSTGRESQL
-- AUTIDOR
-- Todo esto es para poder darle únicamente permisos de consulta al usuario administrador
\c proyecto_equipo1;
CREATE USER auditor WITH PASSWORD 'auditor';
REVOKE ALL ON SCHEMA registros_bitacora FROM auditor;
REVOKE ALL ON ALL TABLES IN SCHEMA registros_bitacora FROM auditor;
GRANT USAGE ON SCHEMA registros_bitacora TO auditor; -- Conceder acceso al esquema
GRANT SELECT ON registros_bitacora.Bitacora TO auditor; -- Conceder permisos de solo lectura a la tabla
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA registros_bitacora FROM auditor;
-- si después se quieren revocar todos los permisos es:
REVOKE SELECT ON registros_bitacora.Bitacora FROM auditor;

-- revocar el acceso al otro esquema
REVOKE USAGE ON SCHEMA contabilidad FROM auditor;
-- eliminar permisos de todo el esquema:
REVOKE ALL ON ALL TABLES IN SCHEMA contabilidad FROM auditor;




-- ============= MYSQL
CREATE USER 'auditor'@'%' IDENTIFIED BY 'auditor';
GRANT SELECT ON contabilidad.Bitacora TO 'auditor'@'%';
REVOKE ALL PRIVILEGES ON *.* FROM 'auditor'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'auditor'@'localhost';

CREATE USER 'maestro'@'%' IDENTIFIED BY 'maestro';
GRANT ALL PRIVILEGES ON *.* To 'maestro'@'%';
REVOKE ALL PRIVILEGES ON contabilidad.bitacora FROM 'maestro'@'%';
FLUSH PRIVILEGES;

CREATE USER 'usuario'@'%' IDENTIFIED BY 'usuario';
GRANT INSERT, SELECT, UPDATE, DELETE on *.* to 'usuario'@'%';
REVOKE ALL PRIVILEGES ON contabilidad.bitacora FROM 'usuario'@'%';



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

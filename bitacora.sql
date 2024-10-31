








---- POSTGRESQL

CREATE TABLE bitacora_auditoria (
    id SERIAL PRIMARY KEY,         -- Identificador único para cada entrada de la bitácora
    usuario VARCHAR(50),           -- Usuario que hizo el cambio
    fecha TIMESTAMP DEFAULT NOW(), -- Fecha y hora del cambio
    base_datos VARCHAR(50),        -- Base de datos donde ocurrió el cambio
    sentencia_sql TEXT             -- La sentencia SQL ejecutada
);

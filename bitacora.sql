








---- POSTGRESQL

CREATE TABLE bitacora_auditoria (
    id SERIAL PRIMARY KEY,         -- Identificador único para cada entrada de la bitácora
    usuario VARCHAR(50),           -- Usuario que hizo el cambio
    fecha TIMESTAMP DEFAULT NOW(), -- Fecha y hora del cambio
    base_datos VARCHAR(50),        -- Base de datos donde ocurrió el cambio
    sentencia_sql TEXT             -- La sentencia SQL ejecutada
);


-- Mi sugerencia en la bitácora sería ahorrar atributos y concatenarlos de la siguiente manera:

CREATE TABLE bitacora_LMD (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(50),
    detalle TEXT
);

-- Triger Insert:
DELIMITER //

CREATE TRIGGER trigger_insert AFTER INSERT ON tu_tabla
FOR EACH ROW
BEGIN
    INSERT INTO bitacora_LMD (accion, detalle)
    VALUES (
        'INSERT',
        CONCAT(
            'El usuario ', USER(),
            ' el día ', DATE_FORMAT(NOW(), '%d/%m/%Y'),
            ', creó el registro con ID: ', NEW.id
        )
    );
END //

CREATE TRIGGER trigger_update AFTER UPDATE ON tu_tabla
FOR EACH ROW
BEGIN
    INSERT INTO bitacora_LMD (accion, detalle)
    VALUES (
        'UPDATE',
        CONCAT(
            'El usuario ', USER(),
            ' el día ', DATE_FORMAT(NOW(), '%d/%m/%Y'),
            ', modificó el registro con ID: ', NEW.id
        )
    );
END //

CREATE TRIGGER trigger_delete AFTER DELETE ON tu_tabla
FOR EACH ROW
BEGIN
    INSERT INTO bitacora_LMD (accion, detalle)
    VALUES (
        'DELETE',
        CONCAT(
            'El usuario ', USER(),
            ' el día ', DATE_FORMAT(NOW(), '%d/%m/%Y'),
            ', borró el registro con ID: ', OLD.id
        )
    );
END //

DELIMITER ;

-- en toría debería guardar algo másomenos así: El usuario admin el día 09/11/2024, creó el registro con ID: 123



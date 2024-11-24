--Modificación en la tabla Pólizas para que no se repite P_folio en un mismo año
CREATE TABLE Polizas (
    P_anio smallint(4) NOT NULL,
    P_mes smallint(2) NOT NULL,
    P_dia smallint(2) DEFAULT NULL,
    P_tipo char(1) NOT NULL,
    P_folio smallint(6) NOT NULL,
    P_concepto varchar(40) DEFAULT NULL,
    P_hechoPor varchar(40) DEFAULT NULL,
    P_revisadoPor varchar(40) DEFAULT NULL,
    P_autorizadoPor varchar(40) DEFAULT NULL,
    PRIMARY KEY (P_anio, P_mes, P_tipo, P_folio),
    UNIQUE KEY idx_anio_folio_unico (P_anio, P_folio)
);

--Trigger para validar que los datos ingresados en P_tipo puedan ser unicamente 'I', 'E' y 'D'
DELIMITER $$

CREATE TRIGGER validacionPolizasP_tipo
BEFORE INSERT ON Polizas
FOR EACH ROW
BEGIN
    -- Verificar que el valor de P_tipo sea válido
    IF NEW.P_tipo NOT IN ('I', 'D', 'E') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Valor no permitido para M_P_tipo. Debe ser I (Ingresos) | D (Diario) | E (Egresos).';

    END IF;
END$$

--Trigger para que al actualizar datos en la tabla póliza en P_tipo no se ingresen datos diferentes de 'I', 'E' y 'D'
DELIMITER $$

CREATE TRIGGER validacionUpdatePolizasP_tipo
BEFORE UPDATE ON Polizas
FOR EACH ROW
BEGIN
    -- Verificar que el valor de P_tipo sea válido
    IF NEW.P_tipo NOT IN ('I', 'D', 'E') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Valor no permitido para M_P_tipo. Debe ser I (Ingresos) | D (Diario) | E (Egresos).';

    END IF;
END$$


--Trigger para validar que solamente pueda existir una póliza de diario 'D' al día
DELIMITER //

CREATE TRIGGER insertpolizasD_unico
BEFORE INSERT ON Polizas
FOR EACH ROW
BEGIN
    IF NEW.P_tipo = 'D' THEN
        -- Verificar si ya existe una póliza del mismo día
        IF EXISTS (
            SELECT 1 
            FROM Polizas 
            WHERE P_anio = NEW.P_anio
              AND P_mes = NEW.P_mes
              AND P_dia = NEW.P_dia
              AND P_tipo = 'D'
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ya existe una póliza de diario para este día';
        END IF;
    END IF;
END;
//




--Tabla Movimientos particionada
CREATE TABLE Movimientos (
    M_P_anio SMALLINT(4) NOT NULL,
    M_P_mes SMALLINT(2) NOT NULL,
    M_P_dia SMALLINT(2) NOT NULL,
    M_P_tipo CHAR(1) NOT NULL,
    M_P_folio SMALLINT(6) NOT NULL,
    M_numMov INT AUTO_INCREMENT,
    M_C_numCta SMALLINT(3) NOT NULL,
    M_C_numSubCta SMALLINT(1) NOT NULL,
    M_monto DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (M_numMov, M_P_anio)
)
PARTITION BY RANGE (M_P_anio) (
    PARTITION Mov2010_2015 VALUES LESS THAN (2015),
    PARTITION Mov2015_2020 VALUES LESS THAN (2020),
    PARTITION Mov2020_2025 VALUES LESS THAN (2025)
);


--Trigger para validar que los datos insertados en la tabla Movimientos existan en la tabla Pólizas 
DELIMITER $$

CREATE TRIGGER validacionInsert_fk_polizas
BEFORE INSERT ON Movimientos
FOR EACH ROW
BEGIN
    -- Verificar que el año exista
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El año especificado no existe en la tabla Polizas.';
    END IF;

    -- Verificar que el mes exista para el año especificado
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El mes especificado no existe para el año proporcionado en la tabla Polizas.';
    END IF;

    -- Verificar que el tipo de póliza exista para el año y mes especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El tipo de póliza especificado no existe para el año y mes proporcionados en la tabla Polizas.';
    END IF;

    -- Verificar que el folio exista para el año, mes y tipo de póliza especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
          AND P_folio = NEW.M_P_folio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El folio especificado no existe para el año, mes y tipo de póliza proporcionados en tabla Polizas.';
    END IF;
END$$

DELIMITER ;


--Trigger para validar que los datos actualizados en la tabla Movimientos existan en la tabla Pólizas 
DELIMITER $$

CREATE TRIGGER validacionUpdate_fk_polizas
BEFORE UPDATE ON Movimientos
FOR EACH ROW
BEGIN
   
    -- Verificar que el año exista
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El año especificado no existe en la tabla Polizas.';
    END IF;

    -- Verificar que el mes exista para el año especificado
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El mes especificado no existe para el año proporcionado en la Polizas.';
    END IF;

    -- Verificar que el tipo de póliza exista para el año y mes especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El tipo de póliza especificado no existe para el año y mes proporcionados en la tabla Polizas.';
    END IF;

    -- Verificar que el folio exista para el año, mes y tipo de póliza especificados
    IF NOT EXISTS (
        SELECT 1
        FROM Polizas
        WHERE P_anio = NEW.M_P_anio
          AND P_mes = NEW.M_P_mes
          AND P_tipo = NEW.M_P_tipo
          AND P_folio = NEW.M_P_folio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El folio especificado no existe para el año, mes y tipo de póliza proporcionados en la tabla Polizas.';
    END IF;
END$$

DELIMITER ;


--Trigger para validar que los datos insertados en la tabla Movimientos existan en la tabla Cuentas
DELIMITER $$

CREATE TRIGGER validacionInsert_fk_cuentas
BEFORE INSERT ON Movimientos
FOR EACH ROW
BEGIN
    DECLARE error_message VARCHAR(255); -- Declarar una variable para almacenar el mensaje

    -- Validar si M_C_numCta no existe en la tabla Cuentas
    IF NOT EXISTS (
        SELECT 1
        FROM Cuentas
        WHERE C_numCta = NEW.M_C_numCta
    ) THEN
        SET error_message = CONCAT('Error: El valor de M_C_numCta = ', NEW.M_C_numCta, ' no existe en la tabla Cuentas.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = error_message;
    END IF;

    -- Validar si M_C_numSubCta no existe en combinación con M_C_numCta
    IF NOT EXISTS (
        SELECT 1
        FROM Cuentas
        WHERE C_numCta = NEW.M_C_numCta
          AND C_numSubCta = NEW.M_C_numSubCta
    ) THEN
        SET error_message = CONCAT('Error: La combinación de M_C_numCta = ', NEW.M_C_numCta, ' y M_C_numSubCta = ', NEW.M_C_numSubCta, ' no existe en la tabla Cuentas.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = error_message;
    END IF;
END$$

DELIMITER ;


--Trigger para validar que los datos actualizados en la tabla Movimientos existan en la tabla Cuentas 
DELIMITER $$

CREATE TRIGGER validacionUpdate_fk_cuentas
BEFORE UPDATE ON Movimientos
FOR EACH ROW
BEGIN
    -- Validar que la combinación de M_C_numCta y M_C_numSubCta exista en la tabla Cuentas
    IF NOT EXISTS (
        SELECT 1
        FROM Cuentas
        WHERE C_numCta = NEW.M_C_numCta
          AND C_numSubCta = NEW.M_C_numSubCta
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La combinación de M_C_numCta y M_C_numSubCta no existe en la tabla Cuentas.';
    END IF;
END$$

DELIMITER ;
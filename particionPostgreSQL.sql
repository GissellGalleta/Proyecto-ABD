--Triggers y función de la tabla pólizas para validar la inserción y actualización de datos en el atributo p_tipo, unicamente sea I, E y D
CREATE OR REPLACE FUNCTION validar_tipo_polizas()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que P_tipo sea uno de los valores permitidos
    IF NEW.P_tipo NOT IN ('I', 'E', 'D') THEN
        RAISE EXCEPTION 'Error: El valor de P_tipo = % no es válido. Debe ser ''I'', ''E'' o ''D''.', NEW.P_tipo;
    END IF;

    RETURN NEW; -- Permitir la operación si el valor es válido
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_tipo_polizas_trigger
BEFORE INSERT OR UPDATE ON contabilidad.Polizas
FOR EACH ROW
EXECUTE FUNCTION validar_tipo_polizas();


--Tabla particionada
CREATE TABLE Contabilidad.Movimientos ( 
    M_P_anio SMALLINT NOT NULL, 
    M_P_mes SMALLINT NOT NULL, 
    M_P_dia SMALLINT NOT NULL, 
    M_P_tipo CHAR(1) NOT NULL, 
    M_P_folio SMALLINT NOT NULL, 
    M_numMov SERIAL NOT NULL, 
    M_C_numCta SMALLINT NOT NULL, 
    M_C_numSubCta SMALLINT NOT NULL, 
    M_monto DECIMAL(10,2) NOT NULL 
) PARTITION BY RANGE (M_P_anio); 
 
-- Se crean particiones para los rangos de años especificados: 
CREATE TABLE Mov2010_2015 PARTITION OF Contabilidad.Movimientos 
FOR VALUES FROM (2010) TO (2015); 
  
CREATE TABLE Mov2015_2020 PARTITION OF Contabilidad.Movimientos 
FOR VALUES FROM (2015) TO (2020); 
  
CREATE TABLE Mov2020_2025 PARTITION OF Contabilidad.Movimientos 
FOR VALUES FROM (2020) TO (2025); 

--Función y Triggers para validar la inserción y actualización de datos de cuentas y polizas en la tabla movimientos
CREATE OR REPLACE FUNCTION validar_fk_movimientos() 
RETURNS TRIGGER AS $$ 
BEGIN 
    -- Validar que M_C_numCta y M_C_numSubCta existen en Contabilidad.Cuentas 
    IF NOT EXISTS ( 
        SELECT 1 
        FROM Contabilidad.Cuentas 
        WHERE C_numCta = NEW.M_C_numCta 
          AND C_numSubCta = NEW.M_C_numSubCta 
    ) THEN 
        RAISE EXCEPTION 'Error: La combinación de M_C_numCta = %, M_C_numSubCta = % no existe en Cuentas.', 
            NEW.M_C_numCta, NEW.M_C_numSubCta; 
    END IF; 
  
    -- Validar que M_P_anio, M_P_mes, M_P_tipo y M_P_folio existen en Contabilidad.Polizas 
    IF NOT EXISTS ( 
        SELECT 1 
        FROM Contabilidad.Polizas 
        WHERE P_anio = NEW.M_P_anio 
          AND P_mes = NEW.M_P_mes 
          AND P_tipo = NEW.M_P_tipo 
          AND P_folio = NEW.M_P_folio 
    ) THEN 
        RAISE EXCEPTION 'Error: La combinación de M_P_anio = %, M_P_mes = %, M_P_tipo = %, M_P_folio = % no existe en Polizas.', 
            NEW.M_P_anio, NEW.M_P_mes, NEW.M_P_tipo, NEW.M_P_folio; 
    END IF; 
  
    RETURN NEW; 
END; 
$$ LANGUAGE plpgsql; 

CREATE TRIGGER validar_relaciones_movimientos_2010_2015 
BEFORE INSERT OR UPDATE ON Mov2010_2015 
FOR EACH ROW 
EXECUTE PROCEDURE validar_fk_movimientos(); 
  
CREATE TRIGGER validar_relaciones_movimientos_2015_2020 
BEFORE INSERT OR UPDATE ON Mov2015_2020 
FOR EACH ROW 
EXECUTE PROCEDURE validar_fk_movimientos(); 
  
CREATE TRIGGER validar_relaciones_movimientos_2020_2025 
BEFORE INSERT OR UPDATE ON Mov2020_2025 
FOR EACH ROW 
EXECUTE PROCEDURE validar_fk_movimientos(); 

--Función y Trigger para mantener la unicidad global de M_numMov
CREATE OR REPLACE FUNCTION validar_numMov_unico() 
RETURNS TRIGGER AS $$ 
BEGIN 
    -- Validar si M_numMov ya existe en la tabla o particiones 
    IF EXISTS ( 
        SELECT 1 
        FROM contabilidad.Movimientos 
        WHERE M_numMov = NEW.M_numMov 
    ) THEN 
        RAISE EXCEPTION 'Error: El numero de movimiento % ya existe.', NEW.M_numMov; 
    END IF; 
  
    RETURN NEW; 
END; 
$$ LANGUAGE plpgsql; 
  
CREATE TRIGGER validar_numMov_trigger_2010_2015 
BEFORE INSERT OR UPDATE ON Mov2010_2015 
FOR EACH ROW 
EXECUTE PROCEDURE validar_numMov_unico(); 
  
CREATE TRIGGER validar_numMov_trigger_2015_2020 
BEFORE INSERT OR UPDATE ON Mov2015_2020 
FOR EACH ROW 
EXECUTE PROCEDURE validar_numMov_unico(); 
  
CREATE TRIGGER validar_numMov_trigger_2020_2025 
BEFORE INSERT OR UPDATE ON Mov2020_2025 
FOR EACH ROW 
EXECUTE PROCEDURE validar_numMov_unico(); 


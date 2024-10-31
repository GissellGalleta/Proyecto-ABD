CREATE TABLE Movimientos (
    M_P_anio SMALLINT(4),
    M_P_mes SMALLINT(2),
    M_P_dia SMALLINT(2),
    M_P_tipo SMALLINT(1),
    M_P_folio SMALLINT(6),
    M_numMov INT AUTO_INCREMENT,
    M_C_tipoCta SMALLINT(3),
    M_C_numSubCta SMALLINT(1),
    M_monto DECIMAL(10,2),
    PRIMARY KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio, M_numMov),
    FOREIGN KEY (M_P_anio, M_P_mes, M_P_tipo, M_P_folio)
        REFERENCES polizas(P_anio, P_mes, P_tipo, P_folio),
    FOREIGN KEY (M_C_tipoCta, M_C_numSubCta)
        REFERENCES cuentas(C_tipoCta, C_numSubCta)
); 

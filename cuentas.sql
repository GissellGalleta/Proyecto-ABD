CREATE TABLE Cuentas (
    C_numCta SMALLINT(3),
    C_numSubCta SMALLINT(1),
    C_nomCta CHAR(30),
    C_nomSubCta CHAR(30),
    PRIMARY KEY (C_tipoCta, C_numSubCta)
);

CREATE TABLE Cuentas (
    C_numCta SMALLINT(3),
    C_numSubCta SMALLINT(1),
    C_nomCta CHAR(30),
    C_nomSubCta CHAR(30),
    PRIMARY KEY (C_tipoCta, C_numSubCta)
);

---postgresql

CREATE TABLE contabilidad.cuentas (
    C_numCta SMALLINT,
    C_numSubCta SMALLINT,
    C_nomCta CHAR(50),
    C_nomSubCta CHAR(50),
    PRIMARY KEY (C_tipoCta, C_numSubCta)
);
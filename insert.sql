-- Insert para Activo y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (1000, 0, 'Activo', ''),
    (1100, 0, 'Activo circulante', ''),
    (1100, 1, 'Activo circulante', 'Caja'),
    (1100, 2, 'Activo circulante', 'Bancos'),
    (1100, 3, 'Activo circulante', 'Clientes'),
    (1100, 4, 'Activo circulante', 'Mercancías/ Inventarios'),
    (1100, 5, 'Activo circulante', 'Documentos por cobrar'),
    (1100, 6, 'Activo circulante', 'Deudores diversos'),
    (1100, 7, 'Activo circulante', 'IVA acreditable pagado'),
    (1100, 8, 'Activo circulante', 'IVA a favor'),
    (1200, 0, 'Activo fijo', ''),
    (1200, 1, 'Activo fijo', 'Terreno'),
    (1200, 2, 'Activo fijo', 'Mobiliario y equipo'),
    (1200, 3, 'Activo fijo', 'Equipo de transporte'),
    (1200, 4, 'Activo fijo', 'Edificio'),
    (1200, 5, 'Activo fijo', 'Depósitos en garantía'),
    (1200, 6, 'Activo fijo', 'Equipo de cómputo'),
    (1300, 0, 'Activo diferido', ''),
    (1300, 1, 'Activo diferido', 'Gastos de instalación'),
    (1300, 2, 'Activo diferido', 'Papelería y útiles de oficina'),
    (1300, 3, 'Activo diferido', 'Rentas pagadas por adelantado'),
    (1300, 4, 'Activo diferido', 'Seguros pagados por adelantado');

-- Insert para Pasivo y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (2000, 0, 'Pasivo', ''),
    (2100, 0, 'Pasivo circulante', ''),
    (2100, 1, 'Pasivo circulante', 'Documentos por pagar'),
    (2100, 2, 'Pasivo circulante', 'Proveedores'),
    (2100, 3, 'Pasivo circulante', 'Acreedores diversos'),
    (2100, 4, 'Pasivo circulante', 'Sueldos por pagar'),
    (2100, 5, 'Pasivo circulante', 'Impuestos por pagar'),
    (2100, 6, 'Pasivo circulante', 'IVA por acreditar'),
    (2100, 7, 'Pasivo circulante', 'IVA trasladado cobrado'),
    (2100, 8, 'Pasivo circulante', 'IVA por trasladar'),
    (2200, 0, 'Pasivo fijo', ''),
    (2200, 1, 'Pasivo fijo', 'Hipotecas por pagar'),
    (2300, 0, 'Pasivo diferido', ''),
    (2300, 1, 'Pasivo diferido', 'Rentas cobradas por anticipado'),
    (2300, 2, 'Pasivo diferido', 'Intereses cobrados por anticipado');

-- Insert para Capital Contable y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (3000, 0, 'Capital Contable', ''),
    (3100, 0, 'Capital contribuido', ''),
    (3100, 1, 'Capital contribuido', 'Capital social'),
    (3200, 0, 'Capital ganado', ''),
    (3200, 1, 'Capital ganado', 'Utilidades del ejercicio'),
    (3200, 2, 'Capital ganado', 'Pérdidas del ejercicio');

-- Insert para Cuentas de ingreso y subcategorías
INSERT INTO contabilidad.Cuentas (C_tipoCta, C_numSubCta, C_nomCta, C_nomSubCta) VALUES
    (4000, 0, 'Cuentas de ingreso', ''),
    (4100, 0, 'Cuentas de resultados acreedoras', ''),
    (4101, 1, 'Cuentas de resultados acreedoras', 'Ventas'),
    (4102, 1, 'Cuentas de resultados acreedoras', 'Devoluciones sobre compras'),
    (4103, 1, 'Cuentas de resultados acreedoras', 'Rebajas sobre compras');


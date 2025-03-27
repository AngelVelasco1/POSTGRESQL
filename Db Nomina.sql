DROP TABLE IF EXISTS tab_novedades;
DROP TABLE IF EXISTS tab_nomina;
DROP TABLE IF EXISTS tab_emplea;
DROP TABLE IF EXISTS tab_cargos;
DROP TABLE IF EXISTS tab_conceptos;
DROP TABLE IF EXISTS tab_pmtros;
DROP TABLE IF EXISTS tab_meses;

-- SECCIÓN DE CREACIÓN DE TABLAS, PARA INICIAR EL PROCESO
CREATE TABLE IF NOT EXISTS tab_pmtros
(
    id_empresa      DECIMAL(10,0)   NOT NULL, -- ID de la empresa que liquida la nómina
    nom_empresa     VARCHAR         NOT NULL CHECK(LENGTH(nom_empresa) >= 5), -- Nombre de la empresa que liquida la nómina
    ind_perio_pago  CHAR(1)         NOT NULL DEFAULT 'Q' CHECK(ind_perio_pago = 'Q' OR ind_perio_pago = 'M'), --Q QUINCENAL /M MENSUAL
    val_smlv        DECIMAL(8,0)    NOT NULL CHECK(val_smlv > 0), -- Valor del salario mínimo legal vigente para el año según gobierno
    val_auxtrans    DECIMAL (7,0)   NOT NULL CHECK(val_auxtrans > 0 AND val_auxtrans < val_smlv), -- Vr. Aux. Transporte vigente para el año según gobierno
    ind_num_trans   DECIMAL(1)      NOT NULL DEFAULT 2 CHECK(ind_num_trans > 0 AND ind_num_trans < 4), --NÚM. PARA MULTIPLICAR EL SALARAIO, PARA SABER SI PAGAMOS AUXILIO DE TRANSPORTE O NO 
    ano_nomina      DECIMAL(4,0)    NOT NULL DEFAULT 2025, --AÑO VIGENTE
    mes_nomina      DECIMAL(2)      NOT NULL CHECK(mes_nomina >= 1 AND mes_nomina <= 12), --MES VIGENTE
    val_por_intces  DECIMAL(2,0)    NOT NULL DEFAULT 12, -- Vr. porcentaje de intereses a la cesantía
    num_diasmes     DECIMAL(2,0)    NOT NULL DEFAULT 30, -- Número de días del mes fiscal
    PRIMARY KEY(id_empresa)
);
INSERT INTO tab_pmtros VALUES(123456,'EMPRESA LA COSITA RICA','Q',1423500,200000,2,2025,1,12,30);

CREATE TABLE IF NOT EXISTS tab_cargos
(
    id_cargo        DECIMAL(2,0)    NOT NULL,
    nom_cargo       VARCHAR         NOT NULL CHECK(LENGTH(nom_cargo) >= 5),
    PRIMARY KEY(id_cargo)
);

INSERT INTO tab_cargos VALUES(1,'Gerente General');
INSERT INTO tab_cargos VALUES(2,'Secretaria General');
INSERT INTO tab_cargos VALUES(3,'Gerente Comercial');
INSERT INTO tab_cargos VALUES(4,'Gerente Financiero');
INSERT INTO tab_cargos VALUES(5,'Gerente de TI');
INSERT INTO tab_cargos VALUES(6,'Gerente de Mercadeo');
INSERT INTO tab_cargos VALUES(7,'Director de Seguridad de la Información');
INSERT INTO tab_cargos VALUES(8,'Scrum Master');
INSERT INTO tab_cargos VALUES(9,'Desarrollador Front Senior');
INSERT INTO tab_cargos VALUES(10,'Desarrollador Front Junior');
INSERT INTO tab_cargos VALUES(11,'Desarrollador Back Senior');
INSERT INTO tab_cargos VALUES(12,'Desarrollador Back Junior');
INSERT INTO tab_cargos VALUES(13,'Diseñador');
INSERT INTO tab_cargos VALUES(14,'Tester');
INSERT INTO tab_cargos VALUES(15,'Documentador');
INSERT INTO tab_cargos VALUES(16,'Servicios Generales');
INSERT INTO tab_cargos VALUES(17,'Mensajero');
INSERT INTO tab_cargos VALUES(18,'Auxiliar Contable');
INSERT INTO tab_cargos VALUES(19,'Director Contable');
INSERT INTO tab_cargos VALUES(20,'Vigilante');

CREATE TABLE IF NOT EXISTS tab_emplea
(
-- DATOS BÁSICOS DEL EMPLEADO
    id_emplea       DECIMAL(10)     NOT NULL,
    nom_emplea      VARCHAR         NOT NULL CHECK(LENGTH(nom_emplea) >= 3),
    ape_emplea      VARCHAR         NOT NULL CHECK(LENGTH(ape_emplea) >= 2),
    ind_genero      BOOLEAN         NOT NULL, -- TRUE = FEMENINO / FALSE = MASCULINO
    dir_emplea      VARCHAR         NOT NULL CHECK(LENGTH(dir_emplea) >= 5),
    tel_emplea      DECIMAL(10,0)   NOT NULL CHECK(tel_emplea > 2999999999),
    ind_estrato     DECIMAL(1)      NOT NULL CHECK(ind_estrato >= 1 AND ind_estrato <= 6),
-- DATOS PERSONALES
    ind_est_civil   DECIMAL(1)      NOT NULL CHECK(ind_est_civil BETWEEN 0 AND 4), -- 0:Soltero / 1:Casado / 2:Divorciado / 3:Viudo / 4:Otro
    num_hijos       DECIMAL(1,0)    NOT NULL CHECK(num_hijos >= 0 AND num_hijos <= 9),
    val_tipo_sangre VARCHAR         NOT NULL CHECK(LENGTH(val_tipo_sangre)>=2),
    val_edad        DECIMAL(2,0)    NOT NULL CHECK(val_edad >= 16),
-- DATOS LABORALES
    id_cargo        DECIMAL(2,0)    NOT NULL CHECK(id_cargo >= 1),
    val_sal_basico  DECIMAL(8)      NOT NULL CHECK(val_sal_basico >= 500000),
    fec_ingreso     DATE            NOT NULL CHECK(fec_ingreso <= CURRENT_DATE),
    PRIMARY KEY(id_emplea),
    FOREIGN KEY(id_cargo)   REFERENCES tab_cargos(id_cargo)
);

INSERT INTO tab_emplea VALUES(91423627,'Carlos Eduardo','Perez Rueda',FALSE,'Calle 20',3503421739,4,0,3,'A+',61,5,10000000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1032505813,'Laura Juliana','Perez Barrera',TRUE,'Calle 138 Carrera 54',3102454737,5,0,0,'A+',25,3,8000000,'2024-10-01');
INSERT INTO tab_emplea VALUES(1014182933,'Maria camila','Perez Barrera',TRUE,'San Agustin de Guadalix',3122241234,5,1,1,'O+',27,4,8500000,'2024-02-01');
INSERT INTO tab_emplea VALUES(1067062169,'Paula Sofia','Perez Moscoso',TRUE,'Arboretto Piedecuesta',3133216625,4,0,0,'O+',16,8,6500000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000000,'Carlos Chaparro','Perez Moscoso',FALSE,'Girón',3102222222,4,0,0,'O+',40,9,6000000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000001,'Esteban Francisco','Janiot Rivera',FALSE,'Avda. Q. Seca San Alonso',3103333333,4,0,1,'O+',26,9,6000000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000002,'Juan Pablo','Lopez Bobito',FALSE,'Piedecuesta',3104444444,4,0,1,'A+',18,12,5000000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000003,'Joan','Portilla',FALSE,'Piedecuesta Molino',3105555555,4,0,1,'A-',18,9,5500000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000004,'Juana','La Loca',TRUE,'Calle 28 Cra. 18',3106666666,3,0,3,'A-',25,16,2500000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000005,'Pedro','El Escamoso',FALSE,'Lebrija',3107777777,3,0,2,'A+',35,20,2000000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000006,'Juanito','Alimaña',FALSE,'Piedecuesta Barro Blanco',3108888888,2,0,4,'O-',40,20,2000000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000007,'Yoshitomo','Cacaito',FALSE,'Rionegro',3109999999,2,0,5,'A+',28,16,2500000,'2024-01-01');
INSERT INTO tab_emplea VALUES(1015000008,'Yessenya Vanessa','Sanabria de Janiot',TRUE,'San Miguel Casa 20',3111111111,3,0,1,'A-',25,13,4500000,'2024-01-01');

CREATE INDEX idx_nom_emplea      ON tab_emplea(nom_emplea);
CREATE INDEX idx_ape_emplea      ON tab_emplea(ape_emplea);
CREATE INDEX idx_ind_estrato     ON tab_emplea(ind_estrato);
CREATE INDEX idx_val_tipo_sangre ON tab_emplea(val_tipo_sangre);

CREATE TABLE IF NOT EXISTS tab_conceptos
(
    id_concepto     DECIMAL(2,0)    NOT NULL,
    nom_concepto    VARCHAR         NOT NULL  CHECK(LENGTH(nom_concepto)>=5),
    ind_operacion   BOOLEAN         NOT NULL, -- TRUE SUMA / FALSE RESTA
    ind_perio_pago  CHAR(1)         NOT NULL DEFAULT 'Q' CHECK(ind_perio_pago = 'Q' OR ind_perio_pago = 'M'), -- Q QUINCENA /M MENSUAL
    neto_pagado     BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE NETO PAGADO/ FALSE NO NETO PAGADO
    val_porcent     DECIMAL(3,0)    NOT NULL CHECK(val_porcent >= 0), -- Por si el concepto se aplica con un porcentaje. Si es 0 no aplica.
    val_fijo        DECIMAL(8,0)    NOT NULL CHECK(val_fijo >= 0), -- Por si el conbcepto debe llegar un valor fijo permanente. Puede cam,biarlo el usuario
    ind_legal       BOOLEAN         NOT NULL, --TRUE OBLIGATORIO / FALSE NO OBLIGATORIO
    PRIMARY KEY (id_concepto)
);

INSERT INTO tab_conceptos VALUES(1,'Salario Básico',TRUE,'Q',FALSE,0,0,TRUE);
INSERT INTO tab_conceptos VALUES(2,'Auxilio de Transporte',TRUE,'Q',FALSE,0,0,TRUE);
INSERT INTO tab_conceptos VALUES(3,'Entidad Prestadora de Salud (EPS)',FALSE,'M',FALSE,12,0,TRUE);
INSERT INTO tab_conceptos VALUES(4,'Administradora de Pensión (AFP)',FALSE,'M',FALSE,16,0,TRUE);
INSERT INTO tab_conceptos VALUES(5,'NETO PAGADO',FALSE,'Q',TRUE,0,0,TRUE);
INSERT INTO tab_conceptos VALUES(6,'Bonificación por chismoso',TRUE,'M',FALSE,0,100000,FALSE);
INSERT INTO tab_conceptos VALUES(7,'Horas Extras Diurnas',TRUE,'Q',FALSE,25,0,FALSE);
INSERT INTO tab_conceptos VALUES(8,'Horas Extras Nocturna',TRUE,'Q',FALSE,75,0,FALSE);
INSERT INTO tab_conceptos VALUES(9,'Horas Extras Festivas Diurnas',TRUE,'Q',FALSE,100,0,FALSE);
INSERT INTO tab_conceptos VALUES(10,'Horas Extras Fetivas Nocturnas',TRUE,'Q',FALSE,150,0,FALSE);
INSERT INTO tab_conceptos VALUES(11,'Descuento por Préstamo',FALSE,'M',FALSE,10,0,FALSE);

CREATE TABLE IF NOT EXISTS tab_meses
(
    id_mes          DECIMAL(2,0)    NOT NULL    CHECK(id_mes >= 1 AND id_mes <= 12),
    nom_mes         VARCHAR         NOT NULL CHECK(LENGTH(nom_mes) >= 4),
    PRIMARY KEY(id_mes)
);
INSERT INTO tab_meses VALUES(1,'Enero');
INSERT INTO tab_meses VALUES(2,'febrero');
INSERT INTO tab_meses VALUES(3,'Marzo');
INSERT INTO tab_meses VALUES(4,'Abril');
INSERT INTO tab_meses VALUES(5,'Mayo');
INSERT INTO tab_meses VALUES(6,'junio');
INSERT INTO tab_meses VALUES(7,'Julio');
INSERT INTO tab_meses VALUES(8,'Agosto');
INSERT INTO tab_meses VALUES(9,'Septiembre');
INSERT INTO tab_meses VALUES(10,'Octubre');
INSERT INTO tab_meses VALUES(11,'Noviembre');
INSERT INTO tab_meses VALUES(12,'Diciembre');

CREATE TABLE IF NOT EXISTS tab_nomina
(
    ano_nomina      DECIMAL(4,0)    NOT NULL,
    mes_nomina      DECIMAL(2,0)    NOT NULL,
    per_nomina      DECIMAL(1,0)    NOT NULL,
    id_emplea       DECIMAL(10,0)   NOT NULL,
    id_concepto     DECIMAL(2,0)    NOT NULL,
    val_dias_trab   DECIMAL(2,0)    NOT NULL CHECK(val_dias_trab >= 1 AND val_dias_trab <= 30),
    val_nomina      DECIMAL(8,0)    NOT NULL CHECK(val_nomina >= 0),
    PRIMARY KEY(ano_nomina,mes_nomina,per_nomina,id_emplea,id_concepto),
    FOREIGN KEY(id_emplea)      REFERENCES tab_emplea(id_emplea),
    FOREIGN KEY(id_concepto)    REFERENCES tab_conceptos(id_concepto),
    FOREIGN KEY(mes_nomina)     REFERENCES tab_meses(id_mes)
);

CREATE TABLE IF NOT EXISTS tab_novedades
(
    ano_nomina         DECIMAL(4,0)    NOT NULL,
    mes_nomina         DECIMAL(2,0)    NOT NULL,
    per_nomina         DECIMAL(1,0)    NOT NULL,
    id_emplea       DECIMAL(10,0)   NOT NULL,
    id_concepto     DECIMAL(2,0)    NOT NULL,
    val_dias_trab   DECIMAL(2,0)    NOT NULL CHECK(val_dias_trab >= 1 AND val_dias_trab <= 30),
    val_horas_trab  DECIMAL(2,0)    NOT NULL CHECK(val_horas_trab >= 0),
    PRIMARY KEY(ano_nomina,mes_nomina,per_nomina,id_emplea,id_concepto),
    FOREIGN KEY(id_emplea)      REFERENCES tab_emplea(id_emplea),
    FOREIGN KEY(id_concepto)    REFERENCES tab_conceptos(id_concepto)
);

-- NOVEDADES PARA ENERO QUINCENA 1
INSERT INTO tab_novedades VALUES(2025,1,1,91423627,6,15,0);
INSERT INTO tab_novedades VALUES(2025,1,1,1032505813,6,15,0);
INSERT INTO tab_novedades VALUES(2025,1,1,1067062169,6,15,0);
INSERT INTO tab_novedades VALUES(2025,1,1,1015000000,7,15,5);
INSERT INTO tab_novedades VALUES(2025,1,1,1015000001,9,15,10);
INSERT INTO tab_novedades VALUES(2025,1,1,1015000004,6,15,0);
INSERT INTO tab_novedades VALUES(2025,1,1,1015000004,10,15,10);

DROP TABLE IF EXISTS tab_users;
CREATE TABLE IF NOT EXISTS tab_users
(
    email       VARCHAR NOT NULL,
    password    VARCHAR NOT NULL,
    lastlogin   DATE    NOT NULL,
    PRIMARY KEY(email)
);

SELECT * FROM tab_novedades;
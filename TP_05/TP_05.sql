SET SEARCH_PATH = unc_251340;

-- GENERACION DE TABLAS ARTICULO, CONTIENE Y PALABRA
-- Table: P5P1E1_ARTICULO
CREATE TABLE P5P1E1_ARTICULO (
    id_articulo int  NOT NULL,
    titulo varchar(120)  NOT NULL,
    autor varchar(30)  NOT NULL,
    CONSTRAINT P5P1E1_ARTICULO_pk PRIMARY KEY (id_articulo)
);

-- Table: P5P1E1_CONTIENE
CREATE TABLE P5P1E1_CONTIENE (
    id_articulo int  NOT NULL,
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    CONSTRAINT P5P1E1_CONTIENE_pk PRIMARY KEY (id_articulo,idioma,cod_palabra)
);

-- Table: P5P1E1_PALABRA
CREATE TABLE P5P1E1_PALABRA (
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    descripcion varchar(25)  NOT NULL,
    CONSTRAINT P5P1E1_PALABRA_pk PRIMARY KEY (idioma,cod_palabra)
);

DROP TABLE IF EXISTS P5P1E1_CONTIENE, P5P1E1_PALABRA, P5P1E1_ARTICULO;

-- foreign keys
-- Reference: FK_P5P1E1_CONTIENE_ARTICULO (table: P5P1E1_CONTIENE)
ALTER TABLE P5P1E1_CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_ARTICULO
    FOREIGN KEY (id_articulo)
    REFERENCES P5P1E1_ARTICULO (id_articulo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P1E1_CONTIENE_PALABRA (table: P5P1E1_CONTIENE)
ALTER TABLE P5P1E1_CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P1E1_PALABRA (idioma, cod_palabra)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

INSERT INTO P5P1E1_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 1, 'magia');
INSERT INTO P5P1E1_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 2, 'varita');
INSERT INTO P5P1E1_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 3, 'escritura');
INSERT INTO P5P1E1_PALABRA (idioma, cod_palabra, descripcion) VALUES ('BR', 4, 'triangolo');
INSERT INTO P5P1E1_PALABRA (idioma, cod_palabra, descripcion) VALUES ('BR', 5, 'criansa');
INSERT INTO P5P1E1_PALABRA (idioma, cod_palabra, descripcion) VALUES ('BR', 6, 'facer');

INSERT INTO P5P1E1_ARTICULO (id_articulo, titulo, autor) VALUES (1, 'Harry Potter', 'J.K. Rowling');
INSERT INTO P5P1E1_ARTICULO (id_articulo, titulo, autor) VALUES (2, 'Um Dois Treis', 'Autor brazuca');

INSERT INTO P5P1E1_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (1, 'AR', 1);
INSERT INTO P5P1E1_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (1, 'AR', 2);
INSERT INTO P5P1E1_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (1, 'AR', 3);
INSERT INTO P5P1E1_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'BR', 4);
INSERT INTO P5P1E1_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'BR', 5);
INSERT INTO P5P1E1_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'BR', 6);

-- Ejercicio 1.A:
-- Cómo debería implementar las Restricciones de Integridad Referencial (RIR) si se desea que
-- cada vez que se elimine un registro de la tabla PALABRA , también se eliminen los artículos
-- que la referencian en la tabla CONTIENE.
ALTER TABLE P5P1E1_CONTIENE DROP CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA;
ALTER TABLE P5P1E1_CONTIENE DROP CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA_EJ1_A;
ALTER TABLE P5P1E1_CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA_EJ1_A
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P1E1_PALABRA (idioma, cod_palabra)
    MATCH FULL
    ON DELETE CASCADE;

SELECT * FROM P5P1E1_CONTIENE;
SELECT * FROM P5P1E1_PALABRA;

DELETE FROM P5P1E1_PALABRA WHERE cod_palabra = 1;

-- Ejercicio 1.B:
-- Verifique qué sucede con las palabras contenidas en cada artículo, al eliminar una palabra,
-- si definen la Acción Referencial para las bajas (ON DELETE) de la RIR correspondiente
-- como:
    -- ii) Restrict | Respuesta: El resultado da que NO SE PUEDE porque es 'RESTRICT'
    -- iii) Es posible para éste ejemplo colocar SET NULL o SET DEFAULT para ON
    -- DELETE y ON UPDATE?
    -- Respuesta: No se puede, ya que las columnas en la table "CONTIENE" son PK.
    --              Ademas de que las columnas id_articulo, idioma y cod_palabra de la tabla
    --              "Contiene" no permite valores null, en caso de al crear la tabla permitirle
    --              acceptar valores null, ahi seria otra cosa.

ALTER TABLE P5P1E1_CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA_EJ1_A
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P1E1_PALABRA (idioma, cod_palabra)
    MATCH FULL
    ON DELETE RESTRICT;


ALTER TABLE P5P1E1_CONTIENE DROP CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA_sin_match;
ALTER TABLE P5P1E1_CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA_sin_match
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P1E1_PALABRA (idioma, cod_palabra)
    ON DELETE SET NULL;



-- Ejercicio 2:

-- tables
-- Table: TP5_P1_EJ2_AUSPICIO
CREATE TABLE TP5_P1_EJ2_AUSPICIO (
    id_proyecto int  NOT NULL,
    nombre_auspiciante varchar(20)  NOT NULL,
    tipo_empleado char(2)  NULL,
    nro_empleado int  NULL,
    CONSTRAINT TP5_P1_EJ2_AUSPICIO_pk PRIMARY KEY (id_proyecto,nombre_auspiciante)
);

-- Table: TP5_P1_EJ2_EMPLEADO
CREATE TABLE TP5_P1_EJ2_EMPLEADO (
    tipo_empleado char(2)  NOT NULL,
    nro_empleado int  NOT NULL,
    nombre varchar(40)  NOT NULL,
    apellido varchar(40)  NOT NULL,
    cargo varchar(15)  NOT NULL,
    CONSTRAINT TP5_P1_EJ2_EMPLEADO_pk PRIMARY KEY (tipo_empleado,nro_empleado)
);

-- Table: TP5_P1_EJ2_PROYECTO
CREATE TABLE TP5_P1_EJ2_PROYECTO (
    id_proyecto int  NOT NULL,
    nombre_proyecto varchar(40)  NOT NULL,
    anio_inicio int  NOT NULL,
    anio_fin int  NULL,
    CONSTRAINT TP5_P1_EJ2_PROYECTO_pk PRIMARY KEY (id_proyecto)
);

-- Table: TP5_P1_EJ2_TRABAJA_EN
CREATE TABLE TP5_P1_EJ2_TRABAJA_EN (
    tipo_empleado char(2)  NOT NULL,
    nro_empleado int  NOT NULL,
    id_proyecto int  NOT NULL,
    cant_horas int  NOT NULL,
    tarea varchar(20)  NOT NULL,
    CONSTRAINT TP5_P1_EJ2_TRABAJA_EN_pk PRIMARY KEY (tipo_empleado,nro_empleado,id_proyecto)
);

-- foreign keys
-- Reference: FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO (table: TP5_P1_EJ2_AUSPICIO)
ALTER TABLE TP5_P1_EJ2_AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO
    FOREIGN KEY (tipo_empleado, nro_empleado)
    REFERENCES TP5_P1_EJ2_EMPLEADO (tipo_empleado, nro_empleado)
	MATCH FULL
    ON DELETE  SET NULL
    ON UPDATE  RESTRICT;

-- Reference: FK_TP5_P1_EJ2_AUSPICIO_PROYECTO (table: TP5_P1_EJ2_AUSPICIO)
ALTER TABLE TP5_P1_EJ2_AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_PROYECTO
    FOREIGN KEY (id_proyecto)
    REFERENCES TP5_P1_EJ2_PROYECTO (id_proyecto)
    ON DELETE  RESTRICT
    ON UPDATE  RESTRICT;

-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO (table: TP5_P1_EJ2_TRABAJA_EN)
ALTER TABLE TP5_P1_EJ2_TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO
    FOREIGN KEY (tipo_empleado, nro_empleado)
    REFERENCES TP5_P1_EJ2_EMPLEADO (tipo_empleado, nro_empleado)
    ON DELETE  CASCADE
    ON UPDATE  RESTRICT;

-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO (table: TP5_P1_EJ2_TRABAJA_EN)
ALTER TABLE TP5_P1_EJ2_TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO
    FOREIGN KEY (id_proyecto)
    REFERENCES TP5_P1_EJ2_PROYECTO (id_proyecto)
    ON DELETE  RESTRICT
    ON UPDATE  CASCADE;

-- EMPLEADO
INSERT INTO tp5_p1_ej2_empleado VALUES ('A ', 1, 'Juan', 'Garcia', 'Jefe');
INSERT INTO tp5_p1_ej2_empleado VALUES ('B', 1, 'Luis', 'Lopez', 'Adm');
INSERT INTO tp5_p1_ej2_empleado VALUES ('A ', 2, 'María', 'Casio', 'CIO');

-- PROYECTO
INSERT INTO tp5_p1_ej2_proyecto VALUES (1, 'Proy 1', 2019, NULL);
INSERT INTO tp5_p1_ej2_proyecto VALUES (2, 'Proy 2', 2018, 2019);
INSERT INTO tp5_p1_ej2_proyecto VALUES (3, 'Proy 3', 2020, NULL);

-- TRABAJA_EN
INSERT INTO tp5_p1_ej2_trabaja_en VALUES ('A ', 1, 1, 35, 'T1');
INSERT INTO tp5_p1_ej2_trabaja_en VALUES ('A ', 2, 2, 25, 'T3');

-- AUSPICIO
INSERT INTO tp5_p1_ej2_auspicio VALUES (2, 'McDonald', 'A ', 2);

DROP TABLE IF EXISTS TP5_P1_EJ2_AUSPICIO, TP5_P1_EJ2_TRABAJA_EN, TP5_P1_EJ2_PROYECTO, TP5_P1_EJ2_EMPLEADO;

SELECT * FROM TP5_P1_EJ2_AUSPICIO;
SELECT * FROM TP5_P1_EJ2_TRABAJA_EN;
SELECT * FROM tp5_p1_ej2_proyecto;
-- 2.A.1:
-- Permite ejecutarla ya que en las tablas TP5_P1_EJ2_AUSPICIO y TP5_P1_EJ2_TRABAJA_EN no
-- referencian nunca al proyecto con id 3.
DELETE FROM tp5_p1_ej2_proyecto WHERE id_proyecto = 3;

-- 2.A.2:
-- Permite ejecutarla ya que en las tablas TP5_P1_EJ2_AUSPICIO y TP5_P1_EJ2_TRABAJA_EN no
-- referencian nunca al proyecto con id 3.
UPDATE tp5_p1_ej2_proyecto SET id_proyecto = 7 WHERE id_proyecto = 3;

-- 2.A.3:
-- No permite eliminar el proyecto ya que en la tabla TRABAJA_EN hay una fila que hace referencia
-- a ese proyecto, y en la tabla hay una RIR on delete RESTRICT;
DELETE FROM tp5_p1_ej2_proyecto WHERE id_proyecto = 1;

-- 2.A.4:
-- Tanto en la tabla TRABAJA_EN como en AUSPICIO se hace referencia al empleado
SELECT * FROM TP5_P1_EJ2_TRABAJA_EN;
SELECT * FROM TP5_P1_EJ2_AUSPICIO;
-- En la tabla TRABAJA_EN hay una RIR ON DELETE CASCADE, por lo tanto se podria eliminar.
-- En la tabla AUSPICIO hay una RIR ON DELETE SET NULL, y la tabla AUSPICIO permite a esas
-- 2 columnas ser null. Por lo tanto SE PUEDE ELIMINAR.
DELETE FROM tp5_p1_ej2_empleado WHERE tipo_empleado = 'A' AND nro_empleado = 2;

-- 2.A.5:
-- Permite hacer el cambio, la restriccion en CASCADE y existe el proyecto 3 en la tabla PROYECTO
UPDATE TP5_P1_EJ2_TRABAJA_EN SET id_proyecto = 3 WHERE id_proyecto = 1;

-- 2.A.6:
-- No permite realizar la operacion debido a que en la tabla "AUSPICIO"
-- hay un registro con el id_proyecto = 2
UPDATE tp5_p1_ej2_auspicio SET id_proyecto = 5 WHERE id_proyecto = 2;
SELECT * FROM TP5_P1_EJ2_PROYECTO;
SELECT * FROM tp5_p1_ej2_auspicio;

-- 2.B.1:
-- update auspicio set id_proyecto= 66, nro_empleado = 10 where id_proyecto = 22
-- and tipo_empleado = 'A' and nro_empleado = 5;

UPDATE TP5_P1_EJ2_AUSPICIO SET id_proyecto= 66, nro_empleado = 10
WHERE id_proyecto = 22 AND tipo_empleado = 'A' AND nro_empleado = 5;


-- EJERCICIO 3:

CREATE TABLE CARRETERA(
    nro_carretera INT NOT NULL,
    descripcion VARCHAR(60) NOT NULL,
    categoria INT NOT NULL,
    CONSTRAINT TP5_P1_EJ3_PK_CARRETERA PRIMARY KEY(nro_carretera)
);

CREATE TABLE CIUDAD(
    cod_ciudad INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    cant_habitantes INT NOT NULL,
    CONSTRAINT TP5_P1_EJ3_PK_CIUDAD PRIMARY KEY(cod_ciudad)
);

CREATE TABLE RUTA(
    nro_carretera INT NOT NULL,
    cod_ciudad_desde INT NOT NULL,
    cod_ciudad_hasta INT NOT NULL,
    CONSTRAINT TP5_P1_EJ3_PK_RUTA PRIMARY KEY(nro_carretera, cod_ciudad_desde, cod_ciudad_hasta)
);

INSERT INTO CARRETERA(nro_carretera, descripcion, categoria) VALUES (1, 'Carretera 1', 1);
INSERT INTO CARRETERA(nro_carretera, descripcion, categoria) VALUES (2, 'Carretera 2', 2);
INSERT INTO CARRETERA(nro_carretera, descripcion, categoria) VALUES (3, 'Carretera 3', 1);
INSERT INTO CARRETERA(nro_carretera, descripcion, categoria) VALUES (4, 'Carretera 4', 3);
INSERT INTO CARRETERA(nro_carretera, descripcion, categoria) VALUES (5, 'Carretera 5', 2);

INSERT INTO CIUDAD(cod_ciudad, nombre, cant_habitantes) VALUES (100, 'Tandil', 200000);
INSERT INTO CIUDAD(cod_ciudad, nombre, cant_habitantes) VALUES (210, 'Necochea', 100000);
INSERT INTO CIUDAD(cod_ciudad, nombre, cant_habitantes) VALUES (350, 'La Plata', 400000);

INSERT INTO RUTA (nro_carretera, cod_ciudad_desde, cod_ciudad_hasta) VALUES (1, 100, 210);
INSERT INTO RUTA (nro_carretera, cod_ciudad_desde, cod_ciudad_hasta) VALUES (2, 100, 350);
INSERT INTO RUTA (nro_carretera, cod_ciudad_desde, cod_ciudad_hasta) VALUES (3, 210, 350);

-- 3: A: Se podrá declarar como acción referencial de la (RIR) FK_RUTA_CIUDAD_DESDE
-- DELETE CASCADE y para la RIR FK_Ruta_ciudad_hasta DELETE RESTRICT?
ALTER TABLE IF EXISTS RUTA DROP CONSTRAINT IF EXISTS TP5_P1_EJ3_FK_RUTA_CIUDAD_DESDE;
ALTER TABLE RUTA ADD CONSTRAINT TP5_P1_EJ3_FK_RUTA_CIUDAD_DESDE FOREIGN KEY(cod_ciudad_desde)
    REFERENCES CIUDAD(cod_ciudad)
    MATCH FULL
    ON DELETE CASCADE
    ON UPDATE RESTRICT;

ALTER TABLE IF EXISTS RUTA DROP CONSTRAINT IF EXISTS TP5_P1_EJ3_FK_RUTA_CIUDAD_HASTA;
ALTER TABLE RUTA ADD CONSTRAINT TP5_P1_EJ3_FK_RUTA_CIUDAD_HASTA FOREIGN KEY(cod_ciudad_hasta)
    REFERENCES CIUDAD(cod_ciudad)
    MATCH FULL
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;

SELECT * FROM RUTA;
SELECT * FROM CIUDAD;
SELECT * FROM CARRETERA;

DELETE FROM CIUDAD WHERE cod_ciudad = 100;

-- Es posible colocar DELETE SET NULL o UPDATE SET NULL como acción
-- referencial de la RIR FK_RUTA_CARRETERA ?
-- RESPUESTA: No se puede, debido a que nro_carretera ES UNA PK en CARRETERA.

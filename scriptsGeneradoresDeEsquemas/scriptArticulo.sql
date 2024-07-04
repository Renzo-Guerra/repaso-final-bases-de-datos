-- Creacion de la tabla ARTICULO
DROP TABLE IF EXISTS tp5_parte2_ARTICULO;
CREATE TABLE IF NOT EXISTS tp5_parte2_ARTICULO(
    id_articulo INT NOT NULL,
    titulo VARCHAR(120) NOT NULL,
    autor VARCHAR(30) NOT NULL,
    fecha_publicacion date NOT NULL,
    nacionalidad VARCHAR(15) NOT NULL,
    CONSTRAINT PK_tp5_parte2_ARTICULO PRIMARY KEY (id_articulo)
);

-- Creacion de la tabla PALABRA
DROP TABLE IF EXISTS tp5_parte2_PALABRA;
CREATE TABLE IF NOT EXISTS tp5_parte2_PALABRA(
    idioma CHAR(2) NOT NULL,
    cod_palabra INT NOT NULL,
    descripcion VARCHAR(25) NOT NULL,
    CONSTRAINT PK_tp5_parte2_PALABRA PRIMARY KEY (idioma, cod_palabra)
);

-- Creacion de la tabla CONTIENE
DROP TABLE IF EXISTS tp5_parte2_CONTIENE;
CREATE TABLE IF NOT EXISTS tp5_parte2_CONTIENE(
    id_articulo INT NOT NULL,
    idioma CHAR(2) NOT NULL,
    cod_palabra INT NOT NULL,
    CONSTRAINT PK_tp5_parte2_CONTIENE PRIMARY KEY (id_articulo, cod_palabra)
);

-- Agregando foreing keys
ALTER TABLE tp5_parte2_CONTIENE DROP CONSTRAINT IF EXISTS FK_CONTIENE_ARTICULO;
ALTER TABLE tp5_parte2_CONTIENE DROP CONSTRAINT IF EXISTS FK_CONTIENE_PALABRA;

ALTER TABLE tp5_parte2_CONTIENE ADD CONSTRAINT FK_CONTIENE_ARTICULO FOREIGN KEY (id_articulo) REFERENCES tp5_parte2_ARTICULO (id_articulo);
ALTER TABLE tp5_parte2_CONTIENE ADD CONSTRAINT FK_CONTIENE_PALABRA FOREIGN KEY (idioma, cod_palabra) REFERENCES tp5_parte2_PALABRA (idioma, cod_palabra);

INSERT INTO tp5_parte2_ARTICULO (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES (1, 'El despertar de la conciencia', 'autor1', '1997-4-23', 'Argentina');
INSERT INTO tp5_parte2_ARTICULO (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES (2, 'Que hacer y que no hacer', 'autor2', '2004-2-12', 'Bolivia');
INSERT INTO tp5_parte2_ARTICULO (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES (3, 'Las tragedias que abundamos', 'autor3', '1947-2-2', 'Brasil');

INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 1, 'caminar');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 2, 'bailar');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 3, 'lapiz');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 4, 'gomera');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 5, 'lapicera');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 6, 'cerrucho');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('AR', 7, 'taladrar');

INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('BR', 1, 'mambo');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('BR', 2, 'chrispear');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('BR', 3, 'isla');
INSERT INTO tp5_parte2_PALABRA (idioma, cod_palabra, descripcion) VALUES ('BR', 4, 'filo');
-- id_articulo INT NOT NULL, idioma CHAR(2) NOT NULL, cod_palabra INT NOT NULL,
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (1, 'AR', 2);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (1, 'AR', 4);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (1, 'AR', 6);

INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'AR', 1);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'AR', 2);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'AR', 4);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'AR', 5);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (2, 'AR', 6);

INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (3, 'BR', 1);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (3, 'BR', 3);
INSERT INTO tp5_parte2_CONTIENE (id_articulo, idioma, cod_palabra) VALUES (3, 'BR', 2);

SELECT *
FROM tp5_parte2_ARTICULO;

SELECT *
FROM tp5_parte2_PALABRA;

SELECT  idioma,
        cod_palabra,
        count(*) as veces_que_aparece
FROM tp5_parte2_CONTIENE
group by idioma, cod_palabra;

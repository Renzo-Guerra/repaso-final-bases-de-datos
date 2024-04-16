SET SEARCH_PATH = unc_251340;

-- Ejercicio 1: Restricciones que debe definir sobre el esquema de la BD de Voluntarios
-- A: No puede haber voluntarios de más de 70 años.
SELECT *
FROM esq_vol_voluntario v
WHERE EXTRACT('YEAR' FROM AGE(NOW(), v.fecha_nacimiento)) > 70;

ALTER TABLE IF EXISTS esq_vol_voluntario DROP CONSTRAINT IF EXISTS  TP_05_PARTE_2_EJ1_A;
ALTER TABLE esq_vol_voluntario ADD CONSTRAINT TP_05_PARTE_2_EJ1_A CHECK(EXTRACT('YEAR' FROM AGE(NOW(), fecha_nacimiento)) <= 70);

-- B. Ningún voluntario puede aportar más horas que las de su coordinador.
-- El siguiente QUERY devuelve que hay 2 empleados que tienen mas horas_aportadas
-- que sus coordinadores.

SELECT 1
FROM esq_vol_voluntario v
WHERE v.horas_aportadas > (
            SELECT c.horas_aportadas
            FROM esq_vol_voluntario c
            WHERE c.nro_voluntario = v.id_coordinador
          );
-- En el select se ve que en ambos casos cada empleado tiene 500 hs mas que su coordinador.
SELECT *
FROM esq_vol_voluntario v
WHERE v.nro_voluntario = 148 OR v.nro_voluntario = 149;
-- El check deberia quedar como:
CREATE ASSERTION TP_05_PARTE_2_EJ1_B CHECK(
            NOT EXISTS(
                SELECT 1
                FROM esq_vol_voluntario v
                WHERE v.horas_aportadas > (
                    SELECT c.horas_aportadas
                    FROM esq_vol_voluntario c
                    WHERE c.nro_voluntario = v.id_coordinador
                  )
            )
        );

-- C. Las horas aportadas por los voluntarios deben estar dentro de los
-- valores máximos y mínimos consignados en la tarea.
SELECT *
FROM esq_vol_voluntario v
WHERE v.horas_aportadas BETWEEN (
        SELECT t.min_horas
        FROM esq_vol_tarea t
        WHERE t.id_tarea = v.id_tarea
    ) AND (
        SELECT t.max_horas
        FROM esq_vol_tarea t
        WHERE t.id_tarea = v.id_tarea
    );

CHECK(NOT EXISTS (SELECT *
FROM esq_vol_voluntario v
JOIN (
    SELECT t.id_tarea, t.min_horas, t.max_horas
    FROM esq_vol_tarea t
) t ON v.id_tarea = t.id_tarea
WHERE v.horas_aportadas NOT BETWEEN t.min_horas AND t.max_horas));

-- D. Todos los voluntarios deben realizar la misma tarea que su coordinador.
CHECK(NOT EXISTS(SELECT v.nro_voluntario, v.id_tarea, v.id_coordinador, coordinador.id_tarea_coordinador
FROM esq_vol_voluntario v
JOIN (
    SELECT c.nro_voluntario, c.id_tarea AS id_tarea_coordinador
    FROM esq_vol_voluntario c
) coordinador ON coordinador.nro_voluntario = v.id_coordinador
WHERE v.id_tarea <> coordinador.id_tarea_coordinador));

-- E. Los voluntarios no pueden cambiar de institución más de tres veces al año.
-- NO LO PUDE HACEEEER, no se me ocurre como verificar que la fecha sea la
-- del mismo año desde el HAVING...
SELECT historico.nro_voluntario, COUNT(DISTINCT historico.id_institucion) cantidad_instituciones_diferentes_en_1_mismo_año
FROM esq_vol_historico historico
GROUP BY historico.nro_voluntario
HAVING COUNT(DISTINCT historico.id_institucion) > 3 AND COUNT(historico.fecha_fin) > 1
ORDER BY historico.nro_voluntario;

SELECT *
FROM esq_vol_historico historico
ORDER BY historico.nro_voluntario;

-- F. En el histórico, la fecha de inicio debe ser siempre menor que la fecha de finalización.
ALTER TABLE esq_vol_historico ADD CONSTRAINT TP_05_PARTE2_EJ1_F
    CHECK (esq_vol_historico.fecha_inicio < esq_vol_historico.fecha_fin);

-- Ejercicio 2:
-- Considere las siguientes restricciones a definir sobre de Películas:

-- A. Para cada tarea el sueldo máximo debe ser mayor que el sueldo mínimo.
SELECT *
FROM esq_pel_tarea t
WHERE t.sueldo_maximo <= t.sueldo_minimo;

ALTER TABLE IF EXISTS esq_pel_tarea DROP CONSTRAINT IF EXISTS CH_TP_05_PARTE2_EJ2_A;
ALTER TABLE esq_pel_tarea ADD CONSTRAINT CH_TP_05_PARTE2_EJ2_A
    CHECK(sueldo_maximo > sueldo_minimo);

-- B: No puede haber más de 70 empleados en cada departamento.
SELECT e.id_departamento, e.id_distribuidor, COUNT(*) CANT_EMPLEADOS_EN_DEPARTAMENTO
FROM esq_pel_empleado e
GROUP BY e.id_departamento, e.id_distribuidor
ORDER BY COUNT(*) DESC;

-- Constraint de tabla
ALTER TABLE esq_pel_empleado ADD CONSTRAINT CH_TP_05_PARTE2_EJ2_B
 CHECK(NOT EXISTS(
    SELECT 1
    FROM esq_pel_empleado e
    GROUP BY e.id_departamento, e.id_distribuidor
    HAVING COUNT(*) > 70
 ));

-- Restriccion de tabla (A pesar de realizar un join o una subconsulta, si la otra/s tabla/s que se utiliza/n
-- es/son la/s misma/s, cuenta como de tabla!!!)
-- C. Los empleados deben tener jefes que pertenezcan al mismo departamento.
SELECT emp.id_empleado, emp.nombre, emp.apellido, emp.id_jefe, emp.id_departamento, emp.id_distribuidor, jefe.id_departamento, jefe.id_distribuidor
FROM esq_pel_empleado emp
JOIN esq_pel_empleado jefe ON emp.id_jefe = jefe.id_empleado
WHERE emp.id_departamento <> jefe.id_departamento OR emp.id_distribuidor <> jefe.id_distribuidor

-- D. Todas las entregas, tienen que ser de películas de un mismo idioma.
CREATE ASSERTION ASSERTION_TP_05_PARTE2_EJ2_D
    CHECK(NOT EXISTS(
        SELECT entregas.nro_entrega, COUNT(entregas.nro_entrega) cant_idiomas
        FROM (
        SELECT ren_en.nro_entrega
        FROM esq_pel_renglon_entrega ren_en
        JOIN (
            SELECT p.codigo_pelicula, p.idioma
            FROM esq_pel_pelicula p
        ) pelicula ON pelicula.codigo_pelicula = ren_en.codigo_pelicula
    ) entregas
    GROUP BY entregas.nro_entrega
    HAVING COUNT(entregas.nro_entrega) > 1
    ORDER BY entregas.nro_entrega));

-- Solo esta entrega cumple la regla...
SELECT *
FROM esq_pel_renglon_entrega r_e
JOIN esq_pel_pelicula p ON p.codigo_pelicula = r_e.codigo_pelicula
WHERE r_e.nro_entrega = 4142
ORDER BY nro_entrega;

-- E. No pueden haber más de 10 empresas productoras por ciudad.
SELECT id_ciudad, COUNT(*) cant_empresas_en_la_ciudad
FROM esq_pel_empresa_productora emp_prod
WHERE id_ciudad IS NOT NULL
GROUP BY emp_prod.id_ciudad
HAVING COUNT(*) > 10;

ALTER TABLE esq_pel_empresa_productora ADD CONSTRAINT CH_TP_05_PARTE2_EJ2_E
    CHECK (NOT EXISTS(
        SELECT 1
        FROM esq_pel_empresa_productora emp_prod
        WHERE id_ciudad IS NOT NULL
        GROUP BY emp_prod.id_ciudad
        HAVING COUNT(*) > 10
    ));

-- F: Para cada película, si el formato es 8mm, el idioma tiene que ser francés.
SELECT *
FROM esq_pel_pelicula p
WHERE p.formato ILIKE '% 8' AND p.idioma ILIKE 'fran%';

-- No permite agregarla porque hay 6 columnas que rompen la regla que tratamos de imponer!
ALTER TABLE esq_pel_pelicula ADD CONSTRAINT CH_TP_05_PARTE2_EJ2_F
    CHECK ((formato ILIKE '% 8' AND idioma = 'Francés') OR formato NOT ILIKE '% 8');


-- G: El teléfono de los distribuidores Nacionales debe tener la misma característica que la de su
-- distribuidor mayorista.

SELECT 1
FROM esq_pel_distribuidor dist
JOIN esq_pel_nacional nac ON dist.id_distribuidor = nac.id_distribuidor
WHERE EXISTS(
    SELECT 1
    FROM esq_pel_internacional inter
    WHERE inter.id_distribuidor = nac.id_distrib_mayorista
    AND SUBSTRING(dist.telefono, 1, 3) NOT LIKE (
            SELECT SUBSTRING(dis.telefono, 1, 3)
            FROM esq_pel_distribuidor dis
            WHERE dis.id_distribuidor = inter.id_distribuidor
        )
);

SELECT DISTINCT SUBSTRING(emp.telefono, 1, 3)
FROM esq_pel_empleado emp
ORDER BY SUBSTRING(emp.telefono, 1, 3);

-- Ejercicio 3:
-- Creacion de tablas:

-- Table: P5P2E3_ARTICULO
CREATE TABLE P5P2E3_ARTICULO (
    id_articulo int  NOT NULL,
    titulo varchar(120)  NOT NULL,
    autor varchar(30)  NOT NULL,
    fecha_publicacion DATE NOT NULL,
    nacionalidad VARCHAR(15) NOT NULL,
    CONSTRAINT P5P2E3_ARTICULO_pk PRIMARY KEY (id_articulo));

-- Table: P5P2E3_CONTIENE
CREATE TABLE P5P2E3_CONTIENE (
    id_articulo int  NOT NULL,
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    CONSTRAINT P5P2E3_CONTIENE_pk PRIMARY KEY (id_articulo,idioma,cod_palabra));

-- Table: P5P2E3_PALABRA
CREATE TABLE P5P2E3_PALABRA (
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    descripcion varchar(25)  NOT NULL,
    CONSTRAINT P5P2E3_PALABRA_pk PRIMARY KEY (idioma,cod_palabra));

-- foreign keys
-- Reference: FK_P5P2E3_CONTIENE_ARTICULO (table: P5P2E3_CONTIENE)
ALTER TABLE P5P2E3_CONTIENE ADD CONSTRAINT FK_P5P2E3_CONTIENE_ARTICULO
    FOREIGN KEY (id_articulo)
    REFERENCES P5P2E3_ARTICULO (id_articulo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE;

-- Reference: FK_P5P2E3_CONTIENE_PALABRA (table: P5P2E3_CONTIENE)
ALTER TABLE P5P2E3_CONTIENE ADD CONSTRAINT FK_P5P2E3_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P2E3_PALABRA (idioma, cod_palabra)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE;

DROP TABLE IF EXISTS P5P2E3_CONTIENE, P5P2E3_PALABRA, P5P2E3_ARTICULO;

INSERT INTO p5p2e3_palabra (idioma, cod_palabra, descripcion) VALUES ('ES', 1, 'palabra');
INSERT INTO p5p2e3_palabra (idioma, cod_palabra, descripcion) VALUES ('ES', 2, 'comida');
INSERT INTO p5p2e3_palabra (idioma, cod_palabra, descripcion) VALUES ('ES', 3, 'merienda');
INSERT INTO p5p2e3_palabra (idioma, cod_palabra, descripcion) VALUES ('ES', 4, 'desayuno');
INSERT INTO p5p2e3_palabra (idioma, cod_palabra, descripcion) VALUES ('ES', 5, 'cena');
INSERT INTO p5p2e3_palabra (idioma, cod_palabra, descripcion) VALUES ('ES', 6, 'arroz');

INSERT INTO p5p2e3_articulo
    (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES
    (1, 'El español', 'yo', '10-3-2019', 'Español');
INSERT INTO p5p2e3_articulo
    (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES
    (2, 'El español 2', 'yo', '10-3-2017', 'Español');
INSERT INTO p5p2e3_articulo
    (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES
    (3, 'El español 3', 'yo', '10-3-2019', 'Español');
INSERT INTO p5p2e3_articulo
    (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES
    (4, 'El español 4', 'yo', '10-3-2019', 'Español');
INSERT INTO p5p2e3_articulo
    (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES
    (5, 'El español 5', 'yo', '10-3-2019', 'Español');
INSERT INTO p5p2e3_articulo
    (id_articulo, titulo, autor, fecha_publicacion, nacionalidad) VALUES
    (6, 'El español 6', 'yo', '10-3-2019', 'Español');


select * from p5p2e3_contiene;
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (1, 'ES', 1);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (1, 'ES', 2);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (1, 'ES', 3);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (1, 'ES', 4);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (1, 'ES', 5);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (1, 'ES', 6);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (2, 'ES', 6);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (3, 'ES', 6);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (4, 'ES', 6);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (5, 'ES', 6);
INSERT INTO p5p2e3_contiene (id_articulo, idioma, cod_palabra) VALUES (6, 'ES', 6);
SELECT * FROM p5p2e3_contiene ORDER BY cod_palabra, id_articulo;
DELETE FROM p5p2e3_contiene WHERE idioma = 'ES' AND id_articulo = 1 AND cod_palabra = 6;

-- A: Controlar que las nacionalidades sean:
-- "Argentina", "Español", "Inglés, "Alemán" o "Chilena".
-- Restriccion de integridad de tipo "atributo"
ALTER TABLE P5P2E3_ARTICULO ADD CONSTRAINT CH_TP_05_PARTE2_EJ3_A
    CHECK(nacionalidad IN ('Español', 'Inglés', 'Alemán', 'Chilena'));

-- B: Para las fechas de publicaciones se debe considerar que sean
-- fechas posteriores o iguales al 2010.

ALTER TABLE P5P2E3_ARTICULO ADD CONSTRAINT CH_TP_05_PARTE2_EJ3_B
    CHECK(EXTRACT('YEAR' FROM fecha_publicacion) >= 2010);

-- C: Cada palabra clave puede aparecer como máximo en 5 artículos.
SELECT c.idioma, c.cod_palabra, count(*) articulos_donde_es_utilizada
FROM p5p2e3_contiene c
GROUP BY c.idioma, c.cod_palabra;

-- CHECKEO DE FILA (TUPLA)
ALTER TABLE P5P2E3_CONTIENE ADD CONSTRAINT CH_TP_05_PARTE2_EJ3_C
    CHECK(NOT EXISTS(
        SELECT count(*)
        FROM p5p2e3_contiene c
        GROUP BY c.idioma, c.cod_palabra
    ));

-- D: Sólo los autores argentinos pueden publicar artículos que contengan
-- más de 10 palabras claves, pero con un tope de 15 palabras,
-- el resto de los autores sólo pueden publicar artículos que contengan
-- hasta 10 palabras claves.

CREATE ASSERTION ASSERTION_TP_05_PARTE2_EJ3_D
    CHECK(NOT EXISTS(
        (
            SELECT a.id_articulo, a.nacionalidad, count(*) palabras_utilizadas
            FROM p5p2e3_contiene c
            JOIN P5P2E3_ARTICULO a on c.id_articulo = a.id_articulo
            WHERE a.nacionalidad = 'Argentina'
            GROUP BY a.id_articulo, a.nacionalidad
            HAVING count(*) > 15
        ) UNION (
            SELECT a.id_articulo, a.nacionalidad, count(*) palabras_utilizadas
            FROM p5p2e3_contiene c
            JOIN P5P2E3_ARTICULO a on c.id_articulo = a.id_articulo
            WHERE a.nacionalidad <> 'Argentina'
            GROUP BY a.id_articulo, a.nacionalidad
            HAVING count(*) > 10
        )
    ));

-- Solucion propuesta por los profes:
CREATE ASSERTION CK_CANTIDAD_PALABRAS
   CHECK (NOT EXISTS (
            SELECT 1
            FROM p5p2e3_articulo
            WHERE (
                nacionalidad LIKE 'Argentina' AND
                                id_articulo IN (
                                    SELECT id_articulo
                                    FROM p5p2e3_contiene
                                    GROUP BY id_articulo
                                    HAVING COUNT(*) > 15
                                ))
                    OR
                  (
                    nacionalidad NOT LIKE 'Argentina' AND
                    id_articulo IN (
                                SELECT id_articulo
                                FROM p5p2e3_contiene
                                GROUP BY id_articulo
                                HAVING COUNT(*) > 10
                            )
                    )
    ));


-- Ejercicio 4
-- CREACION DE TABLAS:
CREATE TABLE P5P2E4_PACIENTE(
    id_paciente INT NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    domicilio VARCHAR(120) NOT NULL,
    fecha_nacimmiento DATE NOT NULL,
    CONSTRAINT PK_P5P2E4_PACIENTE PRIMARY KEY(id_paciente)
);

CREATE TABLE P5P2E4_ALGORITMO(
    id_algoritmo INT NOT NULL,
    nombre_metadata VARCHAR(40) NOT NULL,
    descripcion VARCHAR(256) NOT NULL,
    costo_computacional VARCHAR(15) NOT NULL,
    CONSTRAINT PK_P5P2E4_ALGORITMO PRIMARY KEY (id_algoritmo)
);

CREATE TABLE P5P2E4_IMAGEN_MEDICA(
    id_paciente INT NOT NULL,
    id_imagen INT NOT NULL,
    modalidad VARCHAR(80) NOT NULL,
    descripcion VARCHAR(180) NOT NULL,
    descripcion_breve VARCHAR(80),
    CONSTRAINT PK_P5P2E4_IMAGEN_MEDICA PRIMARY KEY (id_paciente, id_imagen)
);

CREATE TABLE P5P2E4_PROCESAMIENTO(
    id_algoritmo INT NOT NULL,
    id_paciente INT NOT NULL,
    id_imagen INT NOT NULL,
    nro_secuencia INT NOT NULL,
    parametro DECIMAL(15, 3) NOT NULL,
    CONSTRAINT PK_P5P2E4_PROCESAMIENTO PRIMARY KEY (id_algoritmo, id_paciente, id_imagen, nro_secuencia)
);

ALTER TABLE P5P2E4_IMAGEN_MEDICA ADD CONSTRAINT FK_P5P2E4_IMAGEN_MEDICA_P5P2E4_PACIENTE
    FOREIGN KEY (id_paciente) REFERENCES P5P2E4_PACIENTE(id_paciente);

ALTER TABLE P5P2E4_PROCESAMIENTO ADD CONSTRAINT P5P2E4_PROCESAMIENTO_P5P2E4_ALGORITMO
    FOREIGN KEY (id_algoritmo) REFERENCES P5P2E4_ALGORITMO(id_algoritmo);

ALTER TABLE P5P2E4_PROCESAMIENTO ADD CONSTRAINT P5P2E4_PROCESAMIENTO_P5P2E4_IMAGEN_MEDICA
    FOREIGN KEY (id_paciente, id_imagen) REFERENCES P5P2E4_IMAGEN_MEDICA(id_paciente, id_imagen);

INSERT INTO P5P2E4_PACIENTE (id_paciente, apellido, nombre, domicilio, fecha_nacimmiento)
    VALUES (1, 'Migueles', 'Luciano', '123', '1990-04-12');
INSERT INTO P5P2E4_PACIENTE (id_paciente, apellido, nombre, domicilio, fecha_nacimmiento)
    VALUES (2, 'Torres', 'Alfonzo', '333', '1992-10-04');

INSERT INTO P5P2E4_IMAGEN_MEDICA (id_paciente, id_imagen, modalidad, descripcion, descripcion_breve, fecha)
    VALUES (1, 1, 'FLUOROSCOPIA', 'desc FLUOROSCOPIA', NULL, '2010-03-01');
INSERT INTO P5P2E4_IMAGEN_MEDICA (id_paciente, id_imagen, modalidad, descripcion, descripcion_breve, fecha)
    VALUES (1, 2, 'FLUOROSCOPIA', 'desc FLUOROSCOPIA', NULL, '2010-06-02');
INSERT INTO P5P2E4_IMAGEN_MEDICA (id_paciente, id_imagen, modalidad, descripcion, descripcion_breve, fecha)
    VALUES (1, 3, 'FLUOROSCOPIA', 'desc FLUOROSCOPIA', NULL, '2010-08-04');
INSERT INTO P5P2E4_IMAGEN_MEDICA (id_paciente, id_imagen, modalidad, descripcion, descripcion_breve, fecha)
    VALUES (2, 1, 'FLUOROSCOPIA', 'desc FLUOROSCOPIA', NULL, '2013-02-02');
INSERT INTO P5P2E4_IMAGEN_MEDICA (id_paciente, id_imagen, modalidad, descripcion, descripcion_breve, fecha)
    VALUES (2, 2, 'FLUOROSCOPIA', 'desc FLUOROSCOPIA', NULL, '2015-03-06');


-- A: La modalidad de la imagen médica puede tomar los siguientes valores RADIOLOGIA
-- CONVENCIONAL, FLUOROSCOPIA, ESTUDIOS RADIOGRAFICOS CON
-- FLUOROSCOPIA, MAMOGRAFIA, SONOGRAFIA.

ALTER TABLE P5P2E4_IMAGEN_MEDICA ADD CONSTRAINT CH_TP_05_PARTE2_EJ4_A
    CHECK (modalidad IN('RADIOLIGIA CONVENCIONAL', 'FLUOROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON FLUOROSCOPIA', 'MAMOGRAFIA', 'SONOGRAFIA'));

-- B: Cada imagen no debe tener más de 5 procesamientos.
ALTER TABLE P5P2E4_PROCESAMIENTO ADD CONSTRAINT CH_TP_05_PARTE2_EJ4_B
    CHECK(NOT EXISTS(
        SELECT 1
        FROM P5P2E4_PROCESAMIENTO p
        GROUP BY id_paciente, id_imagen
        HAVING COUNT(*) <= 5
    ));

-- C: Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una
-- indica la fecha de la imagen y la otra la fecha

ALTER TABLE P5P2E4_IMAGEN_MEDICA ADD COLUMN fecha DATE;
ALTER TABLE P5P2E4_IMAGEN_MEDICA ALTER COLUMN fecha SET NOT NULL;

ALTER TABLE P5P2E4_PROCESAMIENTO ADD COLUMN fecha DATE;
ALTER TABLE P5P2E4_PROCESAMIENTO ALTER COLUMN fecha SET NOT NULL;

CREATE ASSERTION ASSERTION_TP_05_PARTE2_EJ4_C
    CHECK(NOT EXISTS(
        SELECT 1
        FROM P5P2E4_PROCESAMIENTO p
        JOIN P5P2E4_IMAGEN_MEDICA img_m ON p.id_paciente = img_m.id_paciente AND p.id_imagen = img_m.id_imagen
        WHERE p.fecha < img_m.fecha
    ));


-- D: Cada paciente sólo puede realizarse dos FLUOROSCOPIAs anuales.
ALTER TABLE P5P2E4_IMAGEN_MEDICA ADD CONSTRAINT CH_TP_05_PARTE2_EJ4_D
CHECK(NOT EXISTS(
    SELECT id_paciente, extract('YEAR' FROM img_m.fecha) anio, count(*) cantidad_fluoroscopias_realizadas
    FROM P5P2E4_IMAGEN_MEDICA img_m
    WHERE img_m.modalidad = 'FLUOROSCOPIA'
    GROUP BY img_m.id_paciente, extract('YEAR' FROM img_m.fecha)
    HAVING count(*) > 2
));

-- E: No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA
CREATE ASSERTION ASSERTION_TP_05_PARTE2_EJ4_E
CHECK(NOT EXISTS(SELECT 1
FROM (
    SELECT id_algoritmo, id_paciente, id_imagen, nro_secuencia
    FROM P5P2E4_PROCESAMIENTO p
) procesamiento
JOIN (
    SELECT img.id_paciente, img.id_imagen
    FROM P5P2E4_IMAGEN_MEDICA img
    WHERE img.modalidad = 'FLUOROSCOPIA'
) imagen_medica ON procesamiento.id_paciente = imagen_medica.id_paciente AND procesamiento.id_imagen = imagen_medica.id_imagen
JOIN (
    SELECT alg.id_algoritmo
    FROM p5p2e4_algoritmo alg
    WHERE alg.costo_computacional = 'O(n)'
) algoritmo ON procesamiento.id_algoritmo = algoritmo.id_algoritmo));

-- Ejercicio 5:
-- Creacion de tablas:

CREATE TABLE P5P1E5_PRENDA(
  id_prenda INT NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  descripcion VARCHAR(129) NOT NULL,
  tipo VARCHAR(40) NOT NULL,
  categoria VARCHAR(80) NOT NULL,
  CONSTRAINT PK_P5P1E5_PRENDA PRIMARY KEY(id_prenda)
);

CREATE TABLE P5P1E5_CLIENTE(
    id_cliente INT NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    estado VARCHAR(5) NOT NULL,
    CONSTRAINT PK_P5P1E5_CLIENTE PRIMARY KEY(id_cliente)
);

CREATE TABLE P5P1E5_FECHA_LIQ(
    dia_liq INT NOT NULL,
    mes_liq INT NOT NULL,
    cant_dias INT NOT NULL,
    CONSTRAINT PK_P5P1E5_FECHA_LIQ PRIMARY KEY(dia_liq, mes_liq)
);

CREATE TABLE P5P1E5_VENTA(
    id_venta INT NOT NULL,
    descuento DECIMAL(10,2) NOT NULL,
    fecha TIMESTAMP NOT NULL,
    id_prenda INT NOT NULL,
    id_cliente INT NOT NULL,
    CONSTRAINT PK_P5P1E5_VENTA PRIMARY KEY(id_venta),
    CONSTRAINT FK_P5P1E5_VENTA_FK_P5P1E5_PRENDA FOREIGN KEY(id_prenda) REFERENCES P5P1E5_PRENDA(id_prenda),
    CONSTRAINT FK_P5P1E5_VENTA_FK_P5P1E5_CLIENTE FOREIGN KEY(id_cliente) REFERENCES P5P1E5_CLIENTE(id_cliente)
);

-- A: Los descuentos en las ventas son porcentajes y deben estar entre 0 y 100.
ALTER TABLE P5P1E5_VENTA ADD CONSTRAINT CH_TP_05_PARTE2_EJ5_A
    CHECK(descuento BETWEEN 0.0 AND 100.0);

-- B: Los descuentos realizados en fechas de liquidación deben superar el 30%.
CREATE ASSERTION ASSERTION_TP_05_PARTE2_EJ5_B
CHECK(NOT EXISTS(
    SELECT *
    FROM P5P1E5_FECHA_LIQ f_l
    JOIN P5P1E5_VENTA V ON EXTRACT('MONTH' FROM v.fecha) = f_l.mes_liq AND EXTRACT('DAY' FROM v.fecha) = f_l.dia_liq
    WHERE descuento > 30.0
));

-- C: Las liquidaciones de Julio y Diciembre no deben superar los 5 días.
ALTER TABLE P5P1E5_FECHA_LIQ ADD CONSTRAINT CH_TP_05_PARTE2_EJ5_C
CHECK(mes_liq <> 7 OR mes_liq <> 12 OR cant_dias < 5);

SELECT *
FROM P5P1E5_FECHA_LIQ f_l
WHERE f_l.cant_dias > 5 AND(f_l.mes_liq = 7 OR f_l.mes_liq = 12)

-- D: Las prendas de categoría ‘oferta’ no tienen descuentos.
CREATE ASSERTION ASSERTION_TP_05_PARTE2_EJ5_D
CHECK(NOT EXISTS(SELECT prenda.id_prenda id_prenda, id_venta id_venta, descuento descuento
FROM (
    SELECT p.id_prenda
    FROM P5P1E5_PRENDA p
    WHERE categoria = 'oferta'
) prenda
JOIN (
    SELECT v.id_venta, v.id_prenda, v.descuento
    FROM P5P1E5_VENTA v
) venta ON prenda.id_prenda = venta.id_prenda
WHERE descuento > 0.0));
SET SEARCH_PATH = unc251340;

-- Escriba las sentencias de creación de cada una de las vistas solicitadas en cada caso.
-- Indique si para el estandar SQL y/o Postgresql dicha vista es actualizable o no, si es de
-- Proyección-Selección (una tabla) o Proyección-Selección-Ensamble (más de una tabla).
-- Justifique cada respuesta.

-- 1: Cree una vista "EMPLEADO_DIST" que liste el nombre, apellido, sueldo, y
-- fecha_nacimiento de los empleados que pertenecen al distribuidor
-- cuyo identificador es 20.

-- Vista de Proyección-Selección.
-- No es actualizable, ni en el estandar ni en posrgreSQL, ya que no es key-preserved
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_1_EMPLEADO_DIST AS
    SELECT emp.nombre, emp.apellido, emp.sueldo, emp.fecha_nacimiento
    FROM unc_esq_peliculas.empleado emp
    WHERE emp.id_distribuidor = 20;

-- 2: Sobre la vista anterior defina otra vista "EMPLEADO_DIST_2000"
-- con el nombre, apellido y sueldo de los empleados que cobran más de 2000.

-- Vista de Proyección-Selección.
-- No es actualizable ni en el estandar sql ni en postgresql.
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_2_EMPLEADO_DIST_2000 AS
    SELECT emp.nombre, emp.apellido, emp.sueldo
    FROM V_TP_07_EJERCICIO_2_1_EMPLEADO_DIST emp
    WHERE emp.sueldo > 2000;

-- 3: Sobre la vista "EMPLEADO_DIST" cree la vista "EMPLEADO_DIST_20_70" con aquellos
-- empleados que han nacido en la década del 70 (entre los años 1970 y 1979).

-- Vista de Proyección-Selección.
-- No es actualizable ni en el estandar sql ni en postgresql.
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_3_EMPLEADO_DIST_20_70 AS
    SELECT *
    FROM V_TP_07_EJERCICIO_2_1_EMPLEADO_DIST emp
    WHERE EXTRACT('YEAR' FROM emp.fecha_nacimiento) BETWEEN 1970 AND 1979;

-- 4: Cree una vista "PELICULAS_ENTREGADA" que contenga el
-- código de la película y la cantidad de unidades entregadas.

-- Vista Proyección-Selección
-- No es actualizable, solo cuenta con 1 de las 2 pks
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_4_PELICULAS_ENTREGADAS AS
    SELECT ren_en.codigo_pelicula, ren_en.cantidad
    FROM unc_esq_peliculas.renglon_entrega ren_en;

-- 5: Cree una vista "ACCION_2000" con el código, el titulo el idioma
-- y el formato de las películas del género ‘Acción’ entregadas en el año 2006.

CREATE TABLE COPIA_PELICULAS AS
    SELECT *
    FROM unc_esq_peliculas.pelicula;

SELECT *
FROM V_TP_07_EJERCICIO_2_5_ACCION_2000_PGSQL
ORDER BY codigo_pelicula;

INSERT INTO V_TP_07_EJERCICIO_2_5_ACCION_2000_PGSQL (codigo_pelicula, titulo, idioma, formato)
VALUES (368, 'Bidi-Peulh-Thiou ', 'Urdu', 'Formato 25');

UPDATE V_TP_07_EJERCICIO_2_5_ACCION_2000_SQL SET formato = 'Formato 23' WHERE codigo_pelicula = 368;

-- Vista Proyección-Selección-Ensamble
-- Es actualizable en el marco postgresql.
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_5_ACCION_2000_PGSQL AS
    SELECT p.codigo_pelicula, p.titulo, p.idioma, p.formato
    FROM copia_peliculas p
    WHERE p.genero = 'Acción' AND
        EXISTS(
            SELECT 1
            FROM unc_esq_peliculas.renglon_entrega ren
            WHERE ren.codigo_pelicula = p.codigo_pelicula AND
                EXISTS(
                SELECT 1
                FROM unc_esq_peliculas.entrega e
                WHERE e.nro_entrega = ren.nro_entrega AND
                    EXTRACT('YEAR' FROM e.fecha_entrega) = 2006
                    )
        );

-- Vista Selección-Proyección-Ensamble
-- Vista actualizable segun estandar SQL.
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_5_ACCION_2000_SQL AS
    SELECT p.codigo_pelicula, p.titulo, p.idioma, p.formato
    FROM copia_peliculas p
    JOIN unc_esq_peliculas.renglon_entrega r ON r.codigo_pelicula = p.codigo_pelicula
    JOIN unc_esq_peliculas.entrega e ON e.nro_entrega = r.nro_entrega
    WHERE p.genero = 'Acción' AND EXTRACT('YEAR' FROM e.fecha_entrega) = 2006;

-- 6: Cree una vista "DISTRIBUIDORAS_ARGENTINA" con los datos completos
-- de las distribuidoras nacionales y sus respectivos departamentos.

SELECT *
FROM V_TP_07_EJERCICIO_2_6_DISTRIBUIDORAS_ARGENTINAS;

-- Vista de Selección-Proyección-Ensamble
-- Vista no actualizable bajo el estandar sql ni Postgresql
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_6_DISTRIBUIDORAS_ARGENTINAS AS
    SELECT dis.id_distribuidor, departamentos.id_departamento, dis.nombre, dis.direccion, dis.telefono
    FROM (
            SELECT dis.*
            FROM unc_esq_peliculas.distribuidor dis
            WHERE dis.tipo = 'N'
         ) dis JOIN
        (
            SELECT dep.id_distribuidor, dep.id_departamento
            FROM unc_esq_peliculas.departamento dep
        ) departamentos ON dis.id_distribuidor = departamentos.id_distribuidor;

-- 7: De la vista anterior cree la vista "DISTRIBUIDORAS_MAS_2_EMP"con los datos
-- completos de las distribuidoras cuyos departamentos tengan más de 2 empleados.

SELECT *
FROM V_TP_07_EJERCICIO_2_7_DISTRIBUIDORAS_ARGENTINAS_MAS_2_EMP
ORDER BY id_distribuidor;

INSERT INTO V_TP_07_EJERCICIO_2_7_DISTRIBUIDORAS_ARGENTINAS_MAS_2_EMP
    (id_distribuidor, id_departamento, nombre, direccion, telefono) VALUES
    (6, 87, 'Distribuidor 6', 'Ide 8506', '545-8609');


UPDATE V_TP_07_EJERCICIO_2_7_DISTRIBUIDORAS_ARGENTINAS_MAS_2_EMP
SET direccion = 'nueva 333'
WHERE id_distribuidor = 6 AND id_departamento = 87;

-- Vista de Selección-Proyeción-Ensamble
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_7_DISTRIBUIDORAS_ARGENTINAS_MAS_2_EMP AS
    SELECT dis.*
    FROM V_TP_07_EJERCICIO_2_6_DISTRIBUIDORAS_ARGENTINAS dis
    WHERE (dis.id_departamento, dis.id_distribuidor) IN (
            SELECT emp.id_departamento, emp.id_distribuidor
            FROM unc_esq_peliculas.empleado emp
            GROUP BY emp.id_departamento, emp.id_distribuidor
            HAVING count(*) > 2
        );


-- 8: Cree la vista "PELI_ARGENTINA" con los datos completos de las productoras
-- y las películas que fueron producidas por empresas productoras de nuestro país.

SELECT *
FROM V_TP_07_EJERCICIO_2_8_PELI_ARGENTINA;

-- Vista Seleccion-Proyección-Ensamble
-- Es actualizable en el estandard SQL pero NO en postgreSQL
CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_8_PELI_ARGENTINA AS
    SELECT empresa.codigo_productora, empresa.nombre_productora, empresa.id_ciudad, peli.codigo_pelicula, peli.titulo, peli.genero, peli.idioma, peli.formato
    FROM unc_esq_peliculas.empresa_productora empresa
    JOIN (
        SELECT c.id_ciudad
        FROM unc_esq_peliculas.ciudad c
        WHERE id_pais = (
                SELECT p.id_pais
                FROM unc_esq_peliculas.pais p
                WHERE p.nombre_pais = 'ARGENTINA')
    ) ciudad ON ciudad.id_ciudad = empresa.id_ciudad
    JOIN unc_esq_peliculas.pelicula peli ON peli.codigo_productora = empresa.codigo_productora

-- 9: De la vista anterior cree la vista "ARGENTINAS_NO_ENTREGADA"
-- para las películas producidas por empresas argentinas pero que no han sido entregadas.

SELECT *
FROM V_TP_07_EJERCICIO_2_9_ARGENTINAS_NO_ENTREGADAS; -- 226

CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_9_ARGENTINAS_NO_ENTREGADAS AS
    SELECT pelis.*
    FROM V_TP_07_EJERCICIO_2_8_PELI_ARGENTINA pelis
    JOIN unc_esq_peliculas.renglon_entrega ren_en ON ren_en.codigo_pelicula = pelis.codigo_pelicula
    WHERE ren_en.nro_entrega NOT IN (
        SELECT entrega.nro_entrega
        FROM unc_esq_peliculas.entrega
    );

-- 10: Cree una vista "PRODUCTORA_MARKETINERA" con las empresas productoras que hayan
-- entregado películas a TODOS los distribuidores.

SELECT *
FROM V_TP_07_EJERCICIO_2_10_PRODUCTORA_MARKETINERA;

CREATE OR REPLACE VIEW V_TP_07_EJERCICIO_2_10_PRODUCTORA_MARKETINERA AS
    SELECT empresas.*, info.cant_distribuidores
    FROM unc_esq_peliculas.empresa_productora empresas
    JOIN (
        SELECT codigo_productora,  count(DISTINCT entregas.id_distribuidor) cant_distribuidores
        FROM unc_esq_peliculas.renglon_entrega ren_en
        JOIN (
                SELECT p.codigo_pelicula, p.codigo_productora
                FROM unc_esq_peliculas.pelicula p
            ) peliculas ON ren_en.codigo_pelicula = peliculas.codigo_pelicula
        JOIN (
                SELECT en.nro_entrega, en.id_distribuidor
                FROM unc_esq_peliculas.entrega en
            ) entregas ON ren_en.nro_entrega = entregas.nro_entrega
        GROUP BY peliculas.codigo_productora
    ) info ON info.codigo_productora = empresas.codigo_productora
    WHERE cant_distribuidores = (
            SELECT COUNT(*)
            FROM unc_esq_peliculas.distribuidor
        );


-- Ejercicio 3:
-- Analice cuáles serían los controles y el comportamiento ante actualizaciones
-- sobre las vistas "EMPLEADO_DIST", "EMPLEADO_DIST_2000" y "EMPLEADO_DIST_20_70"
-- creadas en el ej. 2, si las mismas están definidas con
-- WITH CHECK OPTION LOCAL o CASCADE en cada una de ellas.
-- Evalúe todas las alternativas.

-- No es necesario evaluar nada, ya que EMPLEADO_DIST no es key-preserved, por lo  tanto
-- no es actualiable, y como las otras 2 vistas dependen de EMPLEADO_DIST, tampoco son
-- actualizables.
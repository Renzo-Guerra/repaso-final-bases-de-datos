SET SEARCH_PATH = unc_251340;

-- Ejercicio 1
-- Consultas con anidamiento (usando IN, NOT IN, EXISTS, NOT EXISTS):

-- 1.1: Pelicula
-- Listar todas las películas que poseen entregas de películas de
-- idioma "Inglés" durante el año 2006.

SELECT p.codigo_pelicula, p.titulo, p.idioma
FROM unc_esq_peliculas.pelicula p
WHERE p.idioma = 'Inglés' AND
      EXISTS (
        SELECT 1
        FROM unc_esq_peliculas.renglon_entrega ren_en
        WHERE p.codigo_pelicula = ren_en.codigo_pelicula AND
            EXISTS(
                SELECT 1
                FROM unc_esq_peliculas.entrega en
                WHERE en.nro_entrega = ren_en.nro_entrega AND
                      EXTRACT('YEAR' FROM en.fecha_entrega) = 2006
            )
    )
ORDER BY p.codigo_pelicula;

SELECT p.codigo_pelicula, p.titulo, p.idioma
FROM unc_esq_peliculas.pelicula p
WHERE p.idioma = 'Inglés' AND
      p.codigo_pelicula IN (
            SELECT DISTINCT ren_en.codigo_pelicula
            FROM unc_esq_peliculas.renglon_entrega ren_en
            WHERE ren_en.nro_entrega IN (
                        SELECT en.nro_entrega
                        FROM unc_esq_peliculas.entrega en
                        WHERE EXTRACT('YEAR' FROM en.fecha_entrega) = 2006
                )
        )
ORDER BY p.codigo_pelicula;

-- 1.2: Pelicula
-- Indicar la cantidad de películas que han sido entregadas en 2006 por un
-- distribuidor nacional. (Trate de resolverlo utilizando ensambles)
-- Con ensamble:
SELECT dist.id_distribuidor, dist.nombre, dist.telefono, SUM(ren_en.cantidad) AS cant_peliculas_entregadas_en_2006
FROM unc_esq_peliculas.entrega en
INNER JOIN (
    SELECT d.id_distribuidor, d.nombre, d.telefono
    FROM unc_esq_peliculas.distribuidor d
    WHERE d.tipo = 'I'
) dist ON dist.id_distribuidor = en.id_distribuidor
INNER JOIN unc_esq_peliculas.renglon_entrega ren_en ON ren_en.nro_entrega = en.nro_entrega
GROUP BY dist.id_distribuidor, dist.nombre, dist.telefono;

-- 1.3: Pelicula
-- Indicar los departamentos que no posean empleados cuya diferencia de sueldo
-- máximo y mínimo (asociado a la tarea que realiza) no supere el 40% del
-- sueldo máximo. (Probar con 10% para que retorne valores)
SELECT dep.id_departamento, dep.id_distribuidor, dep.nombre
FROM (
        SELECT d.id_departamento, d.id_distribuidor, d.nombre
        FROM esq_pel_departamento d
     ) dep
WHERE NOT EXISTS(
    SELECT 1
    FROM (
            SELECT emp1.id_departamento, emp1.id_distribuidor, emp1.id_tarea
            FROM esq_pel_empleado emp1
         ) e1
    WHERE e1.id_departamento = dep.id_departamento AND
          e1.id_distribuidor = dep.id_distribuidor AND
            NOT EXISTS(
                SELECT 1
                FROM(
                        SELECT emp2.id_tarea, emp2.sueldo
                        FROM esq_pel_empleado emp2
                    ) emp
                WHERE emp.id_tarea = e1.id_tarea
                GROUP BY emp.id_tarea
                HAVING (MAX(emp.sueldo) - MIN(emp.sueldo)) > (MAX(emp.sueldo) / 100 * 40)
            )
);

SELECT emp_dep.id_departamento, emp_dep.id_distribuidor
FROM (
        SELECT DISTINCT e.id_departamento, e.id_distribuidor
        FROM esq_pel_empleado e
     ) emp_dep
WHERE NOT EXISTS(
    SELECT 1
    FROM (
            SELECT emp1.id_departamento, emp1.id_distribuidor, emp1.id_tarea
            FROM esq_pel_empleado emp1
         ) e1
    WHERE e1.id_departamento = emp_dep.id_departamento AND
          e1.id_distribuidor = emp_dep.id_distribuidor AND
            NOT EXISTS(
                SELECT 1
                FROM(
                        SELECT emp2.id_tarea, emp2.sueldo
                        FROM esq_pel_empleado emp2
                    ) emp
                WHERE emp.id_tarea = e1.id_tarea
                GROUP BY emp.id_tarea
                HAVING (MAX(emp.sueldo) - MIN(emp.sueldo)) > (MAX(emp.sueldo) / 100 * 40)
            )
);

-- 1.4: Peliculas
-- Liste las películas que nunca han sido
-- entregadas por un distribuidor nacional
SELECT pel.codigo_pelicula, pel.titulo
FROM esq_pel_pelicula pel
INNER JOIN (
    SELECT DISTINCT ren_en.codigo_pelicula peliculas_nunca_entregadas_por_distribuidor_nacional
    FROM esq_pel_renglon_entrega ren_en
    WHERE ren_en.nro_entrega IN(
            SELECT entrega.nro_entrega
            FROM esq_pel_entrega entrega
            WHERE NOT EXISTS(
                SELECT 1
                FROM esq_pel_distribuidor dist
                WHERE dist.id_distribuidor = entrega.id_distribuidor AND
                      dist.tipo = 'N'
            )
        )
    ) peliculas_nunca_entregadas ON peliculas_nunca_entregadas.peliculas_nunca_entregadas_por_distribuidor_nacional = pel.codigo_pelicula
ORDER BY pel.codigo_pelicula;

-- 1.5: Pelicula
-- Determinar los jefes que poseen personal a cargo y
-- cuyos departamentos (los del jefe) se encuentren en la Argentina.
SELECT dep.jefe_departamento
FROM esq_pel_departamento dep
WHERE dep.id_ciudad IN (
        SELECT c.id_ciudad
        FROM esq_pel_ciudad c
        WHERE c.id_pais IN (
                SELECT p.id_pais
                FROM esq_vol_pais p
                WHERE p.nombre_pais = 'Argentina'
            )
    ) AND
    EXISTS(
        SELECT 1
        FROM esq_pel_empleado emp
        WHERE emp.id_jefe = dep.jefe_departamento
    );

-- 1.6: Peliculas
-- Liste el apellido y nombre de los empleados que pertenecen a aquellos
-- departamentos de Argentina y donde el jefe de departamento posee
-- una comisión de más del 10% de la que posee su empleado a cargo.
-- Con agrupamiento
SELECT emp.id_departamento, emp.id_distribuidor, emp.apellido, emp.nombre, emp.sueldo
FROM esq_pel_empleado emp
INNER JOIN(
    SELECT dep.id_departamento, dep.id_distribuidor, dep.jefe_departamento
    FROM esq_pel_departamento dep
    WHERE dep.id_ciudad IN (
            SELECT c.id_ciudad
            FROM esq_pel_ciudad c
            WHERE c.id_pais IN (
                    SELECT p.id_pais
                    FROM esq_vol_pais p
                    WHERE p.nombre_pais = 'Argentina'
                )
        ) AND
        EXISTS(
            SELECT 1
            FROM esq_pel_empleado emp_jefe
            WHERE emp_jefe.id_empleado = dep.jefe_departamento
        )
) jefes ON jefes.id_departamento = emp.id_departamento AND
           jefes.id_distribuidor = emp.id_distribuidor
WHERE (emp.sueldo * 1.1) <= (
        SELECT emp_jef.sueldo
        FROM esq_pel_empleado emp_jef
        WHERE emp_jef.id_empleado = jefes.jefe_departamento
    )
ORDER BY emp.apellido;

-- Sin agrupamiento
SELECT emp.apellido, emp.nombre
FROM esq_pel_empleado emp
WHERE (emp.id_departamento, emp.id_distribuidor) IN (
    SELECT dep.id_departamento, dep.id_distribuidor
    FROM esq_pel_departamento dep
    WHERE dep.id_ciudad IN (
            SELECT c.id_ciudad
            FROM esq_pel_ciudad c
            WHERE c.id_pais IN (
                    SELECT p.id_pais
                    FROM esq_vol_pais p
                    WHERE p.nombre_pais = 'Argentina'
                )
        ) AND
        EXISTS(
            SELECT 1
            FROM esq_pel_empleado emp_jefe
            WHERE emp_jefe.id_empleado = dep.jefe_departamento AND
            (emp.sueldo * 1.1) <=  emp_jefe.sueldo
        )
)
ORDER BY emp.apellido;

-- Consultas que involucran agrupamiento:

-- 1.7: Peliculas
-- Indicar la cantidad de películas entregadas a partir del 2010, por género.
SELECT pelicula.genero, SUM(ren.cantidad) AS cantidad_de_películas_entregadas_a_partir_del_2010
FROM (
        SELECT ent.nro_entrega
        FROM esq_pel_entrega ent
        WHERE EXTRACT('YEAR' FROM ent.fecha_entrega) >= 2010
     ) entrega
JOIN esq_pel_renglon_entrega ren ON entrega.nro_entrega = ren.nro_entrega
JOIN (
        SELECT pel.codigo_pelicula, pel.genero
        FROM esq_pel_pelicula pel
) pelicula ON pelicula.codigo_pelicula = ren.codigo_pelicula
GROUP BY pelicula.genero;

-- 1.8: Peliculas
-- Realizar un resumen de entregas por día, indicando el video club
-- al cual se le realizó la entrega y la cantidad entregada.
-- Ordenar el resultado por fecha.
SELECT epv.*, SUM(renglon_en.cantidad) cantidad_peliculas_entregadas, entrega.fecha_entrega
FROM esq_pel_entrega entrega
JOIN (
    SELECT ren.nro_entrega, ren.cantidad
    FROM esq_pel_renglon_entrega ren
) renglon_en ON entrega.nro_entrega = renglon_en.nro_entrega
JOIN (
    SELECT v.id_video, v.propietario
    FROM esq_pel_video v
) epv ON entrega.id_video = epv.id_video
GROUP BY entrega.fecha_entrega, epv.id_video, epv.propietario
ORDER BY entrega.fecha_entrega;

-- 1.9: Peliculas
-- Listar, para cada ciudad, el nombre de la ciudad y la cantidad de
-- empleados mayores de edad que desempeñan tareas en departamentos de
-- la misma y que posean al menos 30 empleados.
SELECT c.nombre_ciudad, cant_empleado_x_dep.cant_emp_dep
FROM esq_pel_ciudad c
JOIN (
    SELECT dep.id_distribuidor, dep.id_departamento, dep.id_ciudad
    FROM esq_pel_departamento dep
) depart ON depart.id_ciudad = c.id_ciudad
JOIN (
    SELECT emp.id_distribuidor, emp.id_departamento, COUNT(*) cant_emp_dep
    FROM esq_pel_empleado emp
    WHERE EXTRACT('YEAR' FROM AGE(NOW(), emp.fecha_nacimiento)) >= 18
    GROUP BY  emp.id_distribuidor, emp.id_departamento
    HAVING count(*) > 30
) cant_empleado_x_dep ON cant_empleado_x_dep.id_distribuidor = depart.id_distribuidor AND
                         cant_empleado_x_dep.id_departamento = depart.id_departamento
ORDER BY cant_empleado_x_dep.cant_emp_dep DESC;

-- 2.1: Voluntario
-- Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan
-- aportes. Ordene el resultado por nombre de institución.
SELECT inst.nombre_institucion, SUM(cant_vol_con_hs_aportadas)
FROM esq_vol_institucion inst
JOIN (
    SELECT v.id_institucion, COUNT(*) cant_vol_con_hs_aportadas
    FROM esq_vol_voluntario v
    WHERE v.horas_aportadas IS NOT NULL
    GROUP BY v.id_institucion
) voluntario ON inst.id_institucion = voluntario.id_institucion
GROUP BY voluntario.id_institucion, inst.nombre_institucion
ORDER BY inst.nombre_institucion;

-- 2.2. Determine la cantidad de coordinadores en cada país, agrupados por nombre de
-- país y nombre de continente. Etiquete la primer columna como 'Número de coordinadores'
SELECT pais.nombre_pais, continente.nombre_continente, COUNT(*) AS Número_de_coordinadores
FROM (
        SELECT DISTINCT v1.id_coordinador
        FROM esq_vol_voluntario v1
        WHERE v1.id_coordinador IS NOT NULL) id_coordinadores JOIN
    (
        SELECT v2.nro_voluntario, id_institucion
        FROM esq_vol_voluntario v2
    ) coordinadores ON coordinadores.nro_voluntario = id_coordinadores.id_coordinador
JOIN (
    SELECT inst.id_institucion, inst.id_direccion
    FROM esq_vol_institucion inst
) institucion ON institucion.id_institucion = coordinadores.id_institucion
JOIN (
    SELECT dir.id_direccion, dir.id_pais
    FROM esq_vol_direccion dir
) direccion ON direccion.id_direccion = institucion.id_direccion
JOIN (
    SELECT p.id_pais, p.nombre_pais, p.id_continente
    FROM esq_vol_pais p
) pais ON pais.id_pais = direccion.id_pais
JOIN (
    SELECT c.id_continente, c.nombre_continente
    FROM esq_vol_continente c
) continente ON continente.id_continente = pais.id_continente
GROUP BY pais.nombre_pais, continente.nombre_continente;

-- 2.3: Voluntario
-- Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de
-- cualquier voluntario que trabaje en la misma institución que el Sr. de apellido Zlotkey.
-- Excluya del resultado a Zlotkey.
SELECT v2.id_institucion, v2.apellido, v2.nombre, v2.fecha_nacimiento
FROM esq_vol_voluntario v2
WHERE v2.apellido NOT LIKE 'Zlotkey' AND EXISTS(
    SELECT 1
    FROM esq_vol_voluntario v_zlot
    WHERE v_zlot.id_institucion = v2.id_institucion)
ORDER BY v2.apellido DESC;

-- 2.4: Voluntario
-- Cree una consulta para mostrar los números de voluntarios y los apellidos de todos
-- los voluntarios cuya cantidad de horas aportadas sea mayor que la media de las horas
-- aportadas. Ordene los resultados por horas aportadas en orden ascendente.
SELECT voluntario.nro_voluntario, voluntario.apellido--, voluntario.horas_aportadas
FROM esq_vol_voluntario voluntario
WHERE voluntario.horas_aportadas > (
        SELECT AVG(COALESCE(v_avg_horas.horas_aportadas, 0))
        FROM esq_vol_voluntario v_avg_horas
    )
-- ORDER BY voluntario.horas_aportadas

-- 3.0 (Crear la tabla)
CREATE TABLE distribuidor_nac(
    id_distribuidor numeric(5,0) NOT NULL,
    nombre character varying(80) NOT NULL,
    direccion character varying(120) NOT NULL,
    teleforno character varying(20),
    nro_inscripcion numeric(8,0) NOT NULL,
    encargado character varying(60) NOT NULL,
    id_distrib_mayorista numeric(5,0),
    CONSTRAINT pk_distribuidorNac PRIMARY KEY (id_distribuidor)
);

-- 3.1: (Poblar tabla)
-- Se solicita llenarla con la información correspondiente a los datos
-- completos de todos los distribuidores nacionales.
INSERT INTO distribuidor_nac (
    SELECT distribuidor.*, nac.nro_inscripcion, nac.encargado, nac.id_distrib_mayorista
    FROM esq_pel_nacional nac
    JOIN (
        SELECT d.id_distribuidor, d.nombre, d.direccion, d.telefono
        FROM esq_pel_distribuidor d
        WHERE d.tipo = 'N'
    ) distribuidor ON distribuidor.id_distribuidor = nac.id_distribuidor
);

-- 3.2:
-- Agregar a la definición de la tabla distribuidor_nac, el campo "codigo_pais" que
-- indica el código de país del distribuidor mayorista que atiende a cada distribuidor
-- nacional.(codigo_pais varchar(5) NULL)
ALTER TABLE distribuidor_nac ADD COLUMN codigo_pais VARCHAR(5) DEFAULT NULL;

-- 3.3:
-- Para todos los registros de la tabla distribuidor_nac, llenar el nuevo campo
-- "codigo_pais" con el valor correspondiente existente en la tabla "Internacional".
SELECT *
FROM distribuidor_nac JOIN esq_pel_internacional internacional
    ON distribuidor_nac.id_distrib_mayorista = internacional.id_distribuidor;

SELECT *
FROM distribuidor_nac;

SELECT *
FROM esq_pel_internacional;


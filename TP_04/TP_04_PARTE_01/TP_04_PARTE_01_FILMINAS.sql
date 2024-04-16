SET SEARCH_PATH = unc_251340;

SELECT *
FROM unc_esq_voluntario.institucion;

-- Solo selecciona los id_cordinador que no son repetidos
SELECT DISTINCT id_coordinador
FROM unc_esq_voluntario.voluntario
WHERE id_coordinador IS NOT NULL; -- El distinct toma solo 1 resultado en NULL

-- El distinct lo aplica a cada columna junta, el id_institucion y
-- el id_cordinador no pueden aparecer como otra combinacion en otra fila.
SELECT DISTINCT id_institucion, id_coordinador
FROM unc_esq_voluntario.voluntario
ORDER BY id_institucion;


-- Ejercicio 1: ¿Cuántas Instituciones tiene la tabla Institución y cuales son?
SELECT id_institucion, nombre_institucion
FROM unc_esq_voluntario.institucion
ORDER BY institucion.id_institucion;

SELECT v.nombre, v.apellido
FROM unc_esq_voluntario.voluntario v;

SELECT *, (t.max_horas - t.min_horas) AS diferencia_hs
FROM unc_esq_voluntario.tarea t
ORDER BY (t.max_horas - t.min_horas);

-- Concatenar de esta forma es peligroso, ya que al intentar concatenar
-- una string con un null, vuelve null a la cadena de texto resultante
SELECT (COALESCE(d.calle, '')||', '||COALESCE(d.ciudad, '')||', '||COALESCE(d.provincia, '')) AS calle_ciudad_provincia, d.codigo_postal, d.id_pais, d.id_direccion
FROM unc_esq_voluntario.direccion d;

-- En cambio CONCAT ignora los valores NULL
SELECT CONCAT(d.calle, ', ', d.ciudad, ', ', d.provincia) AS calle_ciudad_provincia, d.codigo_postal, d.id_pais, d.id_direccion
FROM unc_esq_voluntario.direccion d;

-- Ejercicios 3:
-- 1: ¿Cuáles son los voluntarios nacidos antes de la década del ‘90?
SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE EXTRACT('year' FROM v.fecha_nacimiento) < 1990;

SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE DATE_PART('year', v.fecha_nacimiento) < 1990;

-- 2: ¿Cuáles son los voluntarios con nombre David?
SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE v.nombre = 'David';

-- 3: ¿Cuáles son los voluntarios con apellido Smith?
SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE v.apellido = 'Smith';

-- Ejemplo: Seleccionar los voluntarios que son coordinados por los
-- voluntarios nro 100 y 124 que están trabajando para la institución
-- cuyo código es 50.

SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE v.id_institucion = 50
  AND (id_coordinador = 100 OR v.id_coordinador = 124)

-- ¿Cuáles son los voluntarios nacidos entre 1988 y 1995?

SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE EXTRACT('YEAR' FROM v.fecha_nacimiento) BETWEEN 1988 AND 1995
ORDER BY v.fecha_nacimiento;

SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE DATE_PART('YEAR', v.fecha_nacimiento) BETWEEN 1988 AND 1995
ORDER BY v.fecha_nacimiento;

-- ¿Cuáles son los voluntarios con nombre David o con
-- apellido Smith y que realicen la tarea SA_REP?

SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE v.id_tarea = 'SA_REP' AND (v.nombre = 'David' OR v.apellido = 'Smith');

-- Listar los apellidos ordenados descendentemente y nombres de los
-- voluntarios que son coordinados por el voluntario 124.

SELECT v.apellido, v.nombre
FROM unc_esq_voluntario.voluntario v
WHERE v.id_coordinador = 124
ORDER BY v.apellido DESC, v.nombre;

-- Seleccionar los datos de los voluntarios que
-- corresponden a los 10 primeros voluntarios.

SELECT *
FROM unc_esq_voluntario.voluntario v
ORDER BY v.nro_voluntario ASC
LIMIT 10;

-- Seleccionar los datos de los voluntarios
-- a partir del 15TO voluntario.

SELECT *
FROM unc_esq_voluntario.voluntario v
ORDER BY v.nro_voluntario ASC
OFFSET 14;

-- ¿Cuáles son los 10 voluntarios mayores?

SELECT *
FROM unc_esq_voluntario.voluntario v
ORDER BY v.fecha_nacimiento ASC
LIMIT 10;

-- En orden alfabético ¿quiénes son los 5 primeros
-- voluntarios de la institución 80?

SELECT *
FROM unc_esq_voluntario.voluntario v
WHERE v.id_institucion = 80
ORDER BY v.apellido ASC
LIMIT 5;

-- Seleccionar la fecha de nacimiento del voluntario mas joven con el mas viejo.
SELECT MAX(fecha_nacimiento) AS voluntario_mas_joven, MIN(fecha_nacimiento) AS voluntario_mas_viejo
FROM unc_esq_voluntario.voluntario;

-- El count cuenta la cantidad.

-- RECORDAR: Las funciones de grupo IGNORAN LOS VALORES NULOS del atributo.
SELECT COUNT(d.ciudad) AS cantidad_ciudades
FROM unc_esq_voluntario.direccion d; -- Muestra 23

SELECT COUNT(d.provincia) AS cantidad_ciudades
FROM unc_esq_voluntario.direccion d; -- Muestra 17

-- La función COALESCE(columna, valor_reemplazo) en POSTGRESQL fuerzan
-- a las funciones de grupo a que incluyan valores nulos,
-- retornando un valor en ocurrencia de un nulo.

SELECT AVG(v.porcentaje) AS porcentaje_promedio
FROM unc_esq_voluntario.voluntario v;
-- COALESCE toma los valores internos y devuelve el primer valor no nulo.
-- En caso de que v.porcentaje sea nullo -> devolverá cero (0).
SELECT AVG(COALESCE(v.porcentaje, 0)) AS porcentaje_promedio
FROM unc_esq_voluntario.voluntario v;


-- GROUP BY:
SELECT v.id_institucion, i.nombre_institucion, count(*) CANTIDAD_VOLUNTARIOS
FROM unc_esq_voluntario.voluntario v
INNER JOIN(
    SELECT ins.id_institucion, ins.nombre_institucion
    FROM unc_esq_voluntario.institucion ins
) i ON i.id_institucion = v.id_institucion
WHERE v.id_institucion IS NOT NULL
GROUP BY v.id_institucion, i.nombre_institucion
ORDER BY count(*) DESC;

-- Liste las diferentes instituciones y el máximo
-- de horas aportadas a cada una de ellas

SELECT v.id_institucion, i.nombre_institucion, MAX(v.horas_aportadas)
FROM unc_esq_voluntario.voluntario v
INNER JOIN(
    SELECT ins.id_institucion, ins.nombre_institucion
    FROM unc_esq_voluntario.institucion ins
) i ON i.id_institucion = v.id_institucion
GROUP BY v.id_institucion, i.nombre_institucion
ORDER BY MAX(v.horas_aportadas) DESC, i.nombre_institucion;


-- Determine los porcentajes promedio de los voluntarios por institución.
SELECT v.id_institucion, AVG(COALESCE(V.porcentaje, 0)) AS porcentaje_promedio
FROM unc_esq_voluntario.voluntario v
WHERE v.id_institucion IS NOT NULL
GROUP BY v.id_institucion;

-- ¿Cuántos voluntarios realizan cada tarea?
SELECT v.id_tarea, count(*) voluntarios_realizando_la_tarea
FROM unc_esq_voluntario.voluntario v
GROUP BY v.id_tarea
ORDER BY COUNT(*) DESC;

-- ¿Cuál es el promedio de horas aportadas por tarea?
SELECT v.id_tarea, avg(COALESCE(v.horas_aportadas, 0)) avg_horas_aportadas
FROM unc_esq_voluntario.voluntario v
GROUP BY v.id_tarea
ORDER BY avg(COALESCE(v.horas_aportadas, 0)) DESC;


-- HAVING:
-- Seleccionar los coordinadores que tengan
-- mas de 7 voluntarios a su disposicion.
SELECT v.id_coordinador, COUNT(*) cantidad_de_voluntarios
FROM unc_esq_voluntario.voluntario v
GROUP BY v.id_coordinador
HAVING COUNT(*) > 7;

-- ¿Cuáles son las tareas que tienen más de 10 voluntarios?
SELECT v.id_tarea, count(*) cantidad_voluntarios
FROM unc_esq_voluntario.voluntario v
GROUP BY v.id_tarea
HAVING count(*) > 10;

-- ¿Cuál es el promedio de horas aportadas por tarea solo
-- de aquellos voluntarios nacidos a partir del año 2000?
SELECT v.id_tarea, AVG(COALESCE(v.horas_aportadas, 0)) promedio_de_horas_aportadas
FROM unc_esq_voluntario.voluntario v
WHERE EXTRACT('YEAR' FROM v.fecha_nacimiento) >= 2000
GROUP BY v.id_tarea
ORDER BY AVG(COALESCE(v.horas_aportadas, 0)) DESC;

-- ¿Cuáles son las tareas cuyo promedio de horas aportadas por tarea
-- de los voluntarios nacidos a partir del año 1995 es superior
-- al promedio general de dicho grupo de voluntarios?
SELECT v.id_tarea, avg(COALESCE(v.horas_aportadas, 0)) promedio_de_horas_aportadas
FROM unc_esq_voluntario.voluntario v
WHERE EXTRACT('YEAR' FROM v.fecha_nacimiento) > 1995
GROUP BY v.id_tarea
HAVING
    avg(COALESCE(v.horas_aportadas, 0)) >
       (
            SELECT AVG(COALESCE(vol.horas_aportadas, 0))
            FROM unc_esq_voluntario.voluntario vol
            WHERE vol.id_tarea = v.id_tarea
        );
-- No devuelve nada porque no hay ninguno que sea mayor,
-- aunque si hay algunos que son iguales.

-- Verificando si está bien, aqui traigo el promedio de empleados > 1995
SELECT v.id_tarea, avg(COALESCE(v.horas_aportadas, 0)) promedio_de_horas_aportadas
FROM unc_esq_voluntario.voluntario v
WHERE EXTRACT('YEAR' FROM v.fecha_nacimiento) > 1995
GROUP BY v.id_tarea
ORDER BY v.id_tarea;

-- Verificando si está bien, aqui traigo el promedio general
SELECT v.id_tarea, AVG(COALESCE(v.horas_aportadas, 0))
FROM unc_esq_voluntario.voluntario v
GROUP BY v.id_tarea
ORDER BY v.id_tarea;

-- Los resultados concuerdan!!!
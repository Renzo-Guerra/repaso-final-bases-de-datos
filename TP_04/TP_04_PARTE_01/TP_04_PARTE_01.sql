set SEARCH_PATH = unc_esq_voluntario;

-- 1: Voluntario
-- Seleccione el identificador y nombre de
-- todas las instituciones  que son Fundaciones.
SELECT i.id_institucion, i.nombre_institucion
FROM unc_esq_voluntario.institucion i
WHERE i.nombre_institucion ILIKE '%fundacion%';

-- 2: Peliculas
-- Seleccione el identificador de distribuidor,
-- identificador de departamento y nombre de todos los departamentos.
SELECT d.id_distribuidor, d.id_departamento, d.nombre
FROM unc_esq_peliculas.departamento d;

-- 3: Peliculas
-- Muestre el nombre, apellido y el teléfono de todos los empleados
-- cuyo id_tarea sea 7231, ordenados por apellido y nombre.
SELECT e.nombre, e.apellido, e.telefono
FROM unc_esq_peliculas.empleado e
WHERE e.id_tarea = '7231'
ORDER BY apellido, nombre;

-- 4: Peliculas
-- Muestre el apellido e identificador de todos los
-- empleados que no cobran porcentaje de comisión.
SELECT e.id_empleado, e.apellido
FROM unc_esq_peliculas.empleado e
WHERE e.porc_comision IS NULL OR e.porc_comision = 0;


-- 5: Voluntarios
-- Muestre el apellido y el identificador de la tarea de
-- todos los voluntarios que no tienen coordinador.
SELECT v.apellido, v.id_tarea
FROM unc_esq_voluntario.voluntario v
WHERE v.id_coordinador IS NULL;

-- 6: Peliculas
-- Muestre los datos de los distribuidores
-- internacionales que no tienen registrado teléfono.
SELECT *
FROM unc_esq_peliculas.distribuidor d
WHERE d.tipo = 'I' AND d.telefono IS NULL;

-- 7: Peliculas
-- Muestre los apellidos, nombres y mails de los empleados
-- con cuentas de gmail y cuyo sueldo sea superior a $ 1000.
SELECT e.apellido, e.nombre, e.e_mail
FROM unc_esq_peliculas.empleado e
WHERE e.sueldo > 1000 AND e.e_mail LIKE '%gmail%';

-- 8: Peliculas
-- Seleccione los diferentes identificadores
-- de tareas que se utilizan en la tabla empleado.
SELECT DISTINCT e.id_tarea
FROM unc_esq_peliculas.empleado e;

-- 9: Voluntario
-- Muestre el apellido, nombre y mail de todos los voluntarios
-- cuyo teléfono comienza con +51.
-- Coloque el encabezado de las columnas de los títulos
-- 'Apellido y Nombre' y 'Dirección de mail'.
SELECT CONCAT(v.apellido, ' ', v.nombre) AS apellido_y_nombre, v.e_mail AS direccion_de_mail
FROM unc_esq_voluntario.voluntario v
WHERE v.telefono LIKE '+51%';

-- 10: Pelicula
-- Hacer un listado de los cumpleaños de todos los empleados donde se muestre
-- el nombre y el apellido (concatenados y separados por una coma) y
-- su fecha de cumpleaños (solo el día y el mes),
-- ordenado de acuerdo al mes y día de cumpleaños en forma ascendente.
SELECT CONCAT(e.nombre, ',', e.apellido) AS nombre_apellido, CONCAT(EXTRACT('DAY' FROM e.fecha_nacimiento), '-', EXTRACT('MONTH' FROM e.fecha_nacimiento))
FROM unc_esq_peliculas.empleado e
ORDER BY EXTRACT('MONTH' FROM e.fecha_nacimiento), EXTRACT('DAY' FROM e.fecha_nacimiento);

-- 11: Voluntarios
-- Recupere la cantidad mínima, máxima y promedio de horas aportadas
-- por los voluntarios nacidos desde 1990.
SELECT MIN(v.horas_aportadas), MAX(v.horas_aportadas), AVG(COALESCE(v.horas_aportadas, 0))
FROM unc_esq_voluntario.voluntario v
WHERE EXTRACT('YEAR' FROM v.fecha_nacimiento) >= 1990;

-- 12: Peliculas
-- Listar la cantidad de películas que hay por cada idioma.
SELECT p.idioma, COUNT(*) AS cantidad_peliculas
FROM unc_esq_peliculas.pelicula p
GROUP BY p.idioma;

-- 13: Peliculas
-- Calcular la cantidad de empleados por departamento.
SELECT e.id_departamento, e.id_distribuidor, COUNT(*)
FROM unc_esq_peliculas.empleado e
GROUP BY e.id_departamento, e.id_distribuidor;

-- 14: Peliculas
-- Mostrar los códigos de películas que han recibido entre 3 y 5 entregas.
-- (veces entregadas, NO cantidad de películas entregadas).
SELECT re.codigo_pelicula
FROM unc_esq_peliculas.renglon_entrega re
GROUP BY re.codigo_pelicula
HAVING COUNT(*) BETWEEN 3 AND 5;

-- 15: Voluntario
-- ¿Cuántos cumpleaños de voluntarios hay cada mes?
SELECT EXTRACT('MONTH' FROM v.fecha_nacimiento) AS mes, COUNT(*) AS cantidad
FROM unc_esq_voluntario.voluntario v
GROUP BY EXTRACT('MONTH' FROM v.fecha_nacimiento)
ORDER BY EXTRACT('MONTH' FROM v.fecha_nacimiento);

-- 16: Voluntario
-- ¿Cuáles son las 2 instituciones que más voluntarios tienen?
SELECT v.id_institucion, COUNT(*)
FROM unc_esq_voluntario.voluntario v
WHERE v.id_institucion IS NOT NULL
GROUP BY v.id_institucion
ORDER BY COUNT(*) DESC
LIMIT 2;

-- 17: Peliculas
-- ¿Cuáles son los id de ciudades que tienen más de un departamento?
SELECT dep.id_ciudad, COUNT(*)
FROM unc_esq_peliculas.departamento dep
GROUP BY dep.id_ciudad
HAVING COUNT(*) > 1;
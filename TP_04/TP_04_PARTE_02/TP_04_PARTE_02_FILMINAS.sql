SET SEARCH_PATH = unc_251340;

-- Seleccionar el nombre y apellido de los
-- voluntarios del estado (provincia) de Texas.

SELECT v.nombre, v.apellido
FROM (
	SELECT DISTINCT dir.id_direccion
	FROM esq_vol_direccion dir
	WHERE dir.provincia = 'Texas'
) d
INNER JOIN (
	SELECT id_institucion, id_direccion
	FROM esq_vol_institucion ins
	WHERE id_direccion IS NOT NULL
) i ON i.id_direccion = d.id_direccion
INNER JOIN (
	SELECT vol.nombre, vol.apellido, vol.id_institucion
	FROM esq_vol_voluntario vol
) v ON i.id_institucion = v.id_institucion;

-- Se desea seleccionar los voluntarios que
-- realizan la misma tarea que el voluntario 141 y que
-- aportan más horas que el voluntario 143
SELECT v.*
FROM esq_vol_voluntario v
WHERE v.id_tarea =
	(
		SELECT v1.id_tarea
		FROM esq_vol_voluntario v1
		WHERE v1.nro_voluntario = 141
	) AND
	v.horas_aportadas >
	(
		SELECT v2.horas_aportadas
		FROM esq_vol_voluntario v2
		WHERE v2.nro_voluntario = 143
	);

-- Seleccionar todos los voluntarios que aportan la mínima
-- cantidad de horas:
SELECT v.*
FROM esq_vol_voluntario v
WHERE v.horas_aportadas = (
			SELECT MIN(vol.horas_aportadas)
			FROM esq_vol_voluntario vol
		);

-- Instituciones donde la mínima cantidad de horas
-- que aportan sus voluntarios es mayor que la mínima
-- cantidad de horas que aportan los de la institución 40.
SELECT v.id_institucion, MIN(v.horas_aportadas) min_horas_aportadas
FROM esq_vol_voluntario v
WHERE v.id_institucion IS NOT NULL
GROUP BY v.id_institucion
HAVING MIN(v.horas_aportadas) > (
		SELECT MIN(vol.horas_aportadas)
		FROM esq_vol_voluntario vol
		WHERE vol.id_institucion = 40
	);

-- ¿Cuáles son las tareas cuyo promedio de horas aportadas
-- por tarea de los voluntarios nacidos a partir del año 1995
-- es superior al promedio general de dicho grupo de
-- voluntarios?

-- Para verificar es cambiar el > del HAVING por un >= e ir comparando el
-- promedio general x id tarea (sin distincion de la fecha de nacimiento)
-- con los arrojados en la tabla (Dicha consulta está abajo)
SELECT v.id_tarea, AVG(COALESCE(v.horas_aportadas, 0)) AS horas_aportadas
FROM (
	SELECT  vol.id_tarea, vol.horas_aportadas, vol.fecha_nacimiento
	FROM esq_vol_voluntario vol
) v
WHERE EXTRACT('YEAR' FROM v.fecha_nacimiento) >= 1995
GROUP BY v.id_tarea
HAVING AVG(COALESCE(v.horas_aportadas, 0)) >= (
	SELECT AVG(COALESCE(vol.horas_aportadas, 0))
	FROM (
		SELECT v1.horas_aportadas, v1.id_tarea
		FROM esq_vol_voluntario v1
		WHERE v1.id_tarea = v.id_tarea
	) vol
	GROUP BY vol.id_tarea)
ORDER BY v.id_tarea;
--
SELECT vol.id_tarea, AVG(COALESCE(vol.horas_aportadas, 0))
FROM (
        SELECT v1.horas_aportadas, v1.id_tarea
	    FROM esq_vol_voluntario v1
	    WHERE v1.id_tarea IN ('MK_MAN', 'MK_REP', 'PU_CLERK',
	                          'SA_MAN', 'SA_REP', 'SH_CLERK',
	                          'ST_CLERK', 'ST_MAN')
	) vol
GROUP BY vol.id_tarea
ORDER BY vol.id_tarea;

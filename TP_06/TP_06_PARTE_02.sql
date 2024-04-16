SET SEARCH_PATH = unc_251340;

-- Ejercicio 1
-- Para el esquema "unc_voluntarios" considere que se quiere mantener un registro de quién y
-- cuándo realizó actualizaciones sobre la tabla TAREA en la tabla HIS_TAREA.
-- Dicha tabla tiene la siguiente estructura:
-- HIS_TAREA(nro_registro, fecha, operación, usuario)
DROP TABLE TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA;
CREATE TABLE TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA AS
SELECT * FROM esq_vol_tarea;

ALTER TABLE TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA
ADD CONSTRAINT PK_TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA PRIMARY KEY (id_tarea);

DROP TABLE TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_HIS_TAREA;
CREATE TABLE TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_HIS_TAREA(
  nro_registro SERIAL NOT NULL,
  fecha TIMESTAMP NOT NULL,
  operacion VARCHAR(10) NOT NULL,
  usuario VARCHAR(40) NOT NULL,
  CONSTRAINT PK_TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_HIS_TAREA PRIMARY KEY (nro_registro)
);

-- A:Provea el/los trigger/s necesario/s para mantener en forma automática la tabla HIS_TAREA
-- cuando se realizan actualizaciones (insert, update o delete) en la tabla TAREA.


DROP FUNCTION FN_actualizar_tabla_TP_06_PARTE_02_EJERCICIO_1_HIS_TAREA_ROW;
CREATE OR REPLACE FUNCTION FN_actualizar_tabla_TP_06_PARTE_02_EJERCICIO_1_HIS_TAREA_ROW()
RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_HIS_TAREA (fecha, operacion, usuario)
    VALUES (NOW(), tg_op, current_user);

    IF(tg_op = 'DELETE')THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END
$$
LANGUAGE plpgsql;

DROP TRIGGER TG_TP_06_PARTE_02_EJERCICIO_1_ROW ON TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA;
CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_02_EJERCICIO_1_ROW
AFTER INSERT OR UPDATE OR DELETE
ON tp_06_parte_02_ejercicio_1_voluntario_tarea
FOR EACH ROW
EXECUTE FUNCTION FN_actualizar_tabla_TP_06_PARTE_02_EJERCICIO_1_HIS_TAREA_ROW()

-- B: Muestre los resultados de las tablas si se ejecuta la operación:
DELETE FROM TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA
WHERE id_tarea like 'AD%';

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA;

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_HIS_TAREA;
-- Genera 3 nuevos registros en la tabla VOLUNTARIO_HIS_TAREA


DROP FUNCTION FN_actualizar_tabla_TP_06_PARTE_02_EJERCICIO_1_HIS_TAREA_STATEM;
CREATE OR REPLACE FUNCTION FN_actualizar_tabla_TP_06_PARTE_02_EJERCICIO_1_HIS_TAREA_STATEM()
RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_HIS_TAREA (fecha, operacion, usuario)
    VALUES (NOW(), tg_op, current_user);

    IF(tg_op = 'DELETE')THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END
$$
LANGUAGE plpgsql;

DROP TRIGGER TG_TP_06_PARTE_02_EJERCICIO_1_STATEMENT ON tp_06_parte_02_ejercicio_1_voluntario_tarea;
CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_02_EJERCICIO_1_STATEMENT
AFTER INSERT OR UPDATE OR DELETE
ON tp_06_parte_02_ejercicio_1_voluntario_tarea
FOR EACH STATEMENT
EXECUTE FUNCTION FN_actualizar_tabla_TP_06_PARTE_02_EJERCICIO_1_HIS_TAREA_STATEM();

-- B: Muestre los resultados de las tablas si se ejecuta la operación:
DELETE FROM TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA
WHERE id_tarea ILIKE 'ad%';

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_TAREA;

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_1_VOLUNTARIO_HIS_TAREA;
-- Genera 1 nuevo registros en la tabla VOLUNTARIO_HIS_TAREA,
-- sin importar si el query afecta a mas de 1 fila en la tabla VOLUNTARIO_TAREA



-- Ejercicio 2:
-- A partir del esquema "UNC_PELICULAS", realice procedimientos para:

-- C) Completar una tabla denominada MAS_ENTREGADAS con los datos de
-- las 20 películas más entregadas en los últimos seis meses desde la
-- ejecución del procedimiento.
-- Esta tabla por lo menos debe tener las columnas
-- código_pelicula, nombre, cantidad_de_entregas
-- (en caso de coincidir en cantidad de entrega ordenar por código de película).

CREATE TABLE TP_06_PARTE_02_EJERCICIO_2_A_PELICULAS_MAS_ENTREGADAS(
  codigo_pelicula NUMERIC(5,0) NOT NULL,
  titulo VARCHAR(60) NOT NULL,
  cantidad_de_entregas INTEGER NOT NULL,
  genero VARCHAR(30) NOT NULL,
  CONSTRAINT PK_TP_06_PARTE_02_EJERCICIO_2_A_PELICULAS_MAS_ENTREGADAS PRIMARY KEY (codigo_pelicula)
);

CREATE PROCEDURE PR_ACTUALIZAR_PELICULAS_MAS_ENTREGADAS() AS
$$
BEGIN
    TRUNCATE TP_06_PARTE_02_EJERCICIO_2_A_PELICULAS_MAS_ENTREGADAS;
    INSERT INTO TP_06_PARTE_02_EJERCICIO_2_A_PELICULAS_MAS_ENTREGADAS(codigo_pelicula, titulo, cantidad_de_entregas, genero)
    SELECT esq_pel_pelicula.codigo_pelicula, esq_pel_pelicula.titulo, mayores_entregadas.veces_entregada, esq_pel_pelicula.genero
    FROM (
        SELECT codigo_pelicula, SUM(cantidad) veces_entregada
        FROM esq_pel_renglon_entrega
        GROUP BY codigo_pelicula
        ORDER BY SUM(cantidad) DESC, codigo_pelicula DESC
        LIMIT 20
    ) mayores_entregadas JOIN esq_pel_pelicula ON mayores_entregadas.codigo_pelicula = esq_pel_pelicula.codigo_pelicula;
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_2_A_PELICULAS_MAS_ENTREGADAS;

CALL PR_ACTUALIZAR_PELICULAS_MAS_ENTREGADAS();

-- D) Generar los datos para una tabla denominada SUELDOS,
-- con los datos de los empleados cuyas comisiones superen a la media
-- del departamento en el que trabajan.
-- Esta tabla debe tener las columnas id_empleado, apellido, nombre, sueldo, porc_comision.

DROP TABLE TP_06_PARTE_02_EJERCICIO_2_B_SUELDOS;
CREATE TABLE TP_06_PARTE_02_EJERCICIO_2_B_SUELDOS(
    id_empleado NUMERIC(6,0) NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    sueldo NUMERIC(8,2),
    porc_comision NUMERIC(6,2),
    comision_promedia_en_departamento NUMERIC(5,2),
    CONSTRAINT PK_TP_06_PARTE_02_EJERCICIO_2_B_SUELDOS PRIMARY KEY (id_empleado)
);

CREATE OR REPLACE PROCEDURE PR_SUELDOS_CUYAS_COMISIONES_SUPERAN_LA_MEDIA_DEL_DEPARTAMENTO() AS
$$
BEGIN
    -- Es valida, pero tarda 6 segundos
--     SELECT id_empleado, apellido, nombre, sueldo, porc_comision
--     FROM esq_pel_empleado emp
--     WHERE emp.porc_comision > (
--             SELECT AVG(COALESCE(dep.porc_comision, 0))
--             FROM esq_pel_empleado dep
--             WHERE dep.id_departamento = emp.id_departamento AND
--                   dep.id_distribuidor = emp.id_distribuidor
--             GROUP BY dep.id_departamento, dep.id_distribuidor
--         );

-- Tarda 300 ms en hacerse

    -- Borron de datos
    TRUNCATE TP_06_PARTE_02_EJERCICIO_2_B_SUELDOS;

    -- Carga los datos
    INSERT INTO TP_06_PARTE_02_EJERCICIO_2_B_SUELDOS(id_empleado, apellido, nombre, sueldo, porc_comision, comision_promedia_en_departamento)
    SELECT id_empleado, apellido, nombre, sueldo, porc_comision, depart.comision_promedia
    FROM (
            SELECT id_empleado, apellido, nombre, sueldo, porc_comision, id_distribuidor, id_departamento
            FROM esq_pel_empleado
         ) emp JOIN(
            SELECT dep.id_departamento, dep.id_distribuidor, AVG(COALESCE(dep.porc_comision, 0)) comision_promedia
            FROM esq_pel_empleado dep
            GROUP BY dep.id_departamento, dep.id_distribuidor
        ) depart ON depart.id_distribuidor = emp.id_distribuidor AND depart.id_departamento = emp.id_departamento
    WHERE emp.porc_comision > depart.comision_promedia
    ORDER BY ((porc_comision * 100 / comision_promedia) - 100) DESC;
    -- Los ordena del mayor porcentaje de diferencia entre el promedio del departamento y la porcion de comision
    -- del empleado al menor promedio del departamento y la porcion de comision del empleado.
END;
$$
LANGUAGE plpgsql;

SELECT * FROM TP_06_PARTE_02_EJERCICIO_2_B_SUELDOS;

CALL PR_SUELDOS_CUYAS_COMISIONES_SUPERAN_LA_MEDIA_DEL_DEPARTAMENTO();

-- E) Cambiar el distribuidor de las entregas sucedidas a partir de una fecha dada,
-- siendo que el par de valores de distribuidor viejo y distribuidor nuevo es variable.

-- Creando tablas y poblandolas...
DROP TABLE TP_06_PARTE_02_EJERCICIO_2_C_DISTRIBUIDOR;
CREATE TABLE TP_06_PARTE_02_EJERCICIO_2_C_DISTRIBUIDOR(
    id_distribuidor NUMERIC(5,0) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    direccion VARCHAR(120) NOT NULL,
    telefono VARCHAR(20),
    tipo CHARACTER(1),
    CONSTRAINT PK_TP_06_PARTE_02_EJERCICIO_2_C_DISTRIBUIDOR
        PRIMARY KEY (id_distribuidor)
);

DROP TABLE TP_06_PARTE_02_EJERCICIO_2_C_ENTREGAS;
CREATE TABLE TP_06_PARTE_02_EJERCICIO_2_C_ENTREGAS(
    nro_entrega NUMERIC(10,0) NOT NULL,
    fecha_entrega DATE NOT NULL,
    id_video NUMERIC(5,0) NOT NULL,
    id_distribuidor NUMERIC(5,0) NOT NULL,
    CONSTRAINT PK_TP_06_PARTE_02_EJERCICIO_2_C_ENTREGAS
        PRIMARY KEY (nro_entrega),
    CONSTRAINT FK_TP_06_PARTE_02_EJERCICIO_2_C_ENTREGAS_DISTRIBUIDOR
        FOREIGN KEY (id_distribuidor)
        REFERENCES TP_06_PARTE_02_EJERCICIO_2_C_DISTRIBUIDOR(id_distribuidor)
        MATCH FULL
);

INSERT INTO TP_06_PARTE_02_EJERCICIO_2_C_DISTRIBUIDOR
SELECT *
FROM esq_pel_distribuidor;

INSERT INTO TP_06_PARTE_02_EJERCICIO_2_C_ENTREGAS
SELECT *
FROM esq_pel_entrega;



CREATE OR REPLACE PROCEDURE PR_CAMBIAR_X_DISTRIBUIDOR_DE_ENTREGAS_DESDE_X_FECHA(fecha DATE, distribuidor_viejo NUMERIC(5,0), distribuidor_nuevo NUMERIC(5,0)) AS
$$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN( SELECT *
                FROM esq_pel_entrega e
                WHERE e.id_distribuidor = distribuidor_viejo
                      AND e.fecha_entrega >= fecha )
    LOOP
        RAISE NOTICE '% | %', rec.fecha_entrega, rec.id_distribuidor;

        UPDATE TP_06_PARTE_02_EJERCICIO_2_C_ENTREGAS
        SET id_distribuidor = distribuidor_nuevo
        WHERE id_distribuidor = distribuidor_viejo AND
              nro_entrega = rec.nro_entrega;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_2_C_ENTREGAS
ORDER BY id_distribuidor, fecha_entrega;

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_2_C_DISTRIBUIDOR;

CALL PR_CAMBIAR_X_DISTRIBUIDOR_DE_ENTREGAS_DESDE_X_FECHA('2003-01-01', 1, 3);

-- Ejercicio 3:
-- Para el esquema "UNC_VOLUNTARIOS" se desea conocer la cantidad de voluntarios que
-- hay en cada tarea al inicio de cada mes y guardarla a lo largo de los meses.
-- Para esto es necesario hacer un PROCEDIMIENTO que calcule la cantidad y la almacene
-- en una tabla denominada "CANT_VOLUNTARIOSXTAREA" con la siguiente estructura:

-- CANT_VOLUNTARIOSXTAREA (anio, mes, id_tarea, nombre_tarea, cant_voluntarios)

CREATE TABLE TP_06_PARTE_02_EJERCICIO_03_CANT_VOLUNTARIOSXTAREA(
    anio INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    id_tarea VARCHAR(10) NOT NULL,
    nombre_tarea VARCHAR(40) NOT NULL,
    cant_voluntarios NUMERIC(5,0) NOT NULL,
    CONSTRAINT PK_TP_06_PARTE_02_EJERCICIO_03_CANT_VOLUNTARIOSXTAREA PRIMARY KEY (anio, mes, id_tarea)
);

CREATE OR REPLACE PROCEDURE CARGAR_CANT_VOLUNTARIOS_X_TAREA_AL_COMIENZO_DEL_MES() AS
$$
BEGIN
    INSERT INTO TP_06_PARTE_02_EJERCICIO_03_CANT_VOLUNTARIOSXTAREA
    SELECT EXTRACT('YEAR' FROM NOW()), EXTRACT('MONTH' FROM NOW()), tarea.id_tarea, tarea.nombre_tarea, count(*)
    FROM (
            SELECT v.id_tarea
            FROM esq_vol_voluntario v
         ) vol JOIN(
            SELECT id_tarea, t.nombre_tarea
            FROM esq_vol_tarea t
         ) tarea ON vol.id_tarea = tarea.id_tarea
    GROUP BY tarea.id_tarea, tarea.nombre_tarea;
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM TP_06_PARTE_02_EJERCICIO_03_CANT_VOLUNTARIOSXTAREA
ORDER BY anio, mes, cant_voluntarios DESC;

SELECT *
FROM esq_vol_historico;

TRUNCATE TP_06_PARTE_02_EJERCICIO_03_CANT_VOLUNTARIOSXTAREA;

CALL CARGAR_CANT_VOLUNTARIOS_X_TAREA_AL_COMIENZO_DEL_MES();
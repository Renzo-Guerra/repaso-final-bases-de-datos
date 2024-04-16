SET SEARCH_PATH = unc_251340;

-- Los clientes con menos de 3 años de antiguedad pueden tener hasta 3 servicios instalados de cada tipo.
-- Restriccion multitabla / global
CREATE ASSERTION ASS_CLIENTES_POCA_ANTIGUEDAD_TOPE_SERVICIOS
CHECK(NOT EXISTS(SELECT 1
FROM (
        (
            SELECT c.nro_c, c.zona
            FROM final_cliente c
            WHERE EXTRACT('YEAR' FROM AGE(NOW(), c.fecha_alta)) < 3
         ) cliente INNER JOIN
         (
            SELECT ins.zona, ins.nro_c, ins.id_serv
            FROM FINAL_INSTALACION ins
         ) instalacion ON cliente.nro_c = instalacion.nro_c AND cliente.zona = instalacion.zona INNER JOIN
         (
            SELECT serv.id_serv, serv.tipo_serv
            FROM final_servicio serv
         ) servicio ON servicio.id_serv = instalacion.id_serv
    ) resultado
    GROUP BY resultado.zona, resultado.nro_c, resultado.tipo_serv
    HAVING COUNT(*) > 3)
);

-- La fecha de instalacion de cada servicio no puede ser anterior
-- ni posterior a los años de comienzo y de fin,
-- respectivamente, asociados a dicho servicio

-- Restriccion tipo multitabla / assertion
--
CREATE ASSERTION ASS_FECHA_INSTALACION_VALIDA
CHECK(NOT EXISTS(SELECT 1
FROM (
        (
            SELECT ins.id_serv, ins.fecha_instalacion
            FROM final_instalacion ins
         ) instalacion INNER JOIN
         (
            SELECT serv.id_serv, serv.anio_comienzo, serv.anio_fin
            FROM final_servicio serv
            WHERE serv.anio_fin IS NOT NULL
         ) servicio ON instalacion.id_serv = servicio.id_serv
) posibles_erroneos
WHERE EXTRACT(YEAR FROM posibles_erroneos.fecha_instalacion) NOT BETWEEN posibles_erroneos.anio_comienzo AND posibles_erroneos.anio_fin))

-- El año de comienzo de los servicios que son de vigilancia debe ser posterior a 2020.
-- Restriccion de tupla
ALTER TABLE final_servicio ADD CONSTRAINT CH_FECHA_COMIENZO_DESPUES_2020
CHECK((tipo_serv = 'M') OR ((tipo_serv = 'V') AND (anio_comienzo > 2020)));

-- 2: Considere que en la tabla Servicio se ha agregado un atributo "cant_cluentes"
-- en el cual se requiere registrar la cantidad de clientes a los que se ha
-- instalado cada servicio.
-- A: Establecer el valor inicial de cant_clientes a partir de los datos ya exisentes en la BD.
-- B: Mantener automaticamente actualizados el atribudo cant_clietes ante operaciones sobre la DB.


ALTER TABLE final_servicio ADD COLUMN cant_clientes INT DEFAULT 0;

CREATE OR REPLACE PROCEDURE cargar_por_primera_vez()
AS
$$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT finales.id_serv, count(*) cantidad
        FROM (
                SELECT instalaciones.id_serv, instalaciones.nro_c, instalaciones.zona
                FROM
                (
                    (
                        SELECT s.id_serv
                        FROM final_servicio s
                    )servicio
                    NATURAL JOIN
                    (
                        SELECT i.id_serv, i.nro_c, i.zona
                        FROM final_instalacion i
                    ) instalacion
                ) instalaciones
                INNER JOIN
                (
                    SELECT c.nro_c, c.zona
                    FROM final_cliente c
                ) cliente ON cliente.zona = instalaciones.zona AND cliente.nro_c = instalaciones.nro_c
            )finales
            GROUP BY finales.id_serv, finales.nro_c, finales.zona
    LOOP
        UPDATE final_servicio SET cant_clientes = rec.cantidad WHERE id_serv = rec.id_serv;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CALL cargar_por_primera_vez();

SELECT *
FROM final_servicio;



CREATE OR REPLACE FUNCTION FN_ACTUALIZAR_CANT_CLIENTES_EN_SERVICIO()
RETURNS TRIGGER AS
$$
DECLARE

BEGIN

END;
$$
LANGUAGE plpgsql;

--      TABLAS                  INSERT                      UPDATE                        DELETE
--     servicio                   NO                          NO                            NO
--     cliente                    NO                          NO                            SI
--    instalacion                 SI                (id_servicio, nro_c, zona)              SI

CREATE OR REPLACE FUNCTION FN_ACTUALIZAR_CANT_CLIENTES_DESDE_CLIENTE()
RETURNS TRIGGER AS
$$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT instalacion.id_serv
        FROM (
                SELECT i.id_serv
                FROM final_instalacion i
                WHERE i.zona = NEW.zona AND i.nro_c = NEW.nro_c
             ) instalacion
    LOOP
        UPDATE final_servicio SET cant_clientes = (final_servicio.cant_clientes - 1) WHERE id_serv = rec.id_serv;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_ACTUALIZAR_CANT_CLIENTES_EN_SERVICIO_DESDE_CLIENTE
BEFORE DELETE
ON final_cliente
FOR EACH ROW
EXECUTE FUNCTION FN_ACTUALIZAR_CANT_CLIENTES_DESDE_CLIENTE();

CREATE OR REPLACE FUNCTION FN_ACTUALIZAR_CANT_CLIENTES_DESDE_INSTALACION()
RETURNS TRIGGER AS
$$
DECLARE
    rec RECORD;
BEGIN
    IF(tg_op = 'INSERT')THEN
        UPDATE final_servicio SET cant_clientes = (final_servicio.cant_clientes + 1) WHERE id_serv = NEW.id_serv;
    END IF;
    IF(tg_op = 'UPDATE') THEN
        IF(NEW.id_serv <> OLD.id_serv) THEN
            UPDATE final_servicio SET cant_clientes = (final_servicio.cant_clientes + 1) WHERE id_serv = NEW.id_serv;
            UPDATE final_servicio SET cant_clientes = (final_servicio.cant_clientes - 1) WHERE id_serv = OLD.id_serv;
        ELSE
            UPDATE final_servicio SET cant_clientes = (final_servicio.cant_clientes + 1) WHERE id_serv = NEW.id_serv;
        END IF;
    END IF;
    IF(tg_op = 'DELETE') THEN
        UPDATE final_servicio SET cant_clientes = (final_servicio.cant_clientes - 1) WHERE id_serv = OLD.id_serv;
    END IF;

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_ACTUALIZAR_CANT_CLIENTES_EN_SERVICIO_DESDE_INSTALACION
BEFORE INSERT OR UPDATE OF id_serv, nro_c, zona OR DELETE
ON FINAL_INSTALACION
FOR EACH ROW
EXECUTE FUNCTION FN_ACTUALIZAR_CANT_CLIENTES_DESDE_INSTALACION();


-- Dados los siguientes servicios requeridos en el esquema de peliculas, plantee el SQL que lo resuelve:
-- A: ¿Cuántos distribuidores han realizado exactamente 10 entregas?
-- B: Listar el/los distribuidor/es con la mayor cantidad de entregas realizadas,
-- indicando cual es dicha cantidad

-- A:
SELECT count(*)
FROM (
        SELECT 1
        FROM unc_esq_peliculas.entrega e
        GROUP BY e.id_distribuidor
        HAVING count(*) = 10
     ) entregas;

-- B:
-- Forma que utiliza una query que utiliza una funcion de ayuda
CREATE FUNCTION MAYOR_CANTIDAD_ENTREGAS()
RETURNS INT AS
$$
DECLARE
    mayor_cant INTEGER;
BEGIN
    SELECT count(*) CANT_ENTREGAS INTO mayor_cant
    FROM unc_esq_peliculas.entrega e
    GROUP BY e.id_distribuidor
    ORDER BY COUNT(*) DESC LIMIT 1;

    RETURN mayor_cant;
END;
$$
LANGUAGE plpgsql;

SELECT *, MAYOR_CANTIDAD_ENTREGAS() CANTIDAD
FROM unc_esq_peliculas.distribuidor d
WHERE id_distribuidor IN(
        SELECT e.id_distribuidor
        FROM unc_esq_peliculas.entrega e
        GROUP BY e.id_distribuidor
        HAVING count(*) = MAYOR_CANTIDAD_ENTREGAS()
    );



-- Forma con funcion que devuelve la tabla completa
CREATE OR REPLACE FUNCTION FN_MAYORES_DISTRIBUIDORES()
RETURNS TABLE(id_distribuidor numeric(5), nombre VARCHAR(80), direccion VARCHAR(120), telefono VARCHAR(20), tipo CHAR, cantidad INTEGER) AS
$$
DECLARE
    mayor_cant INTEGER;
    rec RECORD;
BEGIN
    SELECT count(*) CANT_ENTREGAS INTO mayor_cant
    FROM unc_esq_peliculas.entrega e
    GROUP BY e.id_distribuidor
    ORDER BY COUNT(*) DESC LIMIT 1;

    FOR rec IN
        SELECT *
        FROM unc_esq_peliculas.distribuidor d
        WHERE d.id_distribuidor IN(
            SELECT e.id_distribuidor
            FROM unc_esq_peliculas.entrega e
            GROUP BY e.id_distribuidor
            HAVING count(*) = mayor_cant)
    LOOP
        id_distribuidor := rec.id_distribuidor;
        nombre := rec.nombre;
        direccion := rec.direccion;
        telefono := rec.telefono;
        tipo := rec.tipo;
        cantidad := mayor_cant;
        RETURN NEXT;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM FN_MAYORES_DISTRIBUIDORES();


-- 3:

EXPLAIN VERBOSE SELECT *
FROM unc_esq_peliculas.pelicula p
JOIN unc_esq_peliculas.renglon_entrega re on p.codigo_pelicula = re.codigo_pelicula
JOIN unc_esq_peliculas.entrega e ON (e.nro_entrega = re.nro_entrega)
JOIN unc_esq_peliculas.video v ON e.id_video = v.id_video
JOIN unc_esq_peliculas.distribuidor d ON e.id_distribuidor = d.id_distribuidor
JOIN unc_esq_peliculas.nacional on d.id_distribuidor = nacional.id_distribuidor
WHERE d.tipo = 'N' AND idioma = 'Italiano';

EXPLAIN VERBOSE SELECT ren_en.nro_entrega, ren_en.codigo_pelicula, ren_en.cantidad
FROM unc_esq_peliculas.renglon_entrega ren_en
INNER JOIN
(
    SELECT pel.codigo_pelicula, pel.titulo, pel.idioma, pel.formato, pel.genero, pel.codigo_productora
    FROM unc_esq_peliculas.pelicula pel
    WHERE pel.idioma = 'Italiano'
) p ON ren_en.codigo_pelicula = p.codigo_pelicula
INNER JOIN
(
    SELECT entrega.nro_entrega, entrega.fecha_entrega, entrega.id_video, entrega.id_distribuidor
    FROM unc_esq_peliculas.entrega
    INNER JOIN
    (
        SELECT dis.id_distribuidor, dis.nombre, dis.direccion, dis.telefono, dis.tipo
        FROM unc_esq_peliculas.distribuidor dis
        WHERE dis.tipo = 'N'
    ) d ON entrega.id_distribuidor = d.id_distribuidor
    INNER JOIN(
        SELECT n.id_distribuidor, nro_inscripcion, encargado, id_distrib_mayorista
        FROM unc_esq_peliculas.nacional n
    ) n ON entrega.id_distribuidor = n.id_distribuidor
) e ON ren_en.nro_entrega = e.nro_entrega
INNER JOIN
(
    SELECT v.id_video, v.razon_social, v.direccion, v.telefono, v.propietario
    FROM unc_esq_peliculas.video v
) vid ON vid.id_video = e.id_video;

-- 5: VISTAS
-- A: Datos los clientes dados de alta en el año actual que poseen unicamente instalaciones de servicios de vigilancia.
-- B: Datos completos asociados a cada servicio, incluyendo su situacion o su caracteristica, segun sea su tipo.

--A:
SELECT *
FROM V_CLIENTES_NUEVOS_SOLO_VIGILANCIA;


-- Es posible actualizarla en pgsql ya que el from principal solo selecciona 1 tabla,
-- además que en el select principal no se utilizan funciones ventana ni subconsultas.
--
CREATE OR REPLACE VIEW V_CLIENTES_NUEVOS_SOLO_VIGILANCIA AS
    SELECT c.zona, nro_c, apellido_nombre, ciudad
    FROM final_cliente c
    WHERE extract('YEAR' FROM c.fecha_alta) = extract('YEAR' FROM NOW()) AND
            EXISTS(
                SELECT 1
                FROM final_instalacion i
                WHERE i.nro_c = c.nro_c AND i.zona = c.zona AND
                      extract('YEAR' FROM i.fecha_instalacion) = extract('YEAR' FROM NOW()) AND
                      NOT EXISTS(
                            SELECT 1
                            FROM final_servicio s
                            WHERE i.id_serv = s.id_serv AND s.tipo_serv = 'M'
                      ) AND
                      EXISTS(
                            SELECT 1
                            FROM final_servicio s
                            WHERE i.id_serv = s.id_serv AND s.tipo_serv = 'V'
                      )
            );

CREATE OR REPLACE VIEW V_DATOS_SERVICIOS_MONITOREO AS
    SELECT s.*, m.caracteristica
    FROM final_servicio s
    JOIN final_serv_monitoreo m ON s.id_serv = m.id_serv;

CREATE OR REPLACE TRIGGER TG_V_DATOS_SERVICIOS_MONITOREO
INSTEAD OF INSERT OR UPDATE OR DELETE
ON V_DATOS_SERVICIOS_MONITOREO
FOR EACH ROW
EXECUTE FUNCTION FN_ACTUALIZAR_V_DATOS_SERVICIOS_MONITOREO();

CREATE OR REPLACE FUNCTION FN_ACTUALIZAR_V_DATOS_SERVICIOS_MONITOREO()
RETURNS TRIGGER AS
$$
BEGIN
    IF(TG_OP = 'INSERT')THEN
        INSERT INTO final_servicio(ID_SERV, NOMBRE_SERV, ANIO_COMIENZO, ANIO_FIN, TIPO_SERV)
        VALUES (NEW.id_serv, NEW.nombre_serv, NEW.anio_comienzo, NEW.anio_fin, NEW.tipo_serv);

        INSERT INTO final_serv_monitoreo(id_serv, caracteristica) VALUES (NEW.id_serv, NEW.caracteristica);
    ELSEIF(tg_op = 'UPDATE')THEN
        UPDATE final_servicio SET id_serv = NEW.id_serv, nombre_serv = NEW.nombre_serv, anio_comienzo = NEW.anio_comienzo, anio_fin = NEW.anio_fin, tipo_serv = NEW.tipo_serv WHERE id_serv = NEW.id_serv;
        UPDATE final_serv_monitoreo SET id_serv = NEW.id_serv, caracteristica = NEW.caracteristica WHERE id_serv = NEW.id_serv;
    ELSE
        DELETE FROM final_servicio WHERE id_serv = NEW.id_serv;
    END IF;

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM final_serv_monitoreo;

CREATE OR REPLACE VIEW V_DATOS_SERVICIOS_VIGILANCIA AS
    SELECT s.*, v.situacion
    FROM final_servicio s
    JOIN final_serv_vigilancia v ON s.id_serv = v.id_serv;


CREATE OR REPLACE TRIGGER TG_V_DATOS_SERVICIOS_VIGILANCIA
INSTEAD OF INSERT OR UPDATE OR DELETE
ON V_DATOS_SERVICIOS_VIGILANCIA
FOR EACH ROW
EXECUTE FUNCTION FN_ACTUALIZAR_V_DATOS_SERVICIOS_VIGILANCIA();

CREATE OR REPLACE FUNCTION FN_ACTUALIZAR_V_DATOS_SERVICIOS_VIGILANCIA()
RETURNS TRIGGER AS
$$
BEGIN
    IF(TG_OP = 'INSERT')THEN
        INSERT INTO final_servicio(ID_SERV, NOMBRE_SERV, ANIO_COMIENZO, ANIO_FIN, TIPO_SERV)
        VALUES (NEW.id_serv, NEW.nombre_serv, NEW.anio_comienzo, NEW.anio_fin, NEW.tipo_serv);

        INSERT INTO final_serv_vigilancia(id_serv, situacion) VALUES (NEW.id_serv, NEW.situacion);
    ELSEIF(tg_op = 'UPDATE')THEN
        UPDATE final_servicio SET id_serv = NEW.id_serv, nombre_serv = NEW.nombre_serv, anio_comienzo = NEW.anio_comienzo, anio_fin = NEW.anio_fin, tipo_serv = NEW.tipo_serv WHERE id_serv = NEW.id_serv;
        UPDATE final_serv_vigilancia SET id_serv = NEW.id_serv, situacion = NEW.situacion WHERE id_serv = NEW.id_serv;
    ELSE
        DELETE FROM final_servicio WHERE id_serv = NEW.id_serv;
    END IF;

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

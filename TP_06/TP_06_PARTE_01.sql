SET SEARCH_PATH = unc_251340;

-- 1: Implemente de manera procedural las restricciones que no pudo realizar de manera declarativa en
-- el ejercicio 3 del Práctico 5 Parte 2.
-- Ayuda: Restricciones que no se pudieron realizar de manera declarativa: C y D.

-- EJERCICIO 1:C: Cada palabra clave puede aparecer como máximo en 5 artículos.
--          TABLA        INSERT          UPDATE          DELETE
--          CONTIENE        X          id_articulo         -

CREATE OR REPLACE FUNCTION FN_CH_PALABRA_CLAVE_MAXIMO_EN_5_ARTICULOS()
RETURNS TRIGGER AS
$$
DECLARE
    cant_libros_donde_aparece INTEGER;
BEGIN
    SELECT count(*) INTO cant_libros_donde_aparece
    FROM p5p2e3_contiene c
    WHERE c.cod_palabra = NEW.cod_palabra AND c.idioma = NEW.idioma
    GROUP BY c.cod_palabra, c.idioma;

    IF(cant_libros_donde_aparece > 5) THEN
        RAISE EXCEPTION 'La palabra con cod_palabra = % y idioma = % ya aparece en 5 articulos diferentes!', NEW.cod_palabra, NEW.idioma;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO_1_C
AFTER INSERT OR UPDATE OF idioma, cod_palabra
ON p5p2e3_contiene
FOR EACH ROW
EXECUTE FUNCTION FN_CH_PALABRA_CLAVE_MAXIMO_EN_5_ARTICULOS();


-- EJERCICIO 1 D: Sólo los autores argentinos pueden publicar artículos que contengan más de 10 palabras
-- claves, pero con un tope de 15 palabras, el resto de los autores sólo pueden publicar
-- artículos que contengan hasta 10 palabras claves.

--          TABLA        INSERT          UPDATE          DELETE
--          ARTICULO        -         NACIONALIDAD         -
--          CONTIENE        X          id_articulo         -

CREATE OR REPLACE FUNCTION FN_CH_TOPE_PALABRAS_AUTORES()
RETURNS TRIGGER AS
$$
DECLARE
    cant_palabras INTEGER;
    tope_palabras_para_argentino CONSTANT INTEGER := 10;
BEGIN
    SELECT count(*) INTO cant_palabras
    FROM p5p2e3_contiene c
    WHERE c.id_articulo = NEW.id_articulo
    GROUP BY id_articulo;

    IF(cant_palabras > tope_palabras_para_argentino) THEN
        RAISE EXCEPTION 'Los autores que no son argentinos pueden tener hasta 10 palabras claves por articulo!';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO_1_D_AUTORES
AFTER UPDATE OF nacionalidad
ON p5p2e3_articulo
FOR EACH ROW
WHEN(NEW.nacionalidad NOT ILIKE 'argentina')
EXECUTE FUNCTION FN_CH_TOPE_PALABRAS_AUTORES();

CREATE OR REPLACE FUNCTION FN_CH_TOPE_PALABRAS_AUTORES_ARGENTINOS()
RETURNS TRIGGER AS
$$
DECLARE
    cant_palabras_en_articulo INTEGER;
    tope_argentinos CONSTANT INTEGER := 15;
    tope_general CONSTANT INTEGER := 10;
BEGIN
    SELECT count(*) INTO cant_palabras_en_articulo
    FROM p5p2e3_contiene c
    WHERE id_articulo = NEW.id_articulo
    ORDER BY c.id_articulo;

    IF((SELECT nacionalidad FROM p5p2e3_articulo WHERE id_articulo = NEW.id_articulo) ILIKE 'argentina')THEN
        IF(cant_palabras_en_articulo > tope_argentinos) THEN
            RAISE EXCEPTION 'Los autores argentinos pueden publicar articulos con un maximo de % palabras claves!', tope_argentinos;
        END IF;
        RETURN NEW;
    END IF;

    IF(cant_palabras_en_articulo > tope_general) THEN
        RAISE EXCEPTION 'Los autores que no son argentinos pueden publicar articulos con un maximo de % palabras claves!', tope_general;
    END IF;

    RETURN NEW;
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO_1_D_AUTORES_ARGENTINOS
AFTER INSERT OR UPDATE OF id_articulo
ON p5p2e3_contiene
EXECUTE FUNCTION FN_CH_TOPE_PALABRAS_AUTORES_ARGENTINOS();

-- Ejercicio 2
-- Implemente de manera procedural las restricciones que no pudo realizar de manera declarativa en
-- el ejercicio 4 del Práctico 5 Parte 2.
-- Ayuda: las restricciones que no se pudieron realizar de manera declarativa fueron las de los items
-- B, D, E.

-- B: Cada imagen no debe tener más de 5 procesamientos.
-- Forma declarativa:
ALTER TABLE p5p2e4_procesamiento ADD CONSTRAINT CH_TP_06_PARTE_01_EJERCICIO_2_B
CHECK(NOT EXISTS(SELECT 1
FROM p5p2e4_procesamiento p
GROUP BY p.id_paciente, p.id_imagen
HAVING count(*) > 5));

--      TABLA                  INSERT               UPDATE                DELETE
--   procesamiento               SI         id_paciente | id_imagen           -
CREATE OR REPLACE FUNCTION FN_CH_PROCESAMIENTOS_VALIDOS_EN_IMAGEN_MEDICA()
RETURNS TRIGGER AS
$$
DECLARE
    tope_procesamientos CONSTANT INT := 4;
    total_procesamientos INT;
BEGIN
    SELECT count(*) INTO total_procesamientos
    FROM p5p2e4_procesamiento p
    WHERE p.id_imagen = NEW.id_imagen AND p.id_paciente = NEW.id_paciente
    ORDER BY p.id_paciente, p.id_imagen;

    IF(total_procesamientos > tope_procesamientos) THEN
        RAISE EXCEPTION 'La imagen medica ya fue procesada % veces, ya alcanzo el maximo permitido!', (tope_procesamientos + 1);
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO2_B
BEFORE INSERT OR UPDATE OF id_paciente, id_imagen
ON p5p2e4_procesamiento
FOR EACH ROW
EXECUTE FUNCTION FN_CH_PROCESAMIENTOS_VALIDOS_EN_IMAGEN_MEDICA();

-- C: Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una
-- indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen y controle
-- que la segunda no sea menor que la primera.

--      TABLA                  INSERT               UPDATE                      DELETE
--   imagen_medica               -                   fecha                        -
--   procesamiento               SI         fecha | id_imagen | id_paciente       -

CREATE OR REPLACE FUNCTION FN_fecha_creacion_imagen_menor_a_procesamientos_desde_img_m()
RETURNS TRIGGER AS
$$
DECLARE
    rec_procesamiento RECORD;
BEGIN
    FOR rec_procesamiento IN  SELECT *
                FROM p5p2e4_procesamiento p
                WHERE p.id_paciente = NEW.id_paciente AND p.id_imagen = NEW.id_imagen
    LOOP
        IF(rec_procesamiento.fecha < NEW.fecha) THEN
            RAISE EXCEPTION 'La nueva fecha en la imagen medica es anterior al procesamiento: id_imagen (%), id_paciente (%), id_algoritmo (%), nro_secuencia (%) !', rec_procesamiento.id_imagen, rec_procesamiento.id_paciente, rec_procesamiento.id_algoritmo, rec_procesamiento.nro_secuencia;
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO2_C_DESDE_IMAGEN_MEDICA
BEFORE UPDATE OF fecha
ON p5p2e4_imagen_medica
FOR EACH ROW
EXECUTE FUNCTION FN_fecha_creacion_imagen_menor_a_procesamientos_desde_img_m();



CREATE OR REPLACE FUNCTION FN_fecha_creacion_imagen_menor_a_procesamientos_desde_proce()
RETURNS TRIGGER AS
$$
DECLARE
    fecha_imagen_medica p5p2e4_imagen_medica.fecha%type;
BEGIN
    SELECT img_m.fecha
    FROM p5p2e4_imagen_medica img_m
    WHERE img_m.id_paciente = NEW.id_paciente AND img_m.id_imagen = NEW.id_imagen;

    IF(fecha_imagen_medica > NEW.fecha) THEN
        RAISE EXCEPTION 'La fecha del procesamiento no puede ser menor que la fecha en que se realizo la imagen medica!';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO2_C_DESDE_PROCESAMIENTO
AFTER INSERT OR UPDATE OF fecha
ON p5p2e4_procesamiento
FOR EACH ROW
EXECUTE FUNCTION FN_fecha_creacion_imagen_menor_a_procesamientos_desde_proce();


-- D: Cada paciente sólo puede realizar dos FLUOROSCOPIA anuales.

--      TABLA                  INSERT               UPDATE                      DELETE
--   imagen_medica              SI         fecha | modalidad | id_paciente        -

CREATE OR REPLACE FUNCTION FN_CH_2_FLUOROSCOPIAS_ANUALES_X_PACIENTE()
RETURNS TRIGGER AS
$$
DECLARE
    cant_fluoroscopias_realizadas_en_dicho_anio INT;
    tope_fluoroscopias_anuales CONSTANT INT := 2;
BEGIN
    SELECT count(*) INTO cant_fluoroscopias_realizadas_en_dicho_anio
    FROM p5p2e4_imagen_medica img_m
    WHERE id_paciente = NEW.id_paciente AND img_m.modalidad = 'FLUOROSCOPIA' AND extract('YEAR' FROM img_m.fecha) = extract('YEAR' FROM NEW.fecha)
    GROUP BY id_paciente;

    IF(cant_fluoroscopias_realizadas_en_dicho_anio > tope_fluoroscopias_anuales) THEN
        RAISE EXCEPTION 'El paciente con id % ya se realizo 2 fluoroscopias en el anio %, alcanzo el tope anual permitido!', NEW.id_paciente, extract('YEAR' FROM NEW.fecha);
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO2_D
BEFORE INSERT OR UPDATE OF fecha, modalidad, id_paciente
ON p5p2e4_imagen_medica
FOR EACH ROW
WHEN (NEW.modalidad = 'FLUOROSCOPIA')
EXECUTE FUNCTION FN_CH_2_FLUOROSCOPIAS_ANUALES_X_PACIENTE();

-- E: No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA

--      TABLA                  INSERT               UPDATE                      DELETE
--   imagen_medica               NO               modalidad                       -
--   procesamiento               SI    id_imagen | id_paciente | id_algoritmo     -
--     algoritmo                 NO             costo_computacional               -

CREATE OR REPLACE FUNCTION FN_CH_FLUOROSCOPIA_SIN_COSTO_COMPUTACIONAL_O_N_DESDE_IMG_M()
RETURNS TRIGGER AS
$$
DECLARE
    rec RECORD;
BEGIN
    IF (EXISTS(
        SELECT 1
        FROM (
            SELECT pro.id_paciente, pro.id_imagen, pro.id_algoritmo, pro.nro_secuencia
            FROM p5p2e4_procesamiento pro
            WHERE pro.id_paciente = NEW.id_paciente AND pro.id_imagen = NEW.id_imagen
            AND EXISTS(
                SELECT 1
                FROM p5p2e4_algoritmo alg
                WHERE alg.id_algoritmo = pro.id_algoritmo AND alg.costo_computacional = 'O(n)'
            )
         ) procesamiento
    ))THEN
        RAISE EXCEPTION 'Hubo un error!';
    END IF;

    RETURN NEW;

    SELECT * INTO rec
    FROM (
            SELECT pro.id_paciente, pro.id_imagen, pro.id_algoritmo, pro.nro_secuencia
            FROM p5p2e4_procesamiento pro
            WHERE pro.id_paciente = NEW.id_paciente AND pro.id_imagen = NEW.id_imagen
         ) procesamiento JOIN (
            SELECT alg.id_algoritmo
            FROM p5p2e4_algoritmo alg
            WHERE alg.costo_computacional = 'O(n)'
        ) algoritmo ON procesamiento.id_algoritmo = algoritmo.id_algoritmo;

    IF rec IS NOT NULL THEN
        RAISE EXCEPTION 'Hubo un error!';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO2_E_IMAGEN_MEDICA
BEFORE UPDATE OF modalidad
ON p5p2e4_imagen_medica
FOR EACH ROW
WHEN(modalidad = 'FLUOROSCOPIA')
EXECUTE FUNCTION FN_CH_FLUOROSCOPIA_SIN_COSTO_COMPUTACIONAL_O_N_DESDE_IMG_M();

CREATE OR REPLACE FUNCTION FN_CH_FLUOROSCOPIA_SIN_COSTO_COMPUTACIONAL_O_N_DESDE_ALGOR()
RETURNS TRIGGER AS
$$
DECLARE
    rec RECORD;
BEGIN
    IF (EXISTS(
        SELECT 1
        FROM (
            SELECT pro.id_paciente, pro.id_imagen, pro.id_algoritmo, pro.nro_secuencia
            FROM p5p2e4_procesamiento pro
            WHERE pro.id_algoritmo = pro.id_algoritmo
            AND EXISTS(
                SELECT 1
                FROM p5p2e4_imagen_medica img_m
                WHERE img_m.id_paciente = pro.id_paciente AND img_m.id_imagen = pro.id_imagen AND img_m.modalidad = 'FLUOROSCOPIA'
            )
         ) tabla_resultante
    ))THEN
        RAISE EXCEPTION 'Hubo un error!';
    END IF;

    RETURN NEW;

    SELECT * INTO rec
    FROM (
            SELECT pro.id_paciente, pro.id_imagen, pro.id_algoritmo, pro.nro_secuencia
            FROM p5p2e4_procesamiento pro
            WHERE pro.id_algoritmo = NEW.id_algoritmo
         ) procesamiento JOIN (
            SELECT img.id_imagen, IMG.id_paciente
            FROM p5p2e4_imagen_medica img
            WHERE img.modalidad = 'FLUOROSCOPIA'
        ) imagen_medica ON (procesamiento.id_imagen = imagen_medica.id_imagen AND
                            procesamiento.id_paciente = imagen_medica.id_paciente);

    IF rec IS NOT NULL THEN
        RAISE EXCEPTION 'Hubo un error!';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO2_E_ALGORITMO
BEFORE UPDATE OF costo_computacional
ON p5p2e4_algoritmo
FOR EACH ROW
WHEN (NEW.costo_computacional = 'O(n)')
EXECUTE FUNCTION FN_CH_FLUOROSCOPIA_SIN_COSTO_COMPUTACIONAL_O_N_DESDE_ALGOR();

CREATE OR REPLACE FUNCTION FN_CH_FLUOROSCOPIA_SIN_COSTO_COMPUTACIONAL_O_N_DESDE_PROCES()
RETURNS TRIGGER AS
$$
DECLARE
    const_modalidad CONSTANT VARCHAR := 'FLUOROSCOPIA';
    const_costo_computacional CONSTANT VARCHAR := 'O(n)';
    v_modalidad p5p2e4_imagen_medica.modalidad%type;
    v_costo_computacional p5p2e4_algoritmo.costo_computacional%type;
BEGIN
    SELECT alg.costo_computacional INTO v_costo_computacional
    FROM p5p2e4_algoritmo alg
    WHERE alg.id_algoritmo = NEW.id_algoritmo;

    SELECT img_m.modalidad INTO v_modalidad
    FROM p5p2e4_imagen_medica img_m
    WHERE img_m.id_paciente = NEW.id_paciente AND img_m.id_imagen = NEW.id_imagen;

    IF(v_costo_computacional = const_costo_computacional AND v_modalidad = const_modalidad) THEN
        RAISE EXCEPTION 'Las imagenes medicas con modalidad "%" no pueden realizarse con algoritmos de costo computacional "%"!', const_modalidad, const_costo_computacional;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO2_E_PROCESAMIENTO
AFTER INSERT OR UPDATE OF id_imagen, id_paciente, id_algoritmo
ON p5p2e4_procesamiento
FOR EACH ROW
EXECUTE FUNCTION FN_CH_FLUOROSCOPIA_SIN_COSTO_COMPUTACIONAL_O_N_DESDE_PROCES();


-- EJERCICIO 3:
-- Implemente de manera procedural las restricciones que no pudo realizar de
-- manera declarativa en el ejercicio 5 del Práctico 5 Parte 2;
-- Ayuda: Restricciones que no se pudieron realizar de manera declarativa: B, C, D;

-- B: Los descuentos realizados en fechas de liquidación deben superar el 30%.
--      TABLA               INSERT              UPDATE              DELETE
--      venta                 SI           descuento | fecha
--    fecha_liq               NO         dia_liq | mes_liq | dias     SI

CREATE OR REPLACE FUNCTION FN_CH_DESCUENTO_EN_FECHA_LIQ_MAYOR_DESDE_VENTA()
RETURNS TRIGGER AS
$$
DECLARE
    rec RECORD;
    anio_descuento CONSTANT INTEGER := extract('YEAR' FROM NEW.fecha);
BEGIN
    FOR rec IN (
        SELECT *
        FROM p5p1e5_fecha_liq
    )LOOP
        IF (NEW.fecha BETWEEN CONCAT(EXTRACT('YEAR' FROM NEW.fecha), '-', rec.mes_liq, '-', rec.dia_liq) AND CONCAT(EXTRACT('YEAR' FROM NEW.fecha), '-', rec.mes_liq, '-', rec.dia_liq)) THEN
            RETURN NEW;
        END IF;
    END LOOP;

    RAISE EXCEPTION 'La fecha ingresada en la tabla VENTA no se encuentra en fecha de ';
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO3_B
BEFORE INSERT OR UPDATE OF descuento, fecha
ON p5p1e5_venta
FOR EACH ROW
WHEN (NEW.descuento <> (0.0)::decimal)
EXECUTE FUNCTION FN_CH_DESCUENTO_EN_FECHA_LIQ_MAYOR_DESDE_VENTA();

-- C. Las liquidaciones de Julio y Diciembre no deben superar los 5 días.
-- D. Las prendas de categoría ‘oferta’ no tienen descuentos.




-- Ejercicio 4
-- a) Copie en su esquema la estructura de la tabla PELICULA del esquema unc_peliculas

DROP TABLE IF EXISTS TP_06_PARTE_01_Pelicula;

CREATE TABLE TP_06_PARTE_01_Pelicula AS
SELECT * FROM unc_esq_peliculas.pelicula;

-- b) Cree la tabla ESTADISTICA con la siguiente sentencia:

CREATE TABLE TP_06_PARTE_01_Estadistica AS
SELECT genero, COUNT(*) total_peliculas, COUNT(distinct idioma) cantidad_idiomas
FROM TP_06_PARTE_01_Pelicula
GROUP BY genero;

-- c) Cree un trigger que cada vez que se realice una modificación en la tabla película
-- (la creada en su esquema) tiene que actualizar la tabla estadística.

-- No se olvide de identificar:
-- i) la granularidad del trigger.
-- ii) Eventos ante los cuales se debe disparar.
-- iii) Analice si conviene modificar por cada operación de actualización o reconstruirla de
-- cero.

-- Actualizando  FOR STATEMENT

CREATE OR REPLACE FUNCTION FN_ACTUALIZAR_TABLA_ESTADISTICAS_PELICULAS()
RETURNS TRIGGER AS
$$
BEGIN
    -- Borramos todos los datos
    TRUNCATE TP_06_PARTE_01_Estadistica;

    -- Volvemos a poblar la tabla con los nuevos datos
    INSERT INTO TP_06_PARTE_01_Estadistica
    SELECT genero, COUNT(*) total_peliculas, COUNT(distinct idioma) cantidad_idiomas
    FROM TP_06_PARTE_01_Pelicula p
    GROUP BY genero;

    IF(TG_OP = 'DELETE')THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER TG_TP_06_PARTE_01_EJERCICIO_4
AFTER INSERT OR UPDATE OF idioma, genero OR DELETE
ON tp_06_parte_01_pelicula
FOR EACH STATEMENT
EXECUTE FUNCTION FN_ACTUALIZAR_TABLA_ESTADISTICAS_PELICULAS();

select *
from TP_06_PARTE_01_Pelicula;

DELETE FROM tp_06_parte_01_pelicula WHERE codigo_pelicula = 1;
INSERT INTO tp_06_parte_01_pelicula (codigo_pelicula, titulo, idioma, formato, genero, codigo_productora) VALUES (1, 'Dushanbe 1', 'Indonesio', 'Formato 2', 'Animación', '531637');

SELECT *
FROM TP_06_PARTE_01_Estadistica;


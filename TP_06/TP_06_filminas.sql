SET SEARCH_PATH = unc_251340;

-- Sintaxis de un trigger:

-- CREATE TRIGGER nombre_trigger
-- BEFORE | AFTER | INSTEAD OF
-- INSERT | UPDATE (OF) | DELETE | TRUNCATE         Este es el evento
-- ON nombre_tabla
-- FOR [EACH] {ROW | STATEMENT}]        GRANULADIDAD
-- [WHEN (CONDICION)]
-- EXCECUTE PROCEDURE | FUNCTION funcion_especifica();


-- CREATE [OR REPLACE] FUNCTION nombre_funcion(lista_parametros)
-- RETURNS tipo_retorno AS $$
-- DECLARE
--      -- Declaracion de variables
-- BEGIN
--      -- Logica
-- END;
-- $$ language plpgsql;


-- Algunas otras (hay muchas más) variables especiales son:
--
-- TG_NAME Tipo de dato text; variable que contiene el nombre del
-- trigger actualmente disparado.
--
-- TG_WHEN Tipo de dato text; una cadena conteniendo el string
-- BEFORE o AFTER dependiendo de la definición del trigger.
--
-- TG_LEVEL Tipo de dato text; una cadena conteniendo el string ROW
-- o STATEMENT dependiendo de la definición del trigger.
--
-- TG_OP Tipo de dato text; una cadena conteniendo el string INSERT,
-- UPDATE o DELETE indicando por cuál operación se disparó el trigger.
--
-- TG_TABLE_NAME Tipo de dato text; variable que contiene el
-- nombre de la tabla que disparó el trigger


-- Ejercicio 3 - TP 3 - Los artículos pueden tener como máximo 15 palabras claves.
ALTER TABLE p5p2e3_contiene ADD CONSTRAINT CH_asdasda
CHECK(NOT EXISTS(SELECT c.id_articulo, count(*) cantidad_palabras_claves_diferentes_utilizadas
FROM p5p2e3_contiene c
GROUP BY id_articulo
HAVING count(*) > 15));


--      TABLA / EVENTO       |       INSERT      |       UPDATE      |       DELETE
--      p5p2e3_contiene                x               id_articulo             -

DROP FUNCTION IF EXISTS FUNCTION_FILMINA_TP06_EJ3;
CREATE OR REPLACE FUNCTION FUNCTION_FILMINA_TP06_EJ3()
RETURNS TRIGGER AS
$$
DECLARE
    cant_palabras INTEGER;
BEGIN
    SELECT count(*) INTO cant_palabras
    FROM p5p2e3_contiene c
    WHERE c.id_articulo = NEW.id_articulo;

    IF(cant_palabras > 15) THEN
        RAISE EXCEPTION 'Cada articulo puede utilizar como maximo 15 palabras claves! El articulo con id "%" ya cuenta con 15.', NEW.id_articulo;
    END IF;

    RETURN NEW;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS TG_FILMINA_TP06_EJ3 ON p5p2e3_contiene;
CREATE TRIGGER TG_FILMINA_TP06_EJ3
AFTER INSERT OR UPDATE OF id_articulo
ON p5p2e3_contiene
FOR EACH ROW EXECUTE FUNCTION FUNCTION_FILMINA_TP06_EJ3();

-- Ejercicio 4 - TP 3
-- Sólo se pueden publicar artículos argentinos que contengan hasta 10 palabras claves.

--      TABLA / EVENTO       |       INSERT      |       UPDATE      |       DELETE
--      p5p2e3_contiene                x               id_artiulo               -
--      p5p2e3_articulo                -              nacionalidad              -

CREATE OR REPLACE FUNCTION FUNCTION_FILMINA_TP06_EJ4_CONTIENE()
RETURNS TRIGGER AS
$$
BEGIN
    IF((SELECT count(*) FROM p5p2e3_contiene WHERE id_articulo = NEW.id_articulo) > 9) THEN
        RAISE EXCEPTION 'Los articulos argentinos solo pueden tener hasta 10 palabras claves!';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER TG_FILMINA_TP06_EJ4_CONTIENE
BEFORE INSERT OR UPDATE OF id_articulo
ON p5p2e3_contiene
FOR EACH ROW
EXECUTE FUNCTION FUNCTION_FILMINA_TP06_EJ4_CONTIENE();

DROP FUNCTION FUNCTION_FILMINA_TP06_EJ4_ARTICULO;
CREATE OR REPLACE FUNCTION FUNCTION_FILMINA_TP06_EJ4_ARTICULO()
RETURNS TRIGGER AS
$$
DECLARE
    cant INTEGER;
    var_nacional p5p2e3_articulo.nacionalidad%type;
BEGIN
    -- Primero obtenemos la nacionalidad del articulo nuevo
    SELECT a.nacionalidad INTO var_nacional
    FROM p5p2e3_articulo a
    WHERE id_articulo = NEW.id_articulo;

    -- Validamos si la nacionalidad es o no argentina
    IF(var_nacional = 'ARGENTINA') THEN
        -- En caso de serlo, seleccionamos la cantidad de palabras que posee ese articulo
        INSERT INTO cant
        SELECT count(*)
        FROM p5p2e3_contiene
        WHERE id_articulo = NEW.id_articulo;

        IF(cant > 9) THEN
            RAISE EXCEPTION 'Los articulos argentinos solo pueden tener un maximo de 10 palabras claves';
        END IF;
    END IF;
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TG_FILMINA_TP06_EJ4_CONTIENE_ARTICULO
BEFORE UPDATE OF nacionalidad
ON p5p2e3_articulo
FOR EACH ROW
WHEN (NEW.nacionalidad = 'ARGENTINO')
EXECUTE FUNCTION FUNCTION_FILMINA_TP06_EJ4_ARTICULO();


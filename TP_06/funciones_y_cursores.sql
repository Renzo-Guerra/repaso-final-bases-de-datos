SET SEARCH_PATH = unc_251340;

CREATE FUNCTION FN_asd(qqq INTEGER) RETURNS INTEGER AS
$$
DECLARE
    var1 ALIAS FOR qqq;
    var1 ALIAS FOR $1;
    var_3_const CONSTANT INTEGER := 1;
    rec RECORD;
    columna esq_pel_tarea.id_tarea%type;
    fila esq_pel_tarea%rowtype;
BEGIN

END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION FUNCTION_SUMADOR(INTEGER) RETURNS INTEGER AS
$$
DECLARE
    num ALIAS FOR $1;
BEGIN
    RETURN num + 1;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION FUNCTION_VOLUNTARIOS_CON_NRO_VOLUNTARIO_MULTIPLO_DE(INTEGER)
RETURNS TABLE(nro_voluntario numeric, apellido VARCHAR, nombre VARCHAR) AS
$$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN(
        SELECT *
        FROM esq_vol_voluntario v
        WHERE v.nro_voluntario % $1 = 0
        ORDER BY v.nro_voluntario)
    LOOP
        RAISE NOTICE '%, %, %', rec.nro_voluntario, rec.apellido, rec.nombre;
        nro_voluntario := rec.nro_voluntario;
        apellido := rec.apellido;
        nombre := rec.nombre;
        RETURN NEXT;
    END LOOP;
END;
$$
LANGUAGE PLPGSQL;

SELECT *
FROM function_voluntarios_con_nro_voluntario_multiplo_de(2);

CREATE OR REPLACE FUNCTION FUNCTION_ALGO()
RETURNS SETOF RECORD AS
$$
DECLARE
    cursor1 REFCURSOR;
    cursor2 CURSOR FOR select * from esq_vol_voluntario;
    rec RECORD;
BEGIN
    OPEN cursor2;
    LOOP
        FETCH NEXT FROM cursor2 INTO rec;
        EXIT WHEN NOT FOUND;

    END LOOP;

END;
$$
LANGUAGE PLPGSQL;

DO
$$
DECLARE
    rec RECORD;
    cursor_vol CURSOR FOR SELECT * FROM esq_vol_voluntario v ORDER BY v.nro_voluntario;
BEGIN
    FOR rec IN cursor_vol
    LOOP
        RAISE NOTICE '%, %', rec.nombre, rec.apellido;
    END LOOP;
END;
$$
LANGUAGE PLPGSQL;
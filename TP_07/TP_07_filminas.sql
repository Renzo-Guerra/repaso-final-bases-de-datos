SET SEARCH_PATH = unc_251340;

-- No se puede eliminar vistas las cuales estan siendo utilizadas en otras vistas!
DROP VIEW IF EXISTS view_empleados_con_sueldo_mayor_a_la_media_de_su_departamento;

-- Para poder eliminar vistas utilizadas en otras vistas, hay que proporcionar el CASCADE!
-- De esta forma eliminaremos no solo la vista, sino las demas vistas que la utilicen
DROP VIEW IF EXISTS view_empleados_con_sueldo_mayor_a_la_media_de_su_departamento CASCADE;

CREATE OR REPLACE VIEW view_empleados_con_sueldo_mayor_a_la_media_de_su_departamento AS
    SELECT emp.*, sueldo_dep.sueldo_promedio_en_su_departamento
    FROM (
            SELECT e.id_empleado, e.nombre, e.apellido, e.telefono, e.id_departamento, e.id_distribuidor, e.sueldo
            FROM esq_pel_empleado e
         ) emp
    JOIN (
            SELECT em.id_departamento, em.id_distribuidor, AVG(COALESCE(em.sueldo, 0)) sueldo_promedio_en_su_departamento
            FROM esq_pel_empleado em
            GROUP BY em.id_departamento, em.id_distribuidor
        ) sueldo_dep ON emp.id_departamento = sueldo_dep.id_departamento AND emp.id_distribuidor = sueldo_dep.id_distribuidor
    WHERE emp.sueldo > sueldo_dep.sueldo_promedio_en_su_departamento;

CREATE OR REPLACE VIEW view_empleados_por_expulsar AS
    SELECT *, ((sueldo * 100 / empleados.sueldo_promedio_en_su_departamento) - 100) porcentaje_de_sueldo_que_rebasa_el_promedio
    FROM view_empleados_con_sueldo_mayor_a_la_media_de_su_departamento empleados
    ORDER BY ((sueldo * 100 / empleados.sueldo_promedio_en_su_departamento) - 100) DESC LIMIT 10;

SELECT *
FROM view_empleados_por_expulsar;

SELECT *
FROM view_empleados_con_sueldo_mayor_a_la_media_de_su_departamento;

-- Vistas y sus actualizaciones:
-- Cuando se actualizan los registros de una tabla, los cambios
-- se reflejan automáticamente sobre la/s vista/s definida/s a partir
-- de ella, dado que la vista está definida como una consulta sobre
-- las tablas base o otra vista.
--
-- Las vistas que hemos visto hasta ahora NO mantienen copias de
-- los datos. Si hay actualizaciones en los datos de las tablas que está
-- utilizando alguna vista, el SGBD debe “actualizar” las vistas (los
-- registros se generan al consultar la vista).
--
-- Sí existe un tipo de vista que mantienen copias de los datos, se
-- las denomina VISTAS MATERIALIZADAS.
-- El SGBD debe mantener automáticamente actualizados los datos
-- de las vistas materializadas.
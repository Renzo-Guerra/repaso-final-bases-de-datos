SET SEARCH_PATH = unc_251340;

-- Seleccionar los empleados que ganen mas dinero que el promedio en su area de tarea!
EXPLAIN ANALYSE SELECT emp.id_empleado, emp.id_departamento, emp.id_distribuidor, emp.id_tarea, emp.sueldo
FROM unc_esq_peliculas.empleado emp
WHERE emp.sueldo > (
        SELECT AVG(COALESCE(dep.sueldo, 0))
        FROM unc_esq_peliculas.empleado dep
        WHERE dep.id_distribuidor = emp.id_distribuidor AND
              dep.id_departamento = emp.id_departamento
        GROUP BY dep.id_distribuidor, dep.id_departamento)
ORDER BY emp.id_empleado;

EXPLAIN ANALYSE SELECT emp.id_empleado, emp.id_departamento, emp.id_distribuidor, emp.id_tarea, emp.sueldo
FROM unc_esq_peliculas.empleado emp
JOIN (
    SELECT e.id_departamento, e.id_distribuidor, AVG(COALESCE(e.sueldo, 0)) avg_sueldo
    FROM unc_esq_peliculas.empleado e
    GROUP BY e.id_departamento, e.id_distribuidor
) sueldo_prom ON emp.id_departamento = sueldo_prom.id_departamento AND
                 emp.id_distribuidor = sueldo_prom.id_distribuidor
WHERE emp.sueldo > sueldo_prom.avg_sueldo
ORDER BY emp.id_empleado;




drop table TP_08_A;
drop table TP_08_B;
drop table TP_08_C;

create table TP_08_A(
  id_a int NOT NULL,
  id_b int,
  nombre varchar(30),
  cantidad_a int,
  constraint PK_A primary key (id_a)
);

create table TP_08_B(
  id_b int NOT NULL,
  nombre varchar(30),
  cantidad_b int,
  id_c int,
  constraint PK_TP_08_B primary key (id_b)
);

create table TP_08_C(
  id_c int NOT NULL,
  nombre varchar(30),
  cantidad_c int,
  constraint PK_TP_08_C primary key (id_c)
);

ALTER TABLE TP_08_A ADD CONSTRAINT FK_A_B FOREIGN KEY (id_b) REFERENCES TP_08_B(id_b);
ALTER TABLE TP_08_B ADD CONSTRAINT FK_B_C FOREIGN KEY (id_c) REFERENCES TP_08_C(id_c);

INSERT INTO TP_08_C (id_c, nombre, cantidad_c) VALUES (1, 'i', 50);
INSERT INTO TP_08_C (id_c, nombre, cantidad_c) VALUES (2, 'j', 10);
INSERT INTO TP_08_C (id_c, nombre, cantidad_c) VALUES (3, 'k', 15);

INSERT INTO TP_08_B (id_b, nombre, cantidad_b, id_c) VALUES (1, 'a', 10, 1);
INSERT INTO TP_08_B (id_b, nombre, cantidad_b, id_c) VALUES (2, 'y', 20, 1);
INSERT INTO TP_08_B (id_b, nombre, cantidad_b, id_c) VALUES (3, 'z', 30, 3);

INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (1, 'a', 1, 10);
INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (2, 'b', 1, 50);
INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (3, 'c', 2, 20);
INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (4, 'd', 2, 20);
INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (5, 'a', 3, 5);
INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (6, 'a', 1, 15);
INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (7, 'b', 2, 20);
INSERT INTO TP_08_A (id_a, nombre, id_b, cantidad_a) VALUES (8, 'c', 3, 20);

SELECT * FROM TP_08_A;
SELECT * FROM TP_08_B;
SELECT * FROM TP_08_C;


SELECT DISTINCT  nt.cantidad
FROM (
         (
             SELECT id_a, nombre, cantidad_a as cantidad
             FROM TP_08_A
         )
         UNION
         (
             SELECT id_b, nombre, cantidad_b as cantidad
             FROM TP_08_B
         )
     ) nt
order by 1;

(
    SELECT cantidad_a as cantidad
    FROM TP_08_A
 )
 INTERSECT
 (
    SELECT cantidad_b as cantidad
    FROM TP_08_B
 ) order by 1;


-- Considere el siguiente esquema de base de datos de
-- empleados de un grupo de investigación en particular:
CREATE TABLE IF NOT EXISTS TP_08_EMPLEADO(
    id_empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    cargo VARCHAR(80) NOT NULL,
    CONSTRAINT PK_TP_08_EMPLEADO PRIMARY KEY (id_empleado)
);

CREATE TABLE IF NOT EXISTS TP_08_PROYECTO(
    cod_proyecto INT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NOT NULL,
    CONSTRAINT PK_TP_08_PROYECTO PRIMARY KEY (cod_proyecto)
);

CREATE TABLE IF NOT EXISTS TP_08_TRABAJA_EN(
    id_empleado INT NOT NULL,
    cod_proyecto INT NOT NULL,
    cant_horas INT NOT NULL,
    CONSTRAINT PK_TP_08_TRABAJA_EN PRIMARY KEY (id_empleado, cod_proyecto),
    CONSTRAINT FK_TP_08_TRABAJA_EN_TP_08_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES TP_08_EMPLEADO (id_empleado),
    CONSTRAINT FK_TP_08_TRABAJA_EN_TP_08_PROYECTO FOREIGN KEY (cod_proyecto) REFERENCES TP_08_PROYECTO (cod_proyecto)
);

-- A su vez, se tienen la siguiente consulta que responde a seleccionar
-- los apellidos de los empleados que trabajan en el proyecto
-- ROBOTICS y que tienen un cargo de investigador:

EXPLAIN SELECT E.apellido
FROM TP_08_EMPLEADO E ,
     TP_08_TRABAJA_EN T ,
     TP_08_PROYECTO P
WHERE E.id_empleado = T.id_empleado AND
      P.cod_proyecto = T.cod_proyecto AND
      P.nombre = 'ROBOTICS' AND
      E.cargo = 'investigador';

EXPLAIN ANALYSE
SELECT datos.apellido
FROM (
        SELECT trabaja_en.id_empleado, emp.apellido, trabaja_en.cod_proyecto
        FROM (
                SELECT e.id_empleado, e.apellido
                FROM TP_08_EMPLEADO e
                WHERE e.cargo = 'INVESTIGADOR'
             ) emp
            NATURAL JOIN
            (
                SELECT t.id_empleado, t.cod_proyecto
                FROM TP_08_TRABAJA_EN t
            ) trabaja_en
     )datos
    NATURAL JOIN
    (
        SELECT p.cod_proyecto
        FROM TP_08_PROYECTO p
        WHERE p.nombre = 'ROBOTICS'
    ) empleados;
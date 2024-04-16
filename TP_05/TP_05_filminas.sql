SET SEARCH_PATH = unc_251340;

DROP TABLE IF EXISTS TP_05_area;
CREATE TABLE TP_05_area(
  tipo_area CHAR(2) NOT NULL,
  id_area INT NOT NULL,
  descripcion VARCHAR(10) NOT NULL,
  CONSTRAINT PK_TP_05_area PRIMARY KEY (tipo_area, id_area)
);

DROP TABLE IF EXISTS TP_05_empleado;
CREATE TABLE TP_05_empleado(
    id_empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nac DATE NOT NULL,
    tipo_area CHAR(2) DEFAULT NULL,
    id_area INT DEFAULT NULL,
    CONSTRAINT FK_TP_05_empleado_area FOREIGN KEY (tipo_area, id_area) REFERENCES TP_05_area(tipo_area, id_area)
    MATCH SIMPLE
    ON DELETE SET NULL
    ON UPDATE SET NULL
);

INSERT INTO TP_05_area (tipo_area, id_area, descripcion) VALUES ('A', 1, 'AREA A1');
INSERT INTO TP_05_area (tipo_area, id_area, descripcion) VALUES ('A', 2, 'AREA A2');
INSERT INTO TP_05_area (tipo_area, id_area, descripcion) VALUES ('B', 1, 'AREA B1');
INSERT INTO TP_05_area (tipo_area, id_area, descripcion) VALUES ('B', 2, 'AREA B2');

INSERT INTO TP_05_empleado(id_empleado, nombre, apellido, fecha_nac, tipo_area, id_area) VALUES (2, 'José', 'Mares', '1990-03-06', 'A', 1);
INSERT INTO TP_05_empleado(id_empleado, nombre, apellido, fecha_nac, tipo_area, id_area) VALUES (3, 'Ana', 'Castro', '1980-08-01', 'B', 1);
INSERT INTO TP_05_empleado(id_empleado, nombre, apellido, fecha_nac, tipo_area, id_area) VALUES (4, 'Ximena', 'Lopez', '1850-08-07', 'A', 2);
INSERT INTO TP_05_empleado(id_empleado, nombre, apellido, fecha_nac, tipo_area, id_area) VALUES (6, 'Iris', 'Dominic', '1978-05-07', 'B', 1);
INSERT INTO TP_05_empleado(id_empleado, nombre, apellido, fecha_nac, tipo_area, id_area) VALUES (8, 'Julian', 'Dominic', '1978-05-07', 'A', NULL);

SELECT * FROM TP_05_empleado;
SELECT * FROM TP_05_area;

DELETE FROM TP_05_area WHERE tipo_area = 'A' AND id_area = 1;
DELETE FROM TP_05_area WHERE tipo_area = 'B' AND id_area = 2;
DELETE FROM TP_05_area;
UPDATE TP_05_area SET id_area = 3 WHERE tipo_area = 'B' AND id_area = 1;
UPDATE TP_05_area SET id_area = 3 WHERE tipo_area = 'B' AND id_area = 2;
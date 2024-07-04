-- SCRIPT PARA CREAR EL ESQUEMA PELICULA

-- Tablas:
CREATE TABLE IF NOT EXISTS esq_pel_pais AS
SELECT *
FROM unc_esq_peliculas.pais;

CREATE TABLE IF NOT EXISTS esq_pel_ciudad AS
    SELECT *
    FROM unc_esq_peliculas.ciudad;

CREATE TABLE IF NOT EXISTS esq_pel_departamento AS
    SELECT *
    FROM unc_esq_peliculas.departamento;

CREATE TABLE IF NOT EXISTS esq_pel_empleado AS
    SELECT *
    FROM unc_esq_peliculas.empleado;

CREATE TABLE IF NOT EXISTS esq_pel_tarea AS
    SELECT *
    FROM unc_esq_peliculas.tarea;

CREATE TABLE IF NOT EXISTS esq_pel_empresa_productora AS
    SELECT *
    FROM unc_esq_peliculas.empresa_productora;

CREATE TABLE IF NOT EXISTS esq_pel_pelicula AS
    SELECT *
    FROM unc_esq_peliculas.pelicula;

CREATE TABLE IF NOT EXISTS esq_pel_entrega AS
    SELECT *
    FROM unc_esq_peliculas.entrega;

CREATE TABLE IF NOT EXISTS esq_pel_distribuidor AS
    SELECT *
    FROM unc_esq_peliculas.distribuidor;

CREATE TABLE IF NOT EXISTS esq_pel_internacional AS
    SELECT *
    FROM unc_esq_peliculas.internacional;

CREATE TABLE IF NOT EXISTS esq_pel_renglon_entrega AS
    SELECT *
    FROM unc_esq_peliculas.renglon_entrega;

CREATE TABLE IF NOT EXISTS esq_pel_video AS
    SELECT *
    FROM unc_esq_peliculas.video;

CREATE TABLE IF NOT EXISTS esq_pel_nacional AS
    SELECT *
    FROM unc_esq_peliculas.nacional;


-- PRIMARY KEYS Y SET NOT NULL:
ALTER TABLE esq_pel_pais ADD CONSTRAINT PK_PEL_PAIS PRIMARY KEY(id_pais);
ALTER TABLE esq_pel_pais ALTER COLUMN nombre_pais SET NOT NULL;

ALTER TABLE esq_pel_ciudad ADD CONSTRAINT PK_PEL_CIUDAD PRIMARY KEY(id_ciudad);
ALTER TABLE esq_pel_ciudad ALTER COLUMN nombre_ciudad SET NOT NULL;
ALTER TABLE esq_pel_ciudad ALTER COLUMN id_pais SET NOT NULL;

ALTER TABLE esq_pel_departamento ADD CONSTRAINT PK_PEL_DEPARTAMENTO PRIMARY KEY(id_departamento, id_distribuidor);
ALTER TABLE esq_pel_departamento ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE esq_pel_departamento ALTER COLUMN id_ciudad SET NOT NULL;
ALTER TABLE esq_pel_departamento ALTER COLUMN jefe_departamento SET NOT NULL;

ALTER TABLE esq_pel_empleado ADD CONSTRAINT PK_PEL_EMPLEADO PRIMARY KEY(id_empleado);
ALTER TABLE esq_pel_empleado ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE esq_pel_empleado ALTER COLUMN apellido SET NOT NULL;
ALTER TABLE esq_pel_empleado ALTER COLUMN e_mail SET NOT NULL;
ALTER TABLE esq_pel_empleado ALTER COLUMN fecha_nacimiento SET NOT NULL;
ALTER TABLE esq_pel_empleado ALTER COLUMN id_tarea SET NOT NULL;
ALTER TABLE esq_pel_empleado ALTER COLUMN id_departamento SET NOT NULL;
ALTER TABLE esq_pel_empleado ALTER COLUMN id_distribuidor SET NOT NULL;

ALTER TABLE esq_pel_tarea ADD CONSTRAINT PK_PEL_TAREA PRIMARY KEY(id_tarea);
ALTER TABLE esq_pel_tarea ALTER COLUMN nombre_tarea SET NOT NULL;
ALTER TABLE esq_pel_tarea ALTER COLUMN sueldo_maximo SET NOT NULL;
ALTER TABLE esq_pel_tarea ALTER COLUMN sueldo_minimo SET NOT NULL;

ALTER TABLE esq_pel_empresa_productora ADD CONSTRAINT PK_PEL_EMPRESA_PRODUCTORA PRIMARY KEY(codigo_productora);
ALTER TABLE esq_pel_empresa_productora ALTER COLUMN nombre_productora SET NOT NULL;

ALTER TABLE esq_pel_pelicula ADD CONSTRAINT PK_PEL_PELICULA PRIMARY KEY(codigo_pelicula);
ALTER TABLE esq_pel_pelicula ALTER COLUMN titulo SET NOT NULL;
ALTER TABLE esq_pel_pelicula ALTER COLUMN idioma SET NOT NULL;
ALTER TABLE esq_pel_pelicula ALTER COLUMN formato SET NOT NULL;
ALTER TABLE esq_pel_pelicula ALTER COLUMN genero SET NOT NULL;
ALTER TABLE esq_pel_pelicula ALTER COLUMN codigo_productora SET NOT NULL;

ALTER TABLE esq_pel_entrega ADD CONSTRAINT PK_PEL_ENTREGA PRIMARY KEY(nro_entrega);
ALTER TABLE esq_pel_entrega ALTER COLUMN fecha_entrega SET NOT NULL;
ALTER TABLE esq_pel_entrega ALTER COLUMN id_video SET NOT NULL;
ALTER TABLE esq_pel_entrega ALTER COLUMN id_distribuidor SET NOT NULL;

ALTER TABLE esq_pel_distribuidor ADD CONSTRAINT PK_PEL_DISTRIBUIDOR PRIMARY KEY(id_distribuidor);
ALTER TABLE esq_pel_distribuidor ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE esq_pel_distribuidor ALTER COLUMN direccion SET NOT NULL;
ALTER TABLE esq_pel_distribuidor ALTER COLUMN tipo SET NOT NULL;

ALTER TABLE esq_pel_internacional ADD CONSTRAINT PK_PEL_INTERNACIONAL PRIMARY KEY(id_distribuidor);
ALTER TABLE esq_pel_internacional ALTER COLUMN codigo_pais SET NOT NULL;

ALTER TABLE esq_pel_renglon_entrega ADD CONSTRAINT PK_PEL_RENGLON_ENTREGA PRIMARY KEY(nro_entrega, codigo_pelicula);
ALTER TABLE esq_pel_renglon_entrega ALTER COLUMN cantidad SET NOT NULL;

ALTER TABLE esq_pel_video ADD CONSTRAINT PK_PEL_VIDEO PRIMARY KEY(id_video);
ALTER TABLE esq_pel_video ALTER COLUMN razon_social SET NOT NULL;
ALTER TABLE esq_pel_video ALTER COLUMN direccion SET NOT NULL;
ALTER TABLE esq_pel_video ALTER COLUMN propietario SET NOT NULL;

ALTER TABLE esq_pel_nacional ADD CONSTRAINT PK_PEL_NACIONAL PRIMARY KEY(id_distribuidor);
ALTER TABLE esq_pel_nacional ALTER COLUMN nro_inscripcion SET NOT NULL;
ALTER TABLE esq_pel_nacional ALTER COLUMN encargado SET NOT NULL;
ALTER TABLE esq_pel_nacional ALTER COLUMN nro_inscripcion SET NOT NULL;


-- AGREGANDO LOS FOREIGN KEY
-- FK DE CIUDAD
ALTER TABLE esq_pel_ciudad ADD CONSTRAINT FK_PEL_CIUDAD_PAIS
    FOREIGN KEY(id_pais)
    REFERENCES esq_pel_pais(id_pais);


-- FK DE DEPARTAMENTO
ALTER TABLE esq_pel_departamento ADD CONSTRAINT FK_PEL_DEPARTAMENTO_DISTRIBUIDOR
    FOREIGN KEY(id_distribuidor)
    REFERENCES esq_pel_distribuidor(id_distribuidor);

ALTER TABLE esq_pel_departamento ADD CONSTRAINT FK_PEL_DEPARTAMENTO_CIUDAD
    FOREIGN KEY(id_ciudad)
    REFERENCES esq_pel_ciudad(id_ciudad);

ALTER TABLE esq_pel_departamento ADD CONSTRAINT FK_PEL_DEPARTAMENTO_EMPLEADO_JEFE
    FOREIGN KEY(jefe_departamento)
    REFERENCES esq_pel_empleado(id_empleado);

-- FK DE EMPLEADO
ALTER TABLE esq_pel_empleado ADD CONSTRAINT FK_PEL_EMPLEADO_TAREA
    FOREIGN KEY(id_tarea)
    REFERENCES esq_pel_tarea(id_tarea);

ALTER TABLE esq_pel_empleado ADD CONSTRAINT FK_PEL_EMPLEADO_EMPLEADO_JEFE
    FOREIGN KEY(id_jefe)
    REFERENCES esq_pel_empleado(id_empleado);

ALTER TABLE esq_pel_empleado ADD CONSTRAINT FK_PEL_EMPLEADO_DEPARTAMENTO
    FOREIGN KEY(id_departamento, id_distribuidor)
    REFERENCES esq_pel_departamento(id_departamento, id_distribuidor);


-- FK DE EMPRESA_PRODUCTORA
ALTER TABLE esq_pel_empresa_productora ADD CONSTRAINT FK_PEL_EMPRESAPRODUCTORA_CIUDAD
    FOREIGN KEY(id_ciudad)
    REFERENCES esq_pel_ciudad(id_ciudad);

-- FK DE PELICULA
ALTER TABLE esq_pel_pelicula ADD CONSTRAINT FK_PEL_PELICULA_EMPRESAPRODUCTORA
    FOREIGN KEY(codigo_productora)
    REFERENCES esq_pel_empresa_productora(codigo_productora);


-- FK DE ENTREGA
ALTER TABLE esq_pel_entrega ADD CONSTRAINT FK_PEL_ENTREGA_VIDEO
    FOREIGN KEY(id_video)
    REFERENCES esq_pel_video(id_video);

ALTER TABLE esq_pel_entrega ADD CONSTRAINT FK_PEL_ENTREGA_DISTRIBUIDOR
    FOREIGN KEY(id_distribuidor)
    REFERENCES esq_pel_distribuidor(id_distribuidor);


-- FK DE INTERNACIONAL
ALTER TABLE esq_pel_internacional ADD CONSTRAINT FK_PEL_INTERNACIONAL_DISTRIBUIDOR
    FOREIGN KEY(id_distribuidor)
    REFERENCES esq_pel_distribuidor(id_distribuidor);


-- FK DE RENGLON_ENTREGA
ALTER TABLE esq_pel_renglon_entrega ADD CONSTRAINT FK_PEL_RENGLONENTREGA_ENTREGA
    FOREIGN KEY(nro_entrega)
    REFERENCES esq_pel_entrega(nro_entrega);

ALTER TABLE esq_pel_renglon_entrega ADD CONSTRAINT FK_PEL_RENGLONENTREGA_PELICULA
    FOREIGN KEY(codigo_pelicula)
    REFERENCES esq_pel_pelicula(codigo_pelicula);


-- FK DE NACIONAL
ALTER TABLE esq_pel_nacional ADD CONSTRAINT FK_PEL_NACIONAL_DISTRIBUIDOR
    FOREIGN KEY(id_distribuidor)
    REFERENCES esq_pel_distribuidor(id_distribuidor);

ALTER TABLE esq_pel_nacional ADD CONSTRAINT FK_PEL_NACIONAL_INTERNACIONAL
    FOREIGN KEY(id_distrib_mayorista)
    REFERENCES esq_pel_internacional(id_distribuidor);


-- Eliminar RESTRICCIONES DE FK
ALTER TABLE esq_pel_ciudad DROP CONSTRAINT IF EXISTS fk_pel_ciudad_pais;
--
ALTER TABLE esq_pel_departamento DROP CONSTRAINT IF EXISTS FK_PEL_DEPARTAMENTO_DISTRIBUIDOR;
ALTER TABLE esq_pel_departamento DROP CONSTRAINT IF EXISTS FK_PEL_DEPARTAMENTO_CIUDAD;
ALTER TABLE esq_pel_departamento DROP CONSTRAINT IF EXISTS FK_PEL_DEPARTAMENTO_EMPLEADO_JEFE;
--
ALTER TABLE esq_pel_empleado DROP CONSTRAINT IF EXISTS FK_PEL_EMPLEADO_TAREA;
ALTER TABLE esq_pel_empleado DROP CONSTRAINT IF EXISTS FK_PEL_EMPLEADO_EMPLEADO_JEFE;
ALTER TABLE esq_pel_empleado DROP CONSTRAINT IF EXISTS FK_PEL_EMPLEADO_DEPARTAMENTO;
--
ALTER TABLE esq_pel_empresa_productora DROP CONSTRAINT IF EXISTS FK_PEL_EMPRESAPRODUCTORA_CIUDAD;
ALTER TABLE esq_pel_pelicula DROP CONSTRAINT IF EXISTS FK_PEL_PELICULA_EMPRESAPRODUCTORA;

--
ALTER TABLE esq_pel_entrega DROP CONSTRAINT IF EXISTS FK_PEL_ENTREGA_VIDEO;
ALTER TABLE esq_pel_entrega DROP CONSTRAINT IF EXISTS FK_PEL_ENTREGA_DISTRIBUIDOR;
--
ALTER TABLE esq_pel_internacional DROP CONSTRAINT IF EXISTS FK_PEL_INTERNACIONAL_DISTRIBUIDOR;
--
ALTER TABLE esq_pel_renglon_entrega DROP CONSTRAINT IF EXISTS FK_PEL_RENGLONENTREGA_ENTREGA;
ALTER TABLE esq_pel_renglon_entrega DROP CONSTRAINT IF EXISTS FK_PEL_RENGLONENTREGA_PELICULA;
--
ALTER TABLE esq_pel_nacional DROP CONSTRAINT IF EXISTS FK_PEL_NACIONAL_DISTRIBUIDOR;
ALTER TABLE esq_pel_nacional DROP CONSTRAINT IF EXISTS FK_PEL_NACIONAL_INTERNACIONAL;

-- Eliminar tablas
DROP TABLE IF EXISTS esq_pel_video;
DROP TABLE IF EXISTS esq_pel_nacional;
DROP TABLE IF EXISTS esq_pel_renglon_entrega;
DROP TABLE IF EXISTS esq_pel_internacional;
DROP TABLE IF EXISTS esq_pel_distribuidor;
DROP TABLE IF EXISTS esq_pel_entrega;
DROP TABLE IF EXISTS esq_pel_pelicula;
DROP TABLE IF EXISTS esq_pel_empresa_productora;
DROP TABLE IF EXISTS esq_pel_tarea;
DROP TABLE IF EXISTS esq_pel_empleado;
DROP TABLE IF EXISTS esq_pel_departamento;
DROP TABLE IF EXISTS esq_pel_ciudad;
DROP TABLE IF EXISTS esq_pel_pais;
-- SCRIPT PARA CREAR EL ESQUEMA VOLUNTARIO

-- Tabla continente
CREATE TABLE IF NOT EXISTS esq_vol_continente AS
    SELECT *
    FROM unc_esq_voluntario.continente;

-- Tabla pais
CREATE TABLE IF NOT EXISTS  esq_vol_pais AS
    SELECT *
    FROM unc_esq_voluntario.pais;

-- Tabla direccion
CREATE TABLE IF NOT EXISTS esq_vol_direccion AS
    SELECT *
    FROM unc_esq_voluntario.direccion;

-- Tabla institucion
CREATE TABLE IF NOT EXISTS esq_vol_institucion AS
    SELECT *
    FROM unc_esq_voluntario.institucion;

-- Tabla voluntario
CREATE TABLE IF NOT EXISTS esq_vol_voluntario AS
    SELECT *
    FROM unc_esq_voluntario.voluntario;

-- Tabla tarea
CREATE TABLE IF NOT EXISTS esq_vol_tarea AS
    SELECT *
    FROM unc_esq_voluntario.tarea;

-- Tabla historico
CREATE TABLE IF NOT EXISTS esq_vol_historico AS
    SELECT *
    FROM unc_esq_voluntario.historico;

-- PRIMARY KEYS Y SET NOT NULL:
ALTER TABLE esq_vol_institucion ADD CONSTRAINT PK_INSTITUCION PRIMARY KEY(id_institucion);
ALTER TABLE esq_vol_continente ADD CONSTRAINT PK_CONTIENE PRIMARY KEY(id_continente);
ALTER TABLE esq_vol_pais ADD CONSTRAINT PK_PAIS PRIMARY KEY(id_pais);
ALTER TABLE esq_vol_voluntario ADD CONSTRAINT PK_VOLUNTARIO PRIMARY KEY(nro_voluntario);
ALTER TABLE esq_vol_tarea ADD CONSTRAINT PK_TAREA PRIMARY KEY(id_tarea);
ALTER TABLE esq_vol_historico ADD CONSTRAINT PK_HISTORICO PRIMARY KEY(nro_voluntario, fecha_inicio);
ALTER TABLE esq_vol_direccion ADD CONSTRAINT PK_DIRECCION PRIMARY KEY(id_direccion);

ALTER TABLE esq_vol_direccion ALTER COLUMN ciudad SET NOT NULL;
ALTER TABLE esq_vol_institucion ALTER COLUMN nombre_institucion SET NOT NULL;
ALTER TABLE esq_vol_pais ALTER COLUMN id_continente SET NOT NULL;
ALTER TABLE esq_vol_voluntario ALTER COLUMN apellido SET NOT NULL;
ALTER TABLE esq_vol_voluntario ALTER COLUMN e_mail SET NOT NULL;
ALTER TABLE esq_vol_voluntario ALTER COLUMN fecha_nacimiento SET NOT NULL;
ALTER TABLE esq_vol_voluntario ALTER COLUMN id_tarea SET NOT NULL;
ALTER TABLE esq_vol_tarea ALTER COLUMN nombre_tarea SET NOT NULL;
ALTER TABLE esq_vol_historico ALTER COLUMN fecha_fin SET NOT NULL;
ALTER TABLE esq_vol_historico ALTER COLUMN id_tarea SET NOT NULL;

-- AGREGANDO LOS FOREIGN KEY
-- FK DE INSTITUCION
ALTER TABLE esq_vol_institucion ADD CONSTRAINT FK_INSTITUCION_DIRECCION
    FOREIGN KEY(id_direccion)
    REFERENCES esq_vol_direccion(id_direccion);

ALTER TABLE esq_vol_pais ADD CONSTRAINT FK_PAIS_CONTINENTE
    FOREIGN KEY(id_continente)
    REFERENCES esq_vol_continente(id_continente);

ALTER TABLE esq_vol_direccion ADD CONSTRAINT FK_DIRECCION_PAIS
    FOREIGN KEY(id_pais)
    REFERENCES esq_vol_pais(id_pais);

ALTER TABLE esq_vol_institucion ADD CONSTRAINT FK_INSTITUCION_VOLUNTARIO
    FOREIGN KEY(id_director)
    REFERENCES esq_vol_voluntario(nro_voluntario);

-- FK DE HISTORICO
ALTER TABLE esq_vol_historico ADD CONSTRAINT FK_HISTORICO_INSTITUCION
    FOREIGN KEY(id_institucion)
    REFERENCES esq_vol_institucion(id_institucion);

ALTER TABLE esq_vol_historico ADD CONSTRAINT FK_HISTORICO_VOLUNTARIO
    FOREIGN KEY(nro_voluntario)
    REFERENCES esq_vol_voluntario(nro_voluntario);

-- FK DE VOLUNTARIO
ALTER TABLE esq_vol_voluntario ADD CONSTRAINT FK_VOLUNTARIO_INSTITUCION
    FOREIGN KEY(id_institucion)
    REFERENCES esq_vol_institucion(id_institucion);

ALTER TABLE esq_vol_voluntario ADD CONSTRAINT FK_VOLUNTARIO_VOLUNTARIO_COORDINADOR
    FOREIGN KEY(id_coordinador)
    REFERENCES esq_vol_voluntario(nro_voluntario);

ALTER TABLE esq_vol_voluntario ADD CONSTRAINT FK_VOLUNTARIO_TAREA
    FOREIGN KEY(id_tarea)
    REFERENCES esq_vol_tarea(id_tarea);

-- Eliminando FK:
ALTER TABLE esq_vol_voluntario DROP CONSTRAINT IF EXISTS FK_VOLUNTARIO_VOLUNTARIO_COORDINADOR;
ALTER TABLE esq_vol_voluntario DROP CONSTRAINT IF EXISTS FK_VOLUNTARIO_INSTITUCION;
ALTER TABLE esq_vol_historico DROP CONSTRAINT IF EXISTS FK_HISTORICO_INSTITUCION;
ALTER TABLE esq_vol_historico DROP CONSTRAINT IF EXISTS FK_HISTORICO_VOLUNTARIO;
ALTER TABLE esq_vol_institucion DROP CONSTRAINT IF EXISTS FK_INSTITUCION_DIRECCION;
ALTER TABLE esq_vol_institucion DROP CONSTRAINT IF EXISTS FK_INSTITUCION_VOLUNTARIO;
ALTER TABLE esq_vol_direccion DROP CONSTRAINT IF EXISTS FK_DIRECCION_PAIS;
ALTER TABLE esq_vol_pais DROP CONSTRAINT IF EXISTS FK_PAIS_CONTINENTE;

-- Eliminando tablas:
DROP TABLE IF EXISTS esq_vol_continente CASCADE;
DROP TABLE IF EXISTS esq_vol_pais CASCADE;
DROP TABLE IF EXISTS esq_vol_direccion CASCADE;
DROP TABLE IF EXISTS esq_vol_institucion CASCADE;
DROP TABLE IF EXISTS esq_vol_voluntario CASCADE;
DROP TABLE IF EXISTS esq_vol_tarea CASCADE;
DROP TABLE IF EXISTS esq_vol_historico CASCADE;

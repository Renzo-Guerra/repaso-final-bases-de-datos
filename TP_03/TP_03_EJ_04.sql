SET SEARCH_PATH = unc_251340;

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-04-12 18:44:35.173

-- tables
-- Table: TP03_EJ04_DISCIPLINA
CREATE TABLE TP_03_EJ_04_DISCIPLINA (
    id_disciplina int NOT NULL,
    nombre_disciplina varchar(20) NOT NULL,
    descripcion_disciplina varchar(120) NOT NULL
);

ALTER TABLE TP_03_EJ_04_DISCIPLINA ADD CONSTRAINT PK_TP_03_EJ_04_DISCIPLINA PRIMARY KEY (id_disciplina);

-- Table: TP03_EJ04_INVESTIGADOR
CREATE TABLE TP_03_EJ_04_INVESTIGADOR (
    id_investigador int  NOT NULL,
    tipo_doc char(3) NOT NULL,
    nro_doc int NOT NULL,
    id_disciplina INT NOT NULL,
    nombre varchar(40) NOT NULL,
    apellido varchar(40) NOT NULL,
    direccion varchar(40) NOT NULL,
    fecha_nac date NOT NULL,
    telefono varchar(15) NOT NULL,
    CONSTRAINT FK_TP_03_EJ_04_INVESTIGADOR FOREIGN KEY (id_disciplina) REFERENCES TP_03_EJ_04_DISCIPLINA(id_disciplina)
);

ALTER TABLE TP_03_EJ_04_INVESTIGADOR ADD CONSTRAINT PK_TP_03_EJ_04_INVESTIGADOR PRIMARY KEY (id_investigador);
ALTER TABLE TP_03_EJ_04_INVESTIGADOR ADD CONSTRAINT U_TP_03_EJ_04_INVESTIGADOR UNIQUE (tipo_doc, nro_doc);

CREATE TABLE TP_03_EJ_04_TELEFONO(
    id_investigador INT NOT NULL,
    numero_tel VARCHAR(40) NOT NULL,
    CONSTRAINT PK_TELEFONO PRIMARY KEY (id_investigador),
    CONSTRAINT FK_TELEFONO_INVESTIGADOR FOREIGN KEY (id_investigador) REFERENCES TP_03_EJ_04_INVESTIGADOR(id_investigador)
);

-- Table: TP03_EJ04_PROYECTO
CREATE TABLE TP_03_EJ_04_PROYECTO (
    cod_proyecto int NOT NULL,
    nombre_proyecto varchar(40) NOT NULL,
    monto decimal(10,2) NOT NULL,
    estadio char(3) NOT NULL,
    tipo_proy char(1) NOT NULL,
    CONSTRAINT PK_TP_03_EJ_04_PROYECTO PRIMARY KEY (cod_proyecto)
);

-- Table: TP03_EJ04_PROY_INIC_FINAL
CREATE TABLE TP_03_EJ_04_PROY_INIC_FINAL (
    fecha_inicio date  NOT NULL,
    fecha_fin date  NULL
);

ALTER TABLE TP_03_EJ_04_PROY_INIC_FINAL ALTER COLUMN fecha_fin SET DEFAULT NULL;
ALTER TABLE TP_03_EJ_04_PROY_INIC_FINAL ADD COLUMN id_investigador INT NOT NULL;
ALTER TABLE TP_03_EJ_04_PROY_INIC_FINAL ADD CONSTRAINT FK_TP_03_EJ_04_PROY_INIC_FINAL_INVESTIGADOR FOREIGN KEY (id_investigador) REFERENCES TP_03_EJ_04_INVESTIGADOR(id_investigador);


CREATE TABLE TP_03_EJ_04_PROY_APROBADO_RECHAZADO(
    id_proyecto INT NOT NULL,
    aprobado BOOLEAN NOT NULL,


);

-- Table: TP03_EJ04_TAREA
CREATE TABLE TP_03_EJ_04_TAREA (
    id_tarea int  NOT NULL,
    nombre_tarea varchar(15)  NOT NULL,
    cant_horas decimal(6,2)  NOT NULL,
    CONSTRAINT PK_TP_03_EJ_04_TAREA PRIMARY KEY (id_tarea)
);

ALTER TABLE TP_03_EJ_04_TAREA ADD CONSTRAINT U_NOMBRE_TAREA UNIQUE (nombre_tarea);

CREATE TABLE INVESTIGADOR_TAREA(
    id_investigador INT NOT NULL,
    id_tarea INT NOT NULL,
    CONSTRAINT PK_INVESTIGADOR_TAREA PRIMARY KEY (id_investigador, id_tarea),
    CONSTRAINT FK_INVESTIGADOR_TAREA_INVESTIGADOR FOREIGN KEY (id_investigador) REFERENCES TP_03_EJ_04_INVESTIGADOR(id_investigador),
    CONSTRAINT FK_INVESTIGADOR_TAREA_TAREA FOREIGN KEY (id_tarea) REFERENCES TP_03_EJ_04_TAREA(id_tarea)
);

-- End of file.
SET SEARCH_PATH = unc_251340;

DROP TABLE FINAL_INSTALACION, FINAL_SERVICIO, FINAL_SERV_VIGILANCIA, FINAL_SERV_MONITOREO, FINAL_CLIENTE;

CREATE TABLE IF NOT EXISTS FINAL_SERV_MONITOREO(
    id_serv INT NOT NULL,
    caracteristica VARCHAR(80) NOT NULL,
    CONSTRAINT PK_FINAL_SERV_MONITOREO PRIMARY KEY (id_serv)
);

CREATE TABLE IF NOT EXISTS FINAL_SERV_VIGILANCIA(
    id_serv INT NOT NULL,
    situacion VARCHAR(80),
    CONSTRAINT PK_FINAL_SERV_VIGILANCIA PRIMARY KEY (id_serv)
);

CREATE TABLE IF NOT EXISTS FINAL_SERVICIO(
    id_serv INT NOT NULL,
    nombre_serv VARCHAR(50),
    anio_comienzo INT NOT NULL,
    anio_fin INT,
    tipo_serv CHAR(1) NOT NULL, -- Puede ser monitoreo (M) o vigilancia (V)
    CONSTRAINT PK_FINAL_SERVICIO PRIMARY KEY (id_serv)
);

CREATE TABLE IF NOT EXISTS FINAL_CLIENTE(
    zona CHAR(2) NOT NULL,
    nro_c INT NOT NULL,
    apellido_nombre VARCHAR(50) NOT NULL,
    ciudad VARCHAR(20) NOT NULL,
    fecha_alta DATE NOT NULL,
    CONSTRAINT PK_FINAL_CLIENTE PRIMARY KEY (zona, nro_c)
);

CREATE TABLE IF NOT EXISTS FINAL_INSTALACION(
    zona CHAR(2) NOT NULL,
    nro_c INT NOT NULL,
    id_serv INT NOT NULL,
    fecha_instalacion DATE NOT NULL,
    cant_horas INT NOT NULL,
    tarea VARCHAR(50) NOT NULL,
    CONSTRAINT PK_FINAL_INSTALACION PRIMARY KEY (zona, nro_c, id_serv),
    CONSTRAINT FK_FINAL_INSTALACION_CLIENTE FOREIGN KEY (zona, nro_c) REFERENCES FINAL_CLIENTE(zona, nro_c),
    CONSTRAINT FK_FINAL_INSTALACION_SERVICIO FOREIGN KEY (id_serv) REFERENCES FINAL_SERVICIO(id_serv)
);
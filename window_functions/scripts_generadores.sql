SET SEARCH_PATH = unc_251340;

CREATE TABLE W_F_product_groups (
	group_id serial,
	group_name VARCHAR (255) NOT NULL,
	CONSTRAINT PK_W_F_product_groups PRIMARY KEY (group_id)
);

CREATE TABLE W_F_products (
	product_id serial,
	product_name VARCHAR (255) NOT NULL,
	price DECIMAL (11, 2),
	group_id INT NOT NULL,
	CONSTRAINT PK_W_F_products PRIMARY KEY (product_id),
	CONSTRAINT FK_W_F_products_W_F_PRODUCT_GROUPS FOREIGN KEY (group_id) REFERENCES W_F_product_groups (group_id)
);


INSERT INTO W_F_product_groups (group_name)
VALUES
	('Smartphone'),
	('Laptop'),
	('Tablet');

INSERT INTO W_F_products (product_name, group_id,price)
VALUES
	('Microsoft Lumia', 1, 200),
	('HTC One', 1, 400),
	('Nexus', 1, 500),
	('iPhone', 1, 900),
	('HP Elite', 2, 1200),
	('Lenovo Thinkpad', 2, 700),
	('Sony VAIO', 2, 700),
	('Dell Vostro', 2, 800),
	('iPad', 3, 700),
	('Kindle Fire', 3, 150),
	('Samsung Galaxy Tab', 3, 200);

SELECT *
FROM W_F_product_groups;

-- en "ORDEN" asigna el numero de fila sin importar si son iguales o no algunos valores
SELECT p.*, ROW_NUMBER() OVER(PARTITION BY group_id ORDER BY price DESC) orden
FROM W_F_products p;

-- en "ORDEN" al encontrar 2 iguales, asigna el mismo numero y el siguiente se saltea
SELECT p.*, RANK() OVER(PARTITION BY group_id ORDER BY price DESC) orden
FROM W_F_products p;

-- En "ORDEN" al encontrar 2 iguales, asigna el mismo numero y el siguiente continua el ranking normal
SELECT p.*, DENSE_RANK() OVER(PARTITION BY group_id ORDER BY price DESC) orden
FROM W_F_products p;

-- ATRIBUTO, TUPLA, TABLA, ASSERTION
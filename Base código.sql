
-- CREAR UNA BASE DE DATOS
CREATE DATABASE [TP1] -- Se crea una base de datos que necesita otras definiciones
ON
(NAME= N'TP1', -- Se le asigna un nombre
	FILENAME= N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\TP1.mdf',
	SIZE= 10,--Un tamaño inicial en MB 
	MAXSIZE= 20, --Un tamaño máximo, si el archivo crece más que esto (en MB) se detiene automáticamente
	FILEGROWTH= 2) -- Tamaño que la base crecerá automáticamente cuando se añadan nuevos datos
LOG ON  
(NAME = N'TP1_log',  
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\TP1.ldf', 
    SIZE = 5, 
    MAXSIZE = 20,  
    FILEGROWTH = 2);  
GO


-- CREAR TABLAS
USE TP1; -- Indica a SQL que use determinada base de datos para modificarla o hacer queries
GO


--Creación de la tabla categoría
CREATE TABLE Categoria(
	ID_categoria INT NOT NULL CONSTRAINT id_cat PRIMARY KEY, --Forma de crear una llave primaria, se mantiene igual para cada tabla. 
	Nombre CHAR(40) NOT NULL, --Agrega un nombre, en este caso del tipo CHAR y como máximo 40 caracteres
)

--Creación de la tabla territorio
CREATE TABLE Territorio(
	ID_territorio INT NOT NULL  CONSTRAINT id_tet PRIMARY KEY,
	Provincia CHAR(20) NOT NULL,
	Canton CHAR(20) NOT NULL,
	Distrito CHAR(20) NOT NULL)

--Creación de la tabla cliente
CREATE TABLE Cliente(
	Cedula INT NOT NULL CONSTRAINT ced_clit PRIMARY KEY CHECK (LEN(cedula) <11 and LEN(Cedula)>8),--Se agrega un check para combrobar que la cedula no sea demasiado larga o demasiado corta
	Tipo_cedula CHAR(8) NOT NULL, 
	Nombre CHAR(40) NOT NULL, 
	Correo CHAR(30) NOT NULL, 
	NTelefono INT NOT NULL CHECK (LEN(NTelefono)=8),--La longitud de los teléfonos en costa rica siempre es de 8 caracteres, por lo cual se puede mantener como un valor fijo y por eso el check
	Direccion CHAR(100) NOT NULL)

--Creación de la tabla subcategoría
-- Esta tabla depende de categoría, por lo tanto requiere de una llave foránea
CREATE TABLE Subcategoria(
	ID_subcategoria INT NOT NULL  CONSTRAINT id_subcat PRIMARY KEY,
	Nombre CHAR(40) NOT NULL,
	ID_categoria INT NOT NULL, CONSTRAINT fk_categoroa FOREIGN KEY (ID_categoria) REFERENCES Categoria(ID_categoria)
)


--Creación de la tabla proveedor
-- Esta tabla depende de territorio, por lo tanto requiere de una llave foránea
CREATE TABLE Proveedor(
	Cedula INT NOT NULL CONSTRAINT ced_prov PRIMARY KEY CHECK (LEN(cedula) <11 and LEN(Cedula)>8),--Se agrega un check para combrobar que la cedula no sea demasiado larga o demasiado corta
	Tipo_cedula CHAR(8) NOT NULL, 
	Nombre CHAR(40)NOT NULL, 
	Correo CHAR(30) NOT NULL, 
	NTelefono INT NOT NULL CHECK (LEN(NTelefono)=8),--La longitud de los teléfonos en costa rica siempre es de 8 caracteres, por lo cual se puede mantener como un valor fijo y por eso el checkL)
	ID_territorio INT NOT NULL, CONSTRAINT fk_Territorio FOREIGN KEY (ID_Territorio) REFERENCES Territorio(ID_territorio))

--Creación de tabla de producto
--Depende de subcategoría y de categoría requiere dos llaves foráneas 
CREATE TABLE Producto(
    Numero_prod INT NOT NULL IDENTITY,
    Nombre CHAR(20) NOT NULL, 
    Precio INT NOT NULL,
    Color CHAR(10) NOT NULL,
    Tamannio INT,
    IDuniv CHAR(10) NOT NULL,
    ID_producto AS CONCAT(Numero_prod, IDuniv) PERSISTED, -- Definición de la columna calculada
    ID_subcategoria INT NOT NULL,
    CONSTRAINT fk_subcategoria FOREIGN KEY (ID_subcategoria) REFERENCES Subcategoria(ID_subcategoria)
)
ALTER TABLE Producto 
ADD CONSTRAINT id_prod PRIMARY KEY (ID_producto)


--Creación de tabla de producto
--Depende de cliente y requiere una llave foranea
CREATE TABLE Factura(
	num_fact INT NOT NULL IDENTITY CONSTRAINT n_f PRIMARY KEY,
	inf_prod CHAR(100) NOT NULL,
	precio INT, --Este valor si puede ser null porque se calcula con apoyo de la tabla intermedia InFactura
	cobro DECIMAL(10,2),
	impuestos  DECIMAL(10,2) CHECK(impuestos>0 and impuestos <100),
	descuento  DECIMAL(10,2) CHECK(descuento>0 and descuento <100),
	fecha DATE NOT NULL,
	Cedula INT NOT NULL, CONSTRAINT fk_cedula FOREIGN KEY (Cedula) REFERENCES cliente(Cedula))

--CREACIÓN TABLAS INTERMEDIAS 
--Estas tablas funcionan para hacer relaciones de muchos a muchos 
--En este caso tenemos dos, de factura a producto y de proveedor a producto y por lo tanto hay que crear tablas intermedias
--que las relacionen.

CREATE TABLE Infactura(
	inf_id INT NOT NULL IDENTITY CONSTRAINT inf_id PRIMARY KEY, 
	u_comp INT NOT NULL,
	precio_final INT,
	num_fact INT NOT NULL, CONSTRAINT fk_factura FOREIGN KEY (num_fact) REFERENCES Factura(num_fact),
	ID_producto VARCHAR(22) NOT NULL, CONSTRAINT fk_producto2 FOREIGN KEY (ID_producto) REFERENCES producto(ID_producto))

CREATE TABLE Infproveedores(
	inf_prov INT NOT NULL IDENTITY(1000,100) PRIMARY KEY,
	u_compradas INT NOT NULL,
	ID_producto VARCHAR(22) NOT NULL, CONSTRAINT fk_producto3 FOREIGN KEY (ID_producto) REFERENCES producto(ID_producto),
	Cedula INT NOT NULL, CONSTRAINT fk_cedula2 FOREIGN KEY (Cedula) REFERENCES Proveedor(Cedula))







--Hay que agregar los datos, para probar  

-- Tabla Categoria
INSERT INTO Categoria(ID_categoria,Nombre)
values (1,'Romance')
INSERT INTO Categoria( ID_categoria,Nombre)
values(2,'Superheroes')
INSERT INTO Categoria(ID_categoria,Nombre)
values (3,'Acción')
INSERT INTO Categoria(ID_categoria,Nombre)
values(4,'Manga')
SELECT *
FROM dbo.Categoria

-- Tabla Territorio
INSERT INTO Territorio(ID_territorio,Provincia,Canton,Distrito)
values (111,'San José','Tibás','San Juan')
INSERT INTO Territorio(ID_territorio,Provincia,Canton,Distrito)
values (441,'Heredia','Santo Domingo','Santo Tomás')
INSERT INTO Territorio(ID_territorio,Provincia,Canton,Distrito)
values (551,'Guanacaste','Liberia','Mayorgo')
INSERT INTO Territorio(ID_territorio,Provincia,Canton,Distrito)
values (661,'Puntarenas','Puntarenas','Pitahaya')
SELECT *
FROM dbo.Territorio

-- Tabla Cliente
INSERT INTO Cliente(Cedula,Tipo_cedula,Nombre,Correo, NTelefono,Direccion)
VALUES(118460903,'Fisica','Daniel Sibaja','daniel280602@gmail.com',70156067,'Santo Domingo, 100 metros sur de la bibioteca')
INSERT INTO Cliente(Cedula,Tipo_cedula,Nombre,Correo, NTelefono,Direccion)
VALUES(1884609030,'Juridica','Fabricio V','patas@gmail.com',70156066,'Alajuela, 100 metros sur del estadio Morera Soto')
INSERT INTO Cliente(Cedula,Tipo_cedula,Nombre,Correo, NTelefono,Direccion)
VALUES(118460905,'Fisica','Lionel Messi','leomessi@hotmail.com',70156068,'Tibas, 300 metros al norte del estadio Ricardo Saprissa')
INSERT INTO Cliente(Cedula,Tipo_cedula,Nombre,Correo, NTelefono,Direccion)
VALUES(2118460906,'Juridica','Walmart SA','walmart@gmail.com',70156069,'Walmart de Heredia')
SELECT * 
FROM dbo.Cliente

-- Tabla SubCategoria
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(100,'Adolescente',1)
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(101,'Marvel',2)
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(102,'Violiento',3)
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(103,'Shonen',4)
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(104,'Triste',1)
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(105,'DC',2)
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(106,'Guerra',3)
INSERT INTO Subcategoria(ID_subcategoria,Nombre,ID_categoria)
VALUES(107,'Isekai',4)
SELECT*
FROM dbo.Subcategoria

-- Tabla Provedor
INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(218460903,'Fisica','Andrés z','andresg@ffff.com',88305141,111)

INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(218460904,'Fisica','Alan z','alan@ffff.com',88355142,441)

INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(1218460905,'Juridica','Cristiano Ronaldo','elbicho@siu.com',88305143,551)

INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(1218460906,'Juridica','Ash Ketchum','pokemon@nintendo.com',88355144,111)

INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(218460907,'Fisica','Hernán z','Hernan@ffff.com',88305141,111)

INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(218460908,'Fisica','Nahomy z','Nahomy@ffff.com',88355142,441)

INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(1218460909,'Juridica','Keylor navas','keylor@navas.com',88305143,551)

INSERT INTO Proveedor(Cedula,Tipo_cedula,Nombre,Correo,NTelefono,ID_territorio)
Values(1218460910,'Juridica','Michael Jackson','jackson5@musica.com',88355144,111)
SELECT*
FROM dbo.Proveedor

-- Tabla Producto
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Amor y Amor',2500,'Negro',100,2000,100)
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Avengers 1',15500,'Rosa',56,3000,101)
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Odio y más',25000,'Rojo',100,4000,102)
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Dragon Ball',500,'Gris',56,5000,103)
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Romance',7500,'Azul',100,6000,104)
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Batman',1500,'Negro',56,7000,105)
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Call of duty',1000,'Amarillo',100,8000,106)
INSERT INTO Producto(Nombre,Precio,Color,Tamannio,IDuniv,ID_subcategoria)
VALUES('Isekai',500,'Blanco',56,1000,107)
SELECT*
FROM dbo.Producto

-- Insertar datos en la tabla "Factura"
INSERT INTO Factura (inf_prod, impuestos, descuento, fecha, Cedula)
VALUES('Batman y mas', 25, 5, '2023-09-23', 118460903)
INSERT INTO Factura (inf_prod, impuestos, descuento, fecha, Cedula)
VALUES('Amor y amor', 35, 15, '2002-09-22', 118460903)
INSERT INTO Factura (inf_prod, impuestos, descuento, fecha, Cedula)
VALUES('Vengadores Y MAS', 5, 5, '2015-01-15', 118460903)
INSERT INTO Factura (inf_prod, impuestos, descuento, fecha, Cedula)
VALUES('Isekai', 35, 10, '2002-06-28', 118460903)
INSERT INTO Factura (inf_prod, impuestos, descuento, fecha, Cedula)
VALUES('Amor y amor', 35, 15, '2012-06-06', 1884609030)
INSERT INTO Factura (inf_prod, impuestos, descuento, fecha, Cedula)
VALUES('Vengadores', 5, 5, '2015-09-15', 118460905)
INSERT INTO Factura (inf_prod, impuestos, descuento, fecha, Cedula)
VALUES('Dragon Ball y mas', 35, 10, '2022-11-07', 2118460906)
SELECT * 
FROM dbo.Factura


-- Insertar datos en la tabla "Infactura"
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (2, 1, 67000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (5, 1,78000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (1, 2, 81000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (22, 1, 12000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (2, 3,23000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (1, 3, 56000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (5, 4, 81000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (50, 5,12000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (10, 6, 23000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (12, 7, 45000)
INSERT INTO Infactura (u_comp, num_fact, ID_producto)
VALUES (2, 7, 34000)

SELECT*
FROM dbo.Infactura

-- Insertar datos en la tabla "Infproveedores
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (200, 12000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (3, 23000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (4, 34000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (5, 45000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (6, 56000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (7, 67000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (8, 78000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (9, 81000, 218460903)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (300, 23000, 218460904)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (400, 34000, 218460907)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (500, 45000, 218460908)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (600, 56000, 1218460905)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (700, 67000, 1218460906)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (800, 78000, 1218460909)
INSERT INTO Infproveedores(u_compradas,ID_producto,Cedula)
VALUES (900, 81000, 1218460910)
SELECT*
FROM dbo.Infproveedores



-- Este bloque de cógido sirve para que el precio se actualice con la cantidad de productos comprados y su respectivo precio
UPDATE Infactura
SET Infactura.precio_final = Infactura.u_comp * Producto.Precio
FROM Infactura
INNER JOIN Producto  ON Infactura.ID_producto = Producto.ID_producto;
SELECT*
FROM dbo.Infactura

-- Estos dos bloques de código añaden a factura el precio de todos los productos comprados y el cobro final tomando en cuenta descuentos e impuestos 

UPDATE Factura
SET Precio = (
    SELECT SUM(precio_final) -- Toma el precio final de infactura 
    FROM Infactura
    WHERE Infactura.num_fact = Factura.num_fact -- Busca los productos comprados por la factura en específico, así no mezcla productos de otras facturas
);
UPDATE Factura
SET cobro =precio - (descuento/100)*precio + (impuestos/100)*precio --Simplemente calcula el cobro final pasando el descuento y los impuestos a porcentaje y los suma y los resta respectivamente
SELECT*
FROM dbo.Factura
SELECT*
FROM dbo.Infactura

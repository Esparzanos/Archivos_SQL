CREATE DATABASE HOSPITAL4
GO
USE HOSPITAL4
GO

--CREAR TABLAS--
CREATE TABLE PACIENTES (
	PACID INT NOT NULL,
	PACNOMBRE VARCHAR(25) NOT NULL,
	PACAPEPAT VARCHAR(25) NOT NULL,
	PACAPEMAT VARCHAR(25),
	PACDOMICILIO VARCHAR (50),
	PACFECHANACIMIENTO DATE NOT NULL,
	PACTEL VARCHAR (10),
	PACSEXO CHAR(1),
	PACCORREO VARCHAR(256) NOT NULL)
GO
CREATE TABLE ESPECIALIDADES(
    ESPID INT NOT NULL,
    ESPNOMBRE VARCHAR(25) NOT NULL)
GO
CREATE TABLE DETALLES(
    ESPID INT NOT NULL,
    DOCID INT NOT NULL)
GO
CREATE TABLE DOCTORES (
	DOCID INT NOT NULL,
	DOCNOMBRE VARCHAR(25) NOT NULL,
	DOCAPEPAT VARCHAR(25) NOT NULL,
	DOCAPEMAT VARCHAR(25),
	DOCDOMICILIO VARCHAR (50),
    DOCRFC VARCHAR (13) NOT�NULL,
	DOCCURP VARCHAR (18) NOT�NULL,
	DOCFECHANACIMIENTO DATE NOT NULL,
	DOCTEL VARCHAR (10),
	DOCSEXO CHAR(1))
GO
CREATE TABLE HOSPITALES(
    HOSID INT NOT NULL,
    HOSNOMBRE VARCHAR(25) NOT NULL,
    HOSDOMICILIO VARCHAR (50),
    HOSTEL VARCHAR (10))
GO
CREATE TABLE CONSULTORIOS(
    CONID INT NOT NULL,
    CONNOMBRE VARCHAR(25) NOT NULL,
    HOSID INT NOT NULL)
GO
CREATE TABLE LABORATORIOS(
    LABID INT NOT NULL,
    LABNOMBRE VARCHAR(50) NOT NULL,
    LABDOMICILIO VARCHAR (50),
    LABTEL VARCHAR (10))
GO
CREATE TABLE MEDICAMENTOS(
    MEDID INT NOT NULL,
    MEDNOMBRE VARCHAR(25) NOT NULL,
    MEDDESCRIPCION VARCHAR (50) NOT�NULL,
    SUSACTIVA VARCHAR (50) NOT NULL,
    MEDPRECIO DECIMAL (10, 2) NOT�NULL,
    LABID INT NOT NULL)
GO
CREATE TABLE RECETAS(
    RECID INT NOT NULL,
    DOSISMED DECIMAL NOT NULL,
    MEDID INT NOT NULL)
GO
CREATE TABLE CITAS(
    CITID INT NOT NULL,
    FECHA DATE NOT NULL,
    PRESION DECIMAL NOT NULL,
    PESO DECIMAL NOT NULL,
    ALTURA DECIMAL NOT NULL,
    SINTOMAS VARCHAR(100),
    PACID INT NOT NULL,
    DOCID INT NOT NULL,
    RECID INT NOT NULL,
    CONID INT NOT NULL)
GO

--AGREGAR CLAVES PRIMARIAS--
ALTER TABLE PACIENTES ADD CONSTRAINT PK_PACIENTES PRIMARY KEY(PACID)
GO
ALTER TABLE ESPECIALIDADES ADD CONSTRAINT PK_CLIENTES PRIMARY KEY(ESPID)
GO
ALTER TABLE DOCTORES ADD CONSTRAINT PK_DOCTORES PRIMARY KEY(DOCID)
GO
ALTER TABLE HOSPITALES ADD CONSTRAINT PK_HOSPITALES PRIMARY KEY(HOSID)
GO
ALTER TABLE CONSULTORIOS ADD CONSTRAINT PK_CONSULTORIOS PRIMARY KEY(CONID)
GO
ALTER TABLE LABORATORIOS ADD CONSTRAINT PK_LABORATORIOS PRIMARY KEY(LABID)
GO
ALTER TABLE MEDICAMENTOS ADD CONSTRAINT PK_MEDICAMENTOS PRIMARY KEY(MEDID)
GO
ALTER TABLE RECETAS ADD CONSTRAINT PK_RECETAS PRIMARY KEY(RECID)
GO
ALTER TABLE CITAS ADD CONSTRAINT PK_CITAS PRIMARY KEY(CITID)
GO

--AGREGAR CLAVES FORANEAS--
ALTER TABLE CITAS ADD CONSTRAINT FK_CITAS_PACIENTES
FOREIGN KEY (PACID) REFERENCES PACIENTES(PACID)
GO
ALTER TABLE CITAS ADD CONSTRAINT FK_CITAS_DOCTORES
FOREIGN KEY (DOCID) REFERENCES DOCTORES(DOCID)
GO
ALTER TABLE CITAS ADD CONSTRAINT FK_CITAS_RECETAS
FOREIGN KEY (RECID) REFERENCES RECETAS(RECID)
GO
ALTER TABLE CITAS ADD CONSTRAINT FK_CITAS_CONSULTORIOS
FOREIGN KEY (CONID) REFERENCES CONSULTORIOS(CONID)
GO
ALTER TABLE DETALLES ADD CONSTRAINT FK_DETALLES_ESPECIALIDADES
FOREIGN KEY (ESPID) REFERENCES ESPECIALIDADES(ESPID)
GO
ALTER TABLE DETALLES ADD CONSTRAINT FK_DETALLES_DOCTORES
FOREIGN KEY (DOCID) REFERENCES DOCTORES(DOCID)
GO
ALTER TABLE CONSULTORIOS ADD CONSTRAINT FK_CONSULTORIOS_HOSPITALES
FOREIGN KEY (HOSID) REFERENCES HOSPITALES(HOSID)
GO
ALTER TABLE RECETAS ADD CONSTRAINT FK_RECETAS_MEDICAMENTOS
FOREIGN KEY (MEDID) REFERENCES MEDICAMENTOS(MEDID)
GO
ALTER TABLE MEDICAMENTOS ADD CONSTRAINT FK_MEDICAMENTOS_LABORATORIOS
FOREIGN KEY (LABID) REFERENCES LABORATORIOS(LABID)
GO

--AGREGAR LLAVES UNICAS--
ALTER TABLE DOCTORES ADD CONSTRAINT UC_DOCTORES_RFC UNIQUE(DOCRFC)
GO
ALTER TABLE DOCTORES ADD CONSTRAINT UC_DOCTORES_CURP UNIQUE(DOCCURP)
GO

--VALORES DEFAULT--
ALTER TABLE PACIENTES ADD CONSTRAINT DEF_PACIENTES_APEMAT DEFAULT('APELLIDO DESCONOCIDO') FOR PACAPEMAT
GO
ALTER TABLE PACIENTES ADD CONSTRAINT DEF_PACIENTES_DOMICILIO DEFAULT('DOMICILIO DESCONOCIDO') FOR PACDOMICILIO
GO
ALTER TABLE PACIENTES ADD CONSTRAINT DEF_PACIENTES_TELEFONO DEFAULT('TELEFONO DESCONOCIDO') FOR PACTEL
GO
ALTER TABLE DOCTORES ADD CONSTRAINT DEF_DOCTORES_APEMAT DEFAULT('APELLIDO DESCONOCIDO') FOR DOCAPEMAT
GO
ALTER TABLE DOCTORES ADD CONSTRAINT DEF_DOCTORES_DOMICILIO DEFAULT('DOMICILIO DESCONOCIDO') FOR DOCDOMICILIO
GO
ALTER TABLE DOCTORES ADD CONSTRAINT DEF_DOCTORES_TELEFONO DEFAULT('TELEFONO DESCONOCIDO') FOR DOCTEL
GO
ALTER TABLE HOSPITALES ADD CONSTRAINT DEF_HOSPITALES_DOMICILIO DEFAULT('DOMICILIO DESCONOCIDO') FOR HOSDOMICILIO
GO
ALTER TABLE HOSPITALES ADD CONSTRAINT DEF_HOSPITALES_TELEFONO DEFAULT('TELEFONO DESCONOCIDO') FOR HOSTEL
GO
ALTER TABLE LABORATORIOS ADD CONSTRAINT DEF_LABORATORIOS_DOMICILIO DEFAULT('DOMICILIO DESCONOCIDO') FOR LABDOMICILIO
GO
ALTER TABLE LABORATORIOS ADD CONSTRAINT DEF_LABORATORIOS_TELEFONO DEFAULT('TELEFONO DESCONOCIDO') FOR LABTEL
GO

--COMPROBACIONES--
ALTER TABLE PACIENTES ADD CHECK (PACSEXO IN('F', 'M', 'f', 'm'))
GO
ALTER TABLE PACIENTES ADD CHECK (LEN(PACTEL) = 10)
GO
ALTER TABLE PACIENTES ADD CHECK (PACFECHANACIMIENTO <= GETDATE())
GO
ALTER TABLE DOCTORES ADD CONSTRAINT CC_DOCTORES_RFC_CURP CHECK(DOCRFC<>DOCCURP)
GO
ALTER TABLE DOCTORES ADD CHECK (LEN(DOCRFC) IN (12, 13))
GO
ALTER TABLE DOCTORES ADD CHECK (LEN(DOCCURP) = 18)
GO
ALTER TABLE DOCTORES ADD CHECK (LEN(DOCTEL) = 10)
GO
ALTER TABLE DOCTORES ADD CHECK (DOCFECHANACIMIENTO <= DATEADD(YEAR, -18, GETDATE()))
GO
ALTER TABLE HOSPITALES ADD CHECK (LEN(HOSTEL) = 10)
GO
ALTER TABLE LABORATORIOS ADD CHECK (LEN(LABTEL) = 10)
GO
ALTER TABLE CITAS ADD CHECK (PESO > 0)
GO
ALTER TABLE CITAS ADD CHECK (ALTURA > 0)
GO
ALTER TABLE CITAS ADD CHECK (PRESION > 0)
GO

--AGREGAR DATOS A LAS TABLAS--
-- Insertar 5 registros en la tabla ESPECIALIDADES
INSERT INTO ESPECIALIDADES (ESPID, ESPNOMBRE)
VALUES 
    (1, 'Cardiolog�a'),
    (2, 'Pediatr�a'),
    (3, 'Dermatolog�a'),
    (4, 'Neurolog�a'),
    (5, 'Gastroenterolog�a')
GO

-- Insertar 5 registros en la tabla PACIENTES
INSERT INTO PACIENTES (PACID, PACNOMBRE, PACAPEPAT, PACAPEMAT, PACDOMICILIO, PACFECHANACIMIENTO, PACTEL, PACSEXO, PACCORREO)
VALUES 
    (1, 'Juan', 'P�rez', 'Gonz�lez', 'Calle 123, Colonia ABC', '2000-05-15', '5551234567', 'M', 'juan@example.com'),
    (2, 'Mar�a', 'L�pez', 'Garc�a', 'Av. Principal, Colonia XYZ', '1995-08-20', '5559876543', 'F', 'maria@example.com'),
    (3, 'Carlos', 'Rodr�guez', 'Mart�nez', 'Calle Central, Colonia LMN', '2010-03-10', '5557778888', 'M', 'carlos@example.com'),
    (4, 'Laura', 'G�mez', 'S�nchez', 'Av. Hospitalaria, Colonia Salud', '1992-11-25', '5555555555', 'F', 'laura@example.com'),
    (5, 'Jos�', 'Hern�ndez', 'Lara', 'Calle de los Ni�os, Colonia Infantil', '2015-09-05', '5554443333', 'M', 'jose@example.com')
GO

-- Insertar 5 registros en la tabla DOCTORES
INSERT INTO DOCTORES (DOCID, DOCNOMBRE, DOCAPEPAT, DOCAPEMAT, DOCDOMICILIO, DOCRFC, DOCCURP, DOCFECHANACIMIENTO, DOCTEL, DOCSEXO)
VALUES 
    (1, 'Dr. Ana', 'G�mez', 'S�nchez', 'Hospital A, Colonia ABC', 'ABCG8901234A5', 'GOSA890123HDFPLR09', '1970-10-05', '5551112222', 'F'),
    (2, 'Dr. Jorge', 'Lara', 'Hern�ndez', 'Hospital B, Colonia XYZ', 'XYZJ750912A2', 'LAHJ750912HDFPLR05', '1980-08-15', '5553334444', 'M'),
    (3, 'Dra. Laura', 'Soto', 'P�rez', 'Hospital C, Colonia LMN', 'LMNP820731G34', 'SPLA820731HDFPLR02', '1978-07-31', '5555555555', 'F'),
    (4, 'Dr. Carlos', 'Mart�nez', 'Gonz�lez', 'Hospital D, Colonia Salud', 'CMGS950528ABC', 'MAGC950528HDFPLR08', '1995-05-28', '5557778888', 'M'),
    (5, 'Dra. Patricia', 'Hern�ndez', 'L�pez', 'Hospital E, Colonia Salud', 'PHLL880712ABC', 'LALH880712HDFPLR04', '1988-07-12', '5559991111', 'F')
GO

-- Insertar 5 registros en la tabla HOSPITALES
INSERT INTO HOSPITALES (HOSID, HOSNOMBRE, HOSDOMICILIO, HOSTEL)
VALUES 
    (1, 'Hospital General', 'Av. Principal, Colonia Hospitalaria', '5551237890'),
    (2, 'Hospital Pedi�trico', 'Calle de los Ni�os, Colonia Infantil', '5559876543'),
    (3, 'Hospital Dermatol�gico', 'Av. de la Piel, Colonia Dermis', '5551112222'),
    (4, 'Hospital Neurol�gico', 'Av. del Cerebro, Colonia Neuro', '5554445555'),
    (5, 'Hospital Gastro', 'Calle de la Digesti�n, Colonia Gastro', '5553332222')
GO

-- Insertar 5 registros en la tabla CONSULTORIO
INSERT INTO CONSULTORIOS(CONID, CONNOMBRE, HOSID)
VALUES 
    (1, 'Consultorio 101', 1),
    (2, 'Consultorio 201', 2),
    (3, 'Consultorio 301', 3),
    (4, 'Consultorio 401', 4),
    (5, 'Consultorio 501', 5)
GO

-- Insertar 5 registros en la tabla LABORATORIO
INSERT INTO LABORATORIOS(LABID, LABNOMBRE, LABDOMICILIO, LABTEL)
VALUES 
    (1, 'Laboratorio Cl�nico', 'Calle de las Pruebas, Colonia An�lisis', '5557778888'),
    (2, 'Laboratorio de Im�genes', 'Av. de las Radiograf�as, Colonia Radiolog�a', '5554443333'),
    (3, 'Laboratorio de Gen�tica', 'Av. del ADN, Colonia Gen�mica', '5559991111'),
    (4, 'Laboratorio de Neurolog�a', 'Calle de las Neuronas, Colonia Neuromed', '5552223333'),
    (5, 'Laboratorio de Gastroenterolog�a', 'Av. del Est�mago, Colonia Gastro', '5555545555')
GO

-- Insertar 5 registros en la tabla MEDICAMENTOS
INSERT INTO MEDICAMENTOS (MEDID, MEDNOMBRE, MEDDESCRIPCION, SUSACTIVA, MEDPRECIO, LABID)
VALUES 
    (1, 'Aspirina', 'Analg�sico', '�cido acetilsalic�lico', 5.99, 1),
    (2, 'Ibuprofeno', 'Antiinflamatorio', 'Ibuprofeno', 7.99, 1),
    (3, 'Paracetamol', 'Analg�sico', 'Paracetamol', 4.99, 2),
    (4, 'Amoxicilina', 'Antibi�tico', 'Amoxicilina', 8.99, 3),
    (5, 'Omeprazol', 'Anti�cido', 'Omeprazol', 6.99, 4)
GO

-- Insertar 5 registros en la tabla RECETAS
INSERT INTO RECETAS (RECID, DOSISMED, MEDID)
VALUES 
    (1, 2.5, 1),
    (2, 1.0, 2),
    (3, 1.5, 3),
    (4, 3.0, 4),
    (5, 2.0, 5)
GO

-- Insertar 5 registros en la tabla CITAS
INSERT INTO CITAS (CITID, FECHA, PRESION, PESO, ALTURA, SINTOMAS, PACID, DOCID, RECID, CONID)
VALUES 
    (1, '2023-09-15', 120, 70, 170, 'Dolor de cabeza', 1, 1, 1, 1),
    (2, '2023-09-16', 130, 65, 165, 'Fiebre', 2, 2, 2, 2),
    (3, '2023-09-17', 110, 75, 175, 'Dolor abdominal', 3, 3, 3, 3),
    (4, '2023-09-18', 140, 80, 180, 'Mareos', 4, 4, 4, 4),
    (5, '2023-09-19', 125, 68, 167, 'Dolor de garganta', 5, 5, 5, 5)
GO

-- Insertar 5 registros en la tabla DETALLES (Para relacionar especialidades con pacientes)
INSERT INTO DETALLES (ESPID, DOCID)
VALUES 
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5)
GO




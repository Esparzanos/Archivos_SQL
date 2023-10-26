USE Northwind
GO

-- EXAMEN ROJO --
--1.- CREAR UN SP QUE RECIBA UN AÑO Y LLENE LA SIGUIENTE TABLA LLAMADA SEMANA( CLAVE INT, FECHA DATETIME, SEMANA INT ), 
--SE DEBE LLENAR DESDE EL PRIMERO DE ENERO DE ENERO HASTA EL 31 DE DICIEMBRE
CREATE TABLE SEMANA ( CLAVE INT, FECHA DATETIME, SEMANA INT )
GO
CREATE PROC SP_SEMANA @AÑO INT
AS
BEGIN
	DECLARE @FECHA DATETIME = CONVERT( DATETIME, '01-01-' + CAST( @AÑO AS VARCHAR ), 105 )
	DECLARE @FIN_AÑO DATETIME = CONVERT( DATETIME, '31-12-' + CAST( @AÑO AS VARCHAR ), 105 )
	DECLARE @NUMERO_SEMANA INT

	WHILE @FECHA <= @FIN_AÑO
	BEGIN
		SET @NUMERO_SEMANA = DATEPART( WEEK, @FECHA )
		INSERT INTO SEMANA ( CLAVE, FECHA, SEMANA )
		VALUES ( DATEPART( DAYOFYEAR, @FECHA ), @FECHA, @NUMERO_SEMANA )

		SET @FECHA = DATEADD( DAY, 1, @FECHA )

	END
END;
GO

EXEC SP_SEMANA @AÑO = 2023;
SELECT * FROM SEMANA
GO

-- PROBLEMA 2
-- Procedimiento almacenado que reciba la clave de una categoria,
-- el procedimiento debe forzar la eliminacion de la categoria, 
-- aunque tenga hijos en las tablas productos u OrderDetails
CREATE PROCEDURE dbo.SP_eliminacionCategoria (@CategoryID INT) AS
BEGIN
	SELECT * FROM Categories
END
GO

-- PROBLEMA 3
-- FUNCION ESCALAR QUE RECIBA UN AÑO Y DIA DE LA SEMANA, DEBE DE
-- REGRESAR EL IMPORTE TOTAL DE VENTAS DE ESE AÑO Y DIA DE LA SEMANA
CREATE FUNCTION dbo.FN_VENTASAÑOSEMANA (@AÑO INT,@DIASEMANA INT)
RETURNS NUMERIC(12,2)
AS
BEGIN
     DECLARE @IMPORTE numeric(12,2)

	 SELECT @IMPORTE = SUM(OD.UnitPrice * OD.Quantity)
	 FROM [Order Details] OD
	 INNER JOIN ORDERS O ON O.OrderID = OD.OrderID
	 WHERE YEAR(O.ORDERDATE)=@AÑO AND DATEPART(WEEKDAY,O.OrderDate) IN (@DIASEMANA)

	 RETURN @IMPORTE
END
GO

SELECT dbo.FN_VENTASAÑOSEMANA(1997, 3)
GO

-- PROBLEMA 4
-- FUNCION DE TABLA EN LINEA QUE RECIBA LA CLAVE DE LA PROVEEDORES 
-- Y REGRESE UNA TABLA CON LOS NOMBRES DE LOS PRODUCTOS QUE SURTE,
-- EL IMPORTE TOTAL DE VENTAS Y EL TOTAL DE ORDENES DONDE SE VENDIO.
create function dbo.fn_proveedoresOrdenes(@ProveedorID INT)
returns table
as
return(select p.ProductName, Importe = Sum(od.UnitPrice * od.Quantity),
TotalOrdenes = COUNT(od.OrderID)
from [Order Details] od 
inner join Products p on p.ProductID = od.ProductID
where p.CategoryID = @ProveedorID
GROUP BY p.ProductName
)
GO

SELECT * FROM dbo.fn_proveedoresOrdenes(1)
GO

-- PROBLEMA 5
-- FUNCION DE TABLA MULTISENTENCIA QUE RECIBA UN AÑO, QUE REGRESE UNA TABLA
-- CON TABLA CON NOMBRE DEL PRODUCTO QUE SE VENDIERON ESE AÑO Y EN OTRA COLUMNA
-- TODOS LOS FOLIOS DE ORDENES EN QUE SE HAN VENDIDO LOS LUNES Y MARTES SOLAMENTE
CREATE FUNCTION ObtenerProductosYOrdenes(@Año INT)
RETURNS @Resultados TABLE (NombreProducto NVARCHAR(MAX), FoliosOrdenes NVARCHAR(MAX))
AS
BEGIN
    DECLARE @FechaInicio DATE, @FechaFin DATE;
    SET @FechaInicio = DATEFROMPARTS(@Año, 1, 1);
    SET @FechaFin = DATEFROMPARTS(@Año, 12, 31);

    INSERT INTO @Resultados (NombreProducto, FoliosOrdenes)
    SELECT P.ProductName AS NombreProducto, 
           STRING_AGG(CONVERT(NVARCHAR(10), O.OrderID), ', ') AS FoliosOrdenes
    FROM Products P
    INNER JOIN [Order Details] OD ON P.ProductID = OD.ProductID
    INNER JOIN Orders O ON OD.OrderID = O.OrderID
    WHERE O.OrderDate BETWEEN @FechaInicio AND @FechaFin
        AND DATEPART(WEEKDAY, O.OrderDate) IN (2, 3) 
    GROUP BY P.ProductName;

    RETURN;
END;
GO

SELECT * FROM ObtenerProductosYOrdenes(1997)
GO


-- EXAMEN NEGRO --
/*
1.- PROCEDIMIENTO ALMACENADO QUE RECIBA LA CLAVE DE UNA CATEGORIA, EL PROCEDIMIENTO DEBE FORZAR LA
ELIMINACION DE LA CATEGORIA, AUNQUE TENGA HIJOS EN LAS TABLAS PRODUCTS U ORDERDETAILS
*/
CREATE PROC SP_P1 @ClaveCategoria INT
AS
BEGIN
	DECLARE @ClaveProducto INT
	SELECT @ClaveProducto = MIN(ProductID) FROM Products WHERE CategoryID = @ClaveCategoria

	WHILE @ClaveProducto IS NOT NULL
	BEGIN
		DELETE FROM [Order Details] WHERE ProductID = @ClaveProducto
		SELECT @ClaveProducto = MIN(ProductID) FROM Products WHERE CategoryID = @ClaveCategoria AND ProductID > @ClaveProducto
	END

	DELETE FROM Products WHERE CategoryID = @ClaveCategoria
	DELETE FROM Categories WHERE CategoryID = @ClaveCategoria
END

EXEC SP_P1 3
SELECT * FROM [Order Details]
SELECT * FROM Products
SELECT * FROM Categories
GO

/*
2.- LA TABLA CLIENTES SE LE AGREGO EL CAMPO TIPOCLIENTE, MEDIANTE UN PROCEDIMIENTO ALMACENADO
ACTUALIZAR DICHO CAMPO DE ACUERDO A LAS SIGUIENTES CONDICIONES
*/
ALTER TABLE Customers ADD TipoCliente NVARCHAR(20)
GO

CREATE PROC SP_P2
AS
BEGIN
	CREATE TABLE #T(ClienteID NCHAR(5), TotalOrdenes INT)
	INSERT #T
	SELECT CustomerID, COUNT(OrderID)
	FROM Orders
	GROUP BY CustomerID

	DECLARE @ClaveCliente NCHAR(5), @OrdenesCliente INT, @TipoCliente NVARCHAR(20)
	SELECT @ClaveCliente = MIN(ClienteID) FROM #T

	WHILE @ClaveCliente IS NOT NULL
	BEGIN
		SELECT @OrdenesCliente = TotalOrdenes FROM #T WHERE ClienteID = @ClaveCliente
		IF @OrdenesCliente BETWEEN 1 AND 50
			SELECT @TipoCliente = 'CLIENTE NORMAL'
		IF @OrdenesCliente BETWEEN 51 AND 150
			SELECT @TipoCliente = 'CLIENTE BUENO'
		IF @OrdenesCliente > 150
			SELECT @TipoCliente = 'CLIENTE EXCELENTE'
		UPDATE Customers SET @TipoCliente = @TipoCliente WHERE CustomerID = @ClaveCliente

		SELECT @ClaveCliente = MIN(ClienteID) FROM #T WHERE ClienteID > @ClaveCliente
	END
END

SELECT CustomerID, TotalOrdenes = COUNT(OrderID)
FROM Orders
GROUP BY CustomerID

SELECT * FROM Customers
EXEC SP_P2
GO

/*
3.- FUNCION ESCALAR QUE RECIBA LA CLAVE DEL EMPLEADO Y REGRESE COMO PARAMETRO DE SALIDA EL LISTADO DE
LOS AnOS BISIESTOS VIVIDOS
*/
CREATE FUNCTION dbo.FN_P3(@ClaveEmpleado INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Listado NVARCHAR(MAX), @Fecha DATETIME, @Ano INT
	SELECT @Listado = ''
	SELECT @Fecha = BirthDate FROM Employees WHERE EmployeeID = @ClaveEmpleado

	WHILE @Fecha <= GETDATE()
	BEGIN
		SELECT @Ano = YEAR(@Fecha)
		IF @Ano % 4 = 0 AND (@Ano % 100 != 0 OR @Ano % 400 = 0)
			SELECT @Listado = @Listado + TRIM(STR(@Ano)) + ', '

		SELECT @Fecha = DATEADD(YY, 1, @Fecha)
	END

	RETURN @Listado
END
GO

SELECT [Listado de anos bisiestos] = dbo.FN_P3(1)
GO

/*
4.- FUNCION DE TABLA EN LINEA QUE RECIBA LA CLAVE DEL EMPLEADO Y REGRESE EN UNA CONSULTA LOS NOMBRES DE
LOS TERRITORIOS Y EN OTRA COLUMNA NOMBRE DE LAS REGIONES QUE ATIENDE
*/
CREATE FUNCTION dbo.FN_P4(@ClaveEmpleado INT)
RETURNS TABLE
AS
RETURN(
	SELECT [Nombre del territorio] = T.TerritoryDescription, [Nombre de la region] = R.RegionDescription
	FROM EmployeeTerritories ET
	INNER JOIN Territories T ON T.TerritoryID = ET.TerritoryID
	INNER JOIN Region R ON R.RegionID = T.RegionID
	WHERE ET.EmployeeID = @ClaveEmpleado
)
GO

SELECT * FROM dbo.FN_P4(3)
GO

/*
5.- FUNCION DE TABLA DE MULTISENTENCIA QUE RECIBA UN AnO, QUE REGRESE UNA TABLA CON NOMBRE DEL
PRODUCTO QUE SE VENDIERON ESE AnO Y EN OTRA COLUMNA, TODOS LOS FOLIOS DE ORDENES EN QUE SE HAN
VENDIDO LOS PRODUCTOS
*/
CREATE FUNCTION dbo.FN_P5(@Ano INT)
RETURNS @RESP TABLE(NombreProducto NVARCHAR(50), Folios NVARCHAR(MAX))
AS
BEGIN
	DECLARE @Temp TABLE(ProductoID INT)
	INSERT @Temp
	SELECT P.ProductID
	FROM Orders O
	INNER JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	INNER JOIN Products P ON P.ProductID = OD.ProductID
	WHERE YEAR(O.OrderDate) = @Ano
	GROUP BY P.ProductID

	DECLARE @ClaveProducto INT, @ListadoOrdenes NVARCHAR(MAX), @ClaveOrden INT, @NombreProducto NVARCHAR(50)
	SELECT @ClaveProducto = MIN(ProductoID) FROM @Temp

	WHILE @ClaveProducto IS NOT NULL
	BEGIN
		SELECT @ListadoOrdenes = ''

		SELECT @ClaveOrden= MIN(O.OrderID)
							FROM Orders O
							INNER JOIN [Order Details] OD ON OD.OrderID = O.OrderID
							WHERE YEAR(O.OrderDate) = @Ano AND OD.ProductID = @ClaveProducto

		WHILE @ClaveOrden IS NOT NULL
		BEGIN
			SELECT @ListadoOrdenes = @ListadoOrdenes + TRIM(STR(@ClaveOrden)) + ', '
			SELECT @ClaveOrden= MIN(O.OrderID)
							FROM Orders O
							INNER JOIN [Order Details] OD ON OD.OrderID = O.OrderID
							WHERE YEAR(O.OrderDate) = @Ano AND OD.ProductID = @ClaveProducto AND O.OrderID > @ClaveOrden
		END

		SELECT @NombreProducto = ProductName FROM Products WHERE ProductID = @ClaveProducto

		INSERT @RESP VALUES(@NombreProducto, @ListadoOrdenes)

		SELECT @ClaveProducto = MIN(ProductoID) FROM @Temp WHERE ProductoID > @ClaveProducto
	END

	RETURN
END
GO

SELECT * FROM dbo.FN_P5(1998)

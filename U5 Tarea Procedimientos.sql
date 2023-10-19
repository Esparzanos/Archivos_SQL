USE NORTHWIND
GO

-- 1
-- AGREGAR EL CAMPO
ALTER TABLE Suppliers
ADD TotalPiezas INT
GO

-- CREAR PROCEDIMIENTO ALMACENADO
CREATE PROC sp_llenarTotalPiezas AS
BEGIN
    UPDATE Suppliers
	SET TotalPiezas = (
		SELECT SUM(QUANTITY)
		FROM VW_ORDERDETAILS AS OD
		WHERE OD.[ID Proveedor] = Suppliers.SupplierID
		GROUP BY OD.[ID Proveedor]
    )
END
GO

-- EJECUTAR PROCEDIMIENTO
EXEC sp_llenarTotalPiezas
GO

-- IMPRIMIR RESULTADO
SELECT TOTALPIEZAS
FROM Suppliers
GO

-- 2
-- SP QUE RECIBA LA CLAVE DEL EMPLEADO Y REGRESE POR RETORNO LA EDAD EXACTA DEL EMPLEADO
CREATE PROC sp_calcularEdad (@EMPID INT) AS
BEGIN
    DECLARE @FECHA DATETIME, @EDAD INT

	SELECT @FECHA = BirthDate
	FROM Employees
	WHERE EmployeeID = @EMPID

	SELECT @EDAD = DATEDIFF(YY, @FECHA, GETDATE())
	SELECT @FECHA = DATEADD(YY, @EDAD, @FECHA)
		IF @EDAD > GETDATE()
			SELECT @EDAD -=1
	RETURN @EDAD
END
GO

-- EJECUTAR PROCEDIMINETO
DECLARE @EDADEMP INT
EXEC @EDADEMP = sp_calcularEdad 8
-- RESULTADOS
SELECT @EDADEMP AS 'EDAD DEL EMPLEADO'
GO

-- 3
-- PROCEDIMIENTO ALMACENADO QUE RECIBA COMO PARAMETRO UN AÑO Y REGRESE DOS PARAMETROS: 
	-- UN PARAMETRO CON EL NOMBRE DE TODOS LOS CLIENTES QUE COMPRARON ESE AÑO.
	-- Y OTRO PARAMETRO CON LA LISTA DE LAS ORDENES REALIZADAS ESE AÑO.
CREATE PROC sp_comprasOrdenesAnio @Anio INT, @Nombre NVARCHAR(200) OUTPUT, @OrdenesRealizadas NVARCHAR(200) OUTPUT AS
BEGIN
	SELECT @Nombre = ''
	SELECT @OrdenesRealizadas = ''

	CREATE TABLE #TablaClientes(ClaveCliente NCHAR(5) NOT NULL)
	INSERT #TablaClientes SELECT C.CustomerID FROM Customers C
	INNER JOIN Orders O ON O.CustomerID = C.CustomerID
	WHERE YEAR(O.OrderDate) = @Anio
	GROUP BY C.CustomerID

	CREATE TABLE #TablaOrdenes(ClaveOrden INT NOT NULL)
	INSERT #TablaOrdenes SELECT OrderID
	FROM Orders
	WHERE YEAR(OrderDate) = @Anio

	DECLARE @ClaveCliente NCHAR(5), @ClaveOrden INT
	SELECT @ClaveCliente = MIN(ClaveCliente) FROM #TablaClientes
	SELECT @ClaveOrden = MIN(ClaveOrden) FROM #TablaOrdenes

	WHILE @ClaveCliente IS NOT NULL
	BEGIN
		SELECT @Nombre = @Nombre + ' ' + (SELECT CompanyName FROM Customers WHERE CustomerID = @ClaveCliente) + ', ' 
		SELECT @ClaveCliente = MIN(ClaveCliente) FROM #TablaClientes WHERE ClaveCliente > @ClaveCliente
	END

	WHILE @ClaveOrden IS NOT NULL
	BEGIN
		SELECT @OrdenesRealizadas = @OrdenesRealizadas + TRIM(STR(@ClaveOrden)) + ', '
		SELECT @ClaveOrden = MIN(ClaveOrden) FROM #TablaOrdenes WHERE ClaveOrden > @ClaveOrden
	END
END
GO

-- EJECUTAR PROCEDIMIENTO
DECLARE @Nombre NVARCHAR(200), @OrdenesRealizadas NVARCHAR(200)
EXEC sp_comprasOrdenesAnio 1996, @Nombre OUTPUT, @OrdenesRealizadas OUTPUT
SELECT @Nombre
UNION
SELECT @OrdenesRealizadas
GO

-- IMPRIMIR RESULTADOS
SELECT * FROM Orders
GO

-- 4.- PROCEDIMIENTO ALMACENADO QUE REGRESE UNA TABLA CON EL AÑO Y LOS NOMBRES DE LOS CLIENTES QUE COMPRARON ESE AÑO.

CREATE PROC SP_DATOSANIOS AS
BEGIN
    CREATE TABLE #ClientesAnios(Anio INT NOT NULL, NomClientes NVARCHAR(150) NOT NULL)
    DECLARE @anio INT, @Nombres NVARCHAR(150), @ClienteCod NCHAR(5)
    SELECT @anio = YEAR(MIN(OrderDate)) From Orders
    WHILE @anio IS NOT NULL
    BEGIN
        SELECT @Nombres = ''
        SELECT @ClienteCod = MIN(CustomerID) FROM Orders WHERE YEAR(OrderDate) = @anio
        WHILE @ClienteCod IS NOT NULL
        BEGIN
            SELECT @Nombres = @Nombres + ' ' + (SELECT CompanyName FROM Customers WHERE CustomerID = @ClienteCod) + ', '
            SELECT @ClienteCod = MIN(CustomerID) FROM Orders WHERE YEAR(OrderDate) = @anio AND CustomerID > @ClienteCod
        END
        INSERT #ClientesAnios VALUES(@anio, @Nombres)
        SELECT @anio = YEAR(MIN(OrderDate)) FROM Orders WHERE YEAR(OrderDate) > @anio
    END
    SELECT Anio, [Nombre Clientes] = NomClientes FROM #ClientesAnios
END

-- EJECUTAR PROCEDIMIENTO
EXEC SP_DATOSANIOS
SELECT * FROM #ClientesAnios
GO 

-- 5.- SP QUE RECIBA UN AÑO Y REGRESE COMO PARAMETRO DE SALIDA LA CLAVE DEL ARTICULO QUE MAS SE VENDIO ESE AÑO
-- Y CANTIDAD DE PIEZAS VENDIDAS DE ESE PRODUCTO EN ESE AÑO.
CREATE PROC sp_articuloVendidoAnual @Anio INT, @IdArticulo INT OUTPUT, @CantidadPiezas INT OUTPUT AS
BEGIN
	CREATE TABLE #TablaPiezasVendidas(ClaveProducto INT NOT NULL, TotalPiezas INT NOT NULL)
	INSERT #TablaPiezasVendidas SELECT OD.ProductID, TotalPiezas = SUM(OD.Quantity)
	FROM [Order Details] OD
	INNER JOIN Orders O ON O.OrderID = OD.OrderID
	WHERE YEAR(O.OrderDate) = @Anio
	GROUP BY ProductID

	SELECT @CantidadPiezas = MAX(TotalPiezas) FROM #TablaPiezasVendidas
	SELECT @IdArticulo = ClaveProducto FROM #TablaPiezasVendidas WHERE TotalPiezas = @CantidadPiezas
END

-- EJECUTAR PROCEDIMIENTO
DECLARE @IdArticulo INT, @CantidadPiezas INT
EXEC sp_articuloVendidoAnual 1996, @IdArticulo OUTPUT, @CantidadPiezas OUTPUT
SELECT ClaveArticulo = @IdArticulo, CantidadPiezas = @CantidadPiezas
GO

-- 6.- FUNCION DE TABLA DE MULTISENTENCIA QUE RECIBA UN AÑO COMO PARAMETRO DE ENTRADA, 
-- QUE REGRESE UNA TABLA CON DOS COLUMNAS: MES, FOLIOS QUE SE VENDIERON ESE MES. NOTA: MOSTRAR TODOS LOS MESES.
CREATE PROC SP_MULTIMES @Anio INT AS
BEGIN
    CREATE TABLE #Meses(NombreMes NVARCHAR(25), FoliosV NVARCHAR(5000))
    DECLARE @Fecha DATETIME, @Folio INT, @ListFolios NVARCHAR(5000)
    SELECT @Fecha = '2000-01-01'
    WHILE YEAR(@Fecha) = 2000
    BEGIN
        SELECT @Folio = MIN(OrderID) FROM Orders WHERE YEAR(OrderDate) = @Anio AND MONTH(OrderDate) = MONTH(@Fecha)
        SELECT @ListFolios  = ''
        WHILE @Folio IS NOT NULL
        BEGIN
            SELECT @ListFolios = @ListFolios + TRIM(STR(@Folio)) + ', '
            SELECT @Folio = MIN(OrderID) FROM Orders WHERE YEAR(OrderDate) = @Anio AND MONTH(OrderDate) = MONTH(@Fecha) AND OrderID > @Folio
        END
        INSERT #Meses VALUES(DATENAME(MM, @Fecha), @ListFolios)
        SELECT @Fecha = DATEADD(MM, 1, @Fecha)
    END
    SELECT [Nombre Mes] = NombreMes, Folios = FoliosV FROM #Meses
END

-- EJECUTAR PROCEDIMIENTO
EXEC SP_MULTIMES 1997
SELECT * FROM #Meses
GO

-- 7.- SP QUE RECIBA LA CLAVE DEL EMPLEADO Y REGRESE COMO PARAMETRO DE SALIDA 
-- TODOS LOS NOMBRE DE LOS TERRITORIOS QUE ATIENDEN EL EMPLEADO.
CREATE PROC sp_emp_territorios @IdEmpleado INT, @Territorios NVARCHAR(4000) OUTPUT AS
BEGIN
	DECLARE @IdTerritorio INT

	CREATE TABLE #TablaET(ClaveTerritorio INT, NombreTerritorio NVARCHAR(50))
	INSERT #TablaET
	SELECT T.TerritoryID, T.TerritoryDescription
	FROM Employees E
	INNER JOIN EmployeeTerritories ET ON ET.EmployeeID = E.EmployeeID
	INNER JOIN Territories T ON T.TerritoryID = ET.TerritoryID
	WHERE E.EmployeeID = @IdEmpleado

	SELECT @IdTerritorio = MIN(ClaveTerritorio) FROM #TablaET

	WHILE @IdTerritorio IS NOT NULL
	BEGIN
		SELECT @Territorios = @Territorios + TRIM((SELECT NombreTerritorio FROM #TablaET WHERE ClaveTerritorio = @IdTerritorio)) + ', '
		SELECT @IdTerritorio = MIN(ClaveTerritorio) FROM #TablaET WHERE ClaveTerritorio > @IdTerritorio
	END
END
GO

-- EJECUTAR PROCEDIMIENTO
DECLARE @ListadoTerritorios NVARCHAR(4000)
SELECT @ListadoTerritorios = ''
EXEC sp_emp_territorios 1, @ListadoTerritorios OUTPUT
SELECT ListadoTerritorios = @ListadoTerritorios
GO

-- 8.- SP QUE REALICE UN PROCESO DONDE REGRESE LA SIGUIENTE TABLA:
-- "NOMBRE DE JEFES" SERÁ LA CADENA CON TODOS LOS NOMBRES DE LOS JEFES QUE TIENE EL EMPLEADO. "JEFE SUPERIOR" ES EL JEFE QUE SE ENCUENTRA EN LA RAIZ DEL ARBOL DE EMPLEADOS.
CREATE PROC SP_JEFES AS
BEGIN
    CREATE TABLE #Jefes(NomEmpleado NVARCHAR(50), NomJefes NVARCHAR(50), JefeSuperior NVARCHAR(50))
    DECLARE @EmpleadoCod INT, @NomEmpleado NVARCHAR(50), @NomJefes NVARCHAR(50), @NombreSuperior NVARCHAR(50), @EmpleadoActual INT
    SELECT @EmpleadoCod = MIN(EmployeeID) FROM Employees
    WHILE @EmpleadoCod IS NOT NULL
    BEGIN
        SELECT @NomEmpleado = FirstName FROM Employees WHERE EmployeeID = @EmpleadoCod
        SELECT @NomJefes = ''
        SELECT @NombreSuperior = ''
        SELECT @EmpleadoActual = ReportsTo FROM Employees WHERE EmployeeID = @EmpleadoCod
        WHILE @EmpleadoActual IS NOT NULL
        BEGIN
            SELECT @NombreSuperior = FirstName FROM Employees WHERE EmployeeID = @EmpleadoActual
            SELECT @NomJefes = @NomJefes + TRIM(@NombreSuperior) + ', '
            SELECT @EmpleadoActual = ReportsTo FROM Employees WHERE EmployeeID = @EmpleadoActual
        END
        INSERT #Jefes VALUES(@NomEmpleado, @NomJefes, @NombreSuperior)
        SELECT @EmpleadoCod = MIN(EmployeeID) FROM Employees WHERE EmployeeID > @EmpleadoCod
    END
    SELECT * FROM #Jefes
END

-- EJECUTAR PROCEDIMIENTO
EXEC SP_JEFES
SELECT * FROM #Jefes
GO

-- 9.- PROCEDIMIENTO ALMACENADO QUE RECIBA EL NONBRE DE UNA TABLA Y 
-- QUE EL PROCEDIMIENTO IMPRIMA EL CODIGO DE CREACION DE DICHA TABLA.

-- 10.- PROCEDIMIENTO ALMACENADO QUE AUMENTE EL PRECIO DE LOS PRODUCTOS UN 10% SI SE HAN VENDIDO
--  MENOS DE UN IMPORTE DE $2,000, 25% ENTRE $2,001 Y $3,0000, 30% MAS DE UN IMPORTE DE $ 3,000.
CREATE PROC sp_aumentoProductos AS
BEGIN
	CREATE TABLE #TablaProductoImporte(ClaveProducto INT, ImporteTotal NUMERIC(12, 2))
	INSERT #TablaProductoImporte
	SELECT ProductID, SUM(Quantity * UnitPrice)
	FROM [Order Details]
	GROUP BY ProductID

	DECLARE @IdProducto INT, @ImporteActual NUMERIC(12, 2)
	SELECT @IdProducto = MIN(ClaveProducto) FROM #TablaProductoImporte

	WHILE @IdProducto IS NOT NULL
	BEGIN
		SELECT @ImporteActual = ImporteTotal FROM #TablaProductoImporte WHERE ClaveProducto = @IdProducto
		IF @ImporteActual < 2000
			UPDATE Products SET UnitPrice = UnitPrice * 1.1 WHERE ProductID = @IdProducto
		ELSE IF @ImporteActual BETWEEN 2000 AND 3000
			UPDATE Products SET UnitPrice = UnitPrice * 1.25 WHERE ProductID = @IdProducto
		ELSE IF @ImporteActual >3000
			UPDATE Products SET UnitPrice = UnitPrice * 1.3 WHERE ProductID = @IdProducto

		SELECT @IdProducto = MIN(ClaveProducto) FROM #TablaProductoImporte WHERE ClaveProducto > @IdProducto
	END
END

-- EJECUTAR PROCEDIMIENTO
SELECT * FROM Products
EXEC sp_aumentoProductos
SELECT * FROM Products
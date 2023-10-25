--Tarea Funciones Taller de BD
USE Northwind
GO

/*1.- FUNCION ESCALAR QUE RECIBA DOS CLAVES DE CLIENTES,UN AÑO Y UN MES, Y REGRESE EL NOMBRE DEL CLIENTE QUE MAS HA VENDIDO PIEZAS DE LOS DOS EN ESE AÑO-MES 
Y EL TOTAL DE PIEZAS VENDIDAS. POR EJEMPLO, DEBE REGRESAR: EL CLIENTE JUAN PEREZ VENDIO 450 PIEZAS.*/


/*2-FUNCION ESCALAR QUE RECIBA LA CLAVE DEL TERRITORIO Y REGRESE UNA CADENA CON LOS NOMBRE DE LOS EMPLEADOS QUE SURTEN DICHO TERRITORIO.*/
CREATE FUNCTION dbo.SurtidoEmpleados (@TerritorioID INT)
RETURNS VARCHAR(1000)
AS
BEGIN
    DECLARE @NombreEmpleado VARCHAR(1000)

    SELECT @NombreEmpleado = COALESCE(@NombreEmpleado + ', ', '') + E.FirstName + ' ' + E.LastName
    FROM Employees E
	INNER JOIN EmployeeTerritories ET ON ET.EmployeeID = E.EmployeeID
	INNER JOIN Territories T ON T.TerritoryID = ET.TerritoryID
    WHERE et.TerritoryID = @TerritorioID

    RETURN @NombreEmpleado
END
GO
SELECT dbo.SurtidoEmpleados(01581)
GO
select * from Territories
select * from EmployeeTerritories
GO

DROP FUNCTION dbo.SurtidoEmpleados
GO


/*3-FUNCION DE TABLA EN LINEA QUE RECIBA LA CLAVE DE UN PROVEEDOR Y REGRESE UNA TABLA CON EL NOMBRE DE TODOS LOS PRODUCTOS QUE HA VENDIDO ESE PROVEEDOR, 
EL TOTAL DE PRODUCTOS VENDIDOS Y EL TOTAL DE ORDENES EN LAS QUE SE HAN VENDIDO.*/
CREATE FUNCTION dbo.FN_ProductosProveedor (@ProveedorID int)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.ProductName AS NombreProducto,
        COUNT(od.ProductID) AS TotalVendido,
        COUNT(DISTINCT o.OrderID) AS TotalOrdenes
    FROM Products p
    INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE p.SupplierID = @ProveedorID
    GROUP BY p.ProductName
)
GO
SELECT * FROM dbo.FN_ProductosProveedor(1)
--drop function dbo.FN_ProductosProveedor 
GO

/*4-FUNCION DE TABLA EN LINEA QUE RECIBA LA CLAVE DEL EMPLEADO, AÑO Y MES, REGRESE EN UNA CONSULTA EL NOMBRE DEL PRODUCTO Y TOTAL DE PRODUCTOS VENDIDOS POR ESE EMPLEADO Y ESE AÑO-MES.*/
CREATE FUNCTION dbo.VentasPorEmpleado (@EmpleadoID int, @AÑO int, @MES int)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.ProductName AS NombreProducto,
        SUM(od.Quantity) AS TotalVendido
    FROM Employees e
    INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    INNER JOIN Products p ON od.ProductID = p.ProductID
    WHERE e.EmployeeID = @EmpleadoID
      AND YEAR(o.OrderDate) = @AÑO
      AND MONTH(o.OrderDate) = @MES
    GROUP BY p.ProductName
)
GO
SELECT * FROM dbo.VentasPorEmpleado (1, 1996, 7)
--drop function dbo.VentasPorEmpleado 
GO


/*5.- UTILIZANDO LA FUNCION ANTERIOR MOSTRAR UNA CONSULTA SIGUIENTE:*/
SELECT
    p.ProductName AS NombreProducto,
    ISNULL(SUM(CASE WHEN YEAR(o.OrderDate) = 1996 AND MONTH(o.OrderDate) = 1 THEN v.TotalVendido END), 0) AS 'TotalPiezas_96_Ene',
    ISNULL(SUM(CASE WHEN YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 1 THEN v.TotalVendido END), 0) AS 'TotalPiezas_97_Ene',
    ISNULL(SUM(CASE WHEN YEAR(o.OrderDate) = 1998 AND MONTH(o.OrderDate) = 1 THEN v.TotalVendido END), 0) AS 'TotalPiezas_98_Ene'
FROM Products p
LEFT JOIN [Order Details] od ON p.ProductID = od.ProductID
LEFT JOIN Orders o ON od.OrderID = o.OrderID
CROSS APPLY dbo.VentasPorEmpleado(1, YEAR(o.OrderDate), MONTH(o.OrderDate)) v
GROUP BY p.ProductName
ORDER BY p.ProductName;
GO



/*6-FUNCION DE TABLA DE MULTISENTENCIA (NO LLEVA PARAMETROS DE ENTRADA) QUE REGRESE UNA TABLA CON EL NOMBRE DE LA CATEGORIA Y LOS NOMBRES DE LOS PRODUCTOS QUE PERTENECEN A LA CATEGORIA 
Y EL TOTAL DE PIEZAS QUE SE HAN VENDIDO DE ESA CATEGORIA*/
CREATE FUNCTION dbo.VentasPorCategoria ()
RETURNS @Resultados TABLE (Categoria VARCHAR(15), NombreProducto VARCHAR(40), PiezasVendidas int)
AS
BEGIN
    INSERT INTO @Resultados (Categoria, NombreProducto, PiezasVendidas)
    SELECT 
        c.CategoryName AS Categoria,
        p.ProductName AS ProductoS,
        SUM(od.Quantity) AS PiezasVendidas
    FROM Categories c
    INNER JOIN Products p ON c.CategoryID = p.CategoryID
    INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
    GROUP BY c.CategoryName, p.ProductName
    RETURN;
END
GO
SELECT * FROM dbo.VentasPorCategoria()
--drop function dbo.VentasPorCategoria
GO


/*7.- FUNCION DE TABLA DE MULTISENTENCIA QUE RECIBA UN AÑO COMO PARAMETRO DE ENTRADA, QUE REGRESE UNA TABLA CON DOS COLUMNAS: DIA DE LA SEMANA, 
FOLIOS QUE SE VENDIERON ESE DÍA DE SEMANA. NOTA, DEBE MOSTRAR TODOS LOS DIAS DE LA SEMANA, AUNQUE NO SE HAYAN REALIZADO ORDENES.*/
CREATE FUNCTION dbo.VentasSemana(@Año int)
RETURNS @Resultados TABLE (DiaSemana VARCHAR(15), FoliosVendidos VARCHAR(max))
AS
BEGIN
    DECLARE @FechaIni datetime = CONVERT(datetime, CONVERT(VARCHAR(4), @Año) + '-01-01')
    DECLARE @FechaFin datetime = CONVERT(datetime, CONVERT(VARCHAR(4), @Año) + '-12-31')
    WHILE @FechaIni <= @FechaFin
    BEGIN
        INSERT INTO @Resultados (DiaSemana, FoliosVendidos)
        SELECT 
            DATENAME(dw, @FechaIni) AS DiaSemana,
            ISNULL(
                (
                    SELECT STRING_AGG(CONVERT(VARCHAR(10), o.OrderID), ', ')
                    FROM Orders o
                    WHERE YEAR(o.OrderDate) = @Año AND CONVERT(date, o.OrderDate) = @FechaIni
                ), 
                'No se hay ordenes'
            )
        SET @FechaIni = DATEADD(day, 1, @FechaIni)
    END
    RETURN;
END
GO
SELECT * FROM dbo.VentasSemana(1997)
--drop function dbo.VentasSemana
GO

/*8.- FUNCION DE TABLA DE MULTISENTENCIA QUE RECIBA LA CLAVE DE UN EMPLEADO Y REGRESE UNA TABLA LOS DIAS DE LA SEMANA Y LOS CUMPLEAÑOS QUE SE HA FESTEJADO ESE DIA DE LA SEMANA*/
CREATE FUNCTION dbo.FN_CUMPLEAÑOS ()
RETURNS @Resultados TABLE (DiaSemana nvarchar(15),CumpleanosFestejados nvarchar(max))
AS
BEGIN
    INSERT INTO @Resultados (DiaSemana, CumpleanosFestejados)
    SELECT DISTINCT
        DATENAME(dw, BirthDate) AS DiaSemana,
        '' AS CumpleanosFestejados
    FROM Employees
    DECLARE @DiaSemana nvarchar(15)
    DECLARE @ConcatenatedYears nvarchar(max)
    DECLARE cursorDias CURSOR FOR
    SELECT DiaSemana FROM @Resultados
    OPEN cursorDias
    FETCH NEXT FROM cursorDias INTO @DiaSemana
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ConcatenatedYears = ''
        INSERT INTO @Resultados (DiaSemana, CumpleanosFestejados)
        SELECT
            @DiaSemana,
            @ConcatenatedYears
        UPDATE @Resultados
        SET @ConcatenatedYears = CumpleanosFestejados = COALESCE(CumpleanosFestejados + ', ', '') + CONVERT(nvarchar(4), YEAR(BirthDate))
        FROM Employees
        WHERE DATENAME(dw, BirthDate) = @DiaSemana
        UPDATE @Resultados
        SET CumpleanosFestejados = @ConcatenatedYears
        WHERE DiaSemana = @DiaSemana
        FETCH NEXT FROM cursorDias INTO @DiaSemana
    END
    CLOSE cursorDias
    DEALLOCATE cursorDias
    RETURN;
END
GO
SELECT * FROM dbo.FN_CUMPLEAÑOS()
--drop function dbo.FN_CUMPLEAÑOS 
GO
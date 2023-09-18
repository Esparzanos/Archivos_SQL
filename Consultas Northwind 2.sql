USE Northwind

-- 1
-- CONSULTA CON EL FOLIO, FECHA DE LA ORDEN, NOMBRE DE LA COMPAÑÍA DE ENVIO, 
-- MOSTRAR LOS REGISTROS CUYO AÑO SEA MULTIPLO DE 3 Y EL MES CONTENGA LA LETRA R.
SELECT O.ORDERID AS FOLIO, O.ORDERDATE AS FECHAORDEN, S.COMPANYNAME AS COMPANYNAME
FROM ORDERS O
INNER JOIN SHIPPERS S ON O.SHIPVIA = S.SHIPPERID
WHERE 
    DATEPART(YY, O.ORDERDATE) % 3 = 0 AND
    DATENAME(MM, O.ORDERDATE) LIKE '%R%'
    
-- 2
-- CONSULTA CON EL FOLIO DE LA ORDEN, FECHA Y NOMBRE DEL CLIENTE
-- QUE SE HAYAN REALIZADO LOS DIAS LUNES, MIÉRCOLES Y VIERNES Y 
-- QUE EL CLIENTE VIVA EN UN AVENIDA.
SELECT O.ORDERID AS FOLIO, O.ORDERDATE AS FECHAORDEN, C.CONTACTNAME AS NOMBRECLIENTE
FROM ORDERS O
INNER JOIN CUSTOMERS C ON O.CUSTOMERID = C.CUSTOMERID 
WHERE
    DATEPART(DW, O.ORDERDATE) IN (2,4,6) AND
    C.REGION IS NOT NULL

-- 3
-- CONSULTA CON LAS PRIMERAS 10 ORDENES DE 1997
-- DEL EMPLEADO QUE NACIERON EN LA DECADA DE 1960.
SELECT TOP 10 O.OrderDate AS FECHAORDEN, E.FirstName AS NOMBRE, E.BirthDate AS NACIMIENTO
FROM ORDERS O
INNER JOIN EMPLOYEES E ON O.EMPLOYEEID = E.EMPLOYEEID
WHERE
    DATEPART(YY, O.ORDERDATE) = 1997 AND
    DATEPART(YY, E.BIRTHDATE) BETWEEN 1960 AND 1969
ORDER BY O.ORDERDATE ASC

-- 4
-- CONSULTA CON EL NOMBRE DEL EMPLEADOS Y NOMBRE DE SU JEFE, 
-- MOSTRAR LOS EMPLEADOS QUE SU NOMBRE INICIE CON VOCAL Y 
-- TENGAN UNA REGION ASIGNADA.
SELECT E.EMPLOYEEID, E.FIRSTNAME + ' ' + E.LASTNAME AS EMPLEADO, 
M.FIRSTNAME + ' ' + M.LASTNAME AS JEFE, E.REGION
FROM EMPLOYEES E
LEFT JOIN EMPLOYEES M ON E.REPORTSTO = M.EMPLOYEEID
WHERE E.FIRSTNAME LIKE '[aeiou]%' AND
E.REGION IS NOT NULL

-- 5
-- CONSULTA CON EL NOMBRE DEL PRODUCTO, NOMBRE DEL PROVEEDOR Y 
-- NOMBRE DE LA CATEGORIA. MOSTRAR SOLO LOS PROVEEDORES QUE SU 
-- TELEFONO INICIE CON 0,4 O 5 Y QUE NO TENGAN HOMEPAGE.
SELECT P.PRODUCTNAME AS PRODUCTO, S.CONTACTNAME AS PROVEEDOR, C.CATEGORYNAME AS CATEGORIA
FROM PRODUCTS P
INNER JOIN SUPPLIERS S ON P.SUPPLIERID = S.SUPPLIERID
INNER JOIN CATEGORIES C ON P.CATEGORYID = C.CATEGORYID
WHERE
    S.PHONE LIKE '[045]%' AND
    S.HOMEPAGE IS NULL

-- 6
-- CONSULTA CON EL NOMBRE DEL EMPLEADO Y NOMBRE DEL TERRITORIO 
-- QUE ATIENDE. MOSTRAR SOLO LOS NOMBRE DE EMPLEADO Y TERRITORIOS 
-- QUE EMPIECEN Y TERMINEN CON VOCAL.
SELECT EMPLOYEES.FIRSTNAME + ' ' + EMPLOYEES.LASTNAME AS 'NOMBRE DEL EMPLEADO', 
    TERRITORIES.TERRITORYDESCRIPTION AS 'NOMBRE DEL TERRITORIO'
FROM EMPLOYEES 
INNER JOIN EMPLOYEETERRITORIES ON EMPLOYEES.EMPLOYEEID = EMPLOYEETERRITORIES.EMPLOYEEID
INNER JOIN TERRITORIES ON EMPLOYEETERRITORIES.TERRITORYID = TERRITORIES.TERRITORYID
WHERE (EMPLOYEES.FIRSTNAME + ' ' + EMPLOYEES.LASTNAME) LIKE '[AEIOU]%[AEIOU]' AND
    TERRITORIES.TERRITORYDESCRIPTION LIKE '[AEIOU]%[AEIOU]'

-- 7
SELECT ORDERS.ORDERID AS 'FOLIO DE LA ORDEN', 
    DATEDIFF(MONTH, ORDERS.ORDERDATE, GETDATE()) AS 'MESES TRANSCURRIDOS DE LA ORDEN', 
    EMPLOYEES.FIRSTNAME + ' ' + EMPLOYEES.LASTNAME AS 'NOMBRE DEL EMPLEADO'
FROM ORDERS 
INNER JOIN EMPLOYEES ON ORDERS.EMPLOYEEID = EMPLOYEES.EMPLOYEEID
WHERE EMPLOYEES.COUNTRY = 'USA' AND EMPLOYEES.POSTALCODE LIKE '%2%'

-- 8
SELECT ORDERS.ORDERID AS 'FOLIO DE LA ORDEN', 
    PRODUCTS.PRODUCTNAME AS 'NOMBRE DEL PRODUCTO', 
    [Order Details].UNITPRICE * [Order Details].QUANTITY AS 'IMPORTE DE VENTA'
FROM 
    ORDERS 
INNER JOIN [Order Details] ON ORDERS.ORDERID = [Order Details].ORDERID
INNER JOIN PRODUCTS ON [Order Details].PRODUCTID = PRODUCTS.PRODUCTID
INNER JOIN CATEGORIES ON PRODUCTS.CATEGORYID = CATEGORIES.CATEGORYID
WHERE CATEGORIES.CATEGORYNAME LIKE '%[AEIOU][AEIOU]%' OR CATEGORIES.CATEGORYNAME LIKE '_%[^AEIOU]'


-- 9
-- CONSULTA CON EL NOMBRE DEL EMPLEADO, NOMBRE DEL TERRITORIO QUE ATIENDE. 
-- MOSTRAS SOLO LOS EMPLEADOS QUE EL TERRITORIO ESTE EN UNA REGION 
-- SI SEGUNDA LETRA SEA LA LETRA O.
SELECT E.FirstName AS NOMBRE, T.TerritoryDescription AS TERRITORIO
FROM EMPLOYEES E
INNER JOIN EMPLOYEETERRITORIES ET ON E.EMPLOYEEID = ET.EMPLOYEEID
INNER JOIN TERRITORIES T ON ET.TERRITORYID = T.TERRITORYID
INNER JOIN REGION R ON T.REGIONID = R.REGIONID
WHERE R.REGIONDESCRIPTION LIKE '_O%'


-- 10
SELECT 
    ORDERS.ORDERID AS 'FOLIO DE LA ORDEN', 
    ORDERS.ORDERDATE AS 'FECHA DE LA ORDEN', 
    EMPLOYEES.FIRSTNAME + ' ' + EMPLOYEES.LASTNAME AS 'NOMBRE DEL EMPLEADO',
    DATEDIFF(YEAR, EMPLOYEES.BIRTHDATE, ORDERS.ORDERDATE) AS 'EDAD DEL EMPLEADO AL HACER LA ORDEN'
FROM ORDERS 
INNER JOIN EMPLOYEES ON ORDERS.EMPLOYEEID = EMPLOYEES.EMPLOYEEID
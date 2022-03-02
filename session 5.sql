--Elaheh Toulabi Nejad  9631243 Session5

------------q1
SELECT  Name,
		Europe,
		[North America],
		Pacific
FROM (SELECT P.Name, ST.[Group],P.ProductID from (((Sales.SalesTerritory ST
INNER JOIN Sales.SalesOrderHeader as OH ON OH.TerritoryID=ST.TerritoryID)
INNER JOIN Sales.SalesOrderDetail as OD ON OD.SalesOrderID=OH.SalesOrderID)
INNER JOIN Production.Product as P ON OD.ProductID=P.ProductID)) as st
pivot(
count (ProductID) for [Group] in (Europe,Pacific,[North America]))as PVT

------------q2

SELECT PersonType,
	   M,
	   F
FROM (
SELECT Person.BusinessEntityID, PersonType, Gender
FROM Person.Person join HumanResources.Employee on (Person.BusinessEntityID =
Employee.BusinessEntityID)) as T
Pivot (
count (BusinessEntityID) for Gender in (M,F)) as PVT

-----------q3
SELECT P.Name
FROM Production.Product as P 
WHERE 
	LEN(Name)<15 and SUBSTRING(Name,LEN(Name)-1,1)='e'
 
----------q4


----------q5
IF OBJECT_ID (N'Wanted', N'IF') IS NOT NULL
DROP FUNCTION Wanted;
GO
CREATE FUNCTION Wanted (@year int,@month int, @productName varchar(40))
RETURNS TABLE
AS
RETURN
(
SELECT ST.Name
FROM (((Sales.SalesTerritory ST
INNER JOIN Sales.SalesOrderHeader as OH ON OH.TerritoryID=ST.TerritoryID)
INNER JOIN Sales.SalesOrderDetail as OD ON OD.SalesOrderID=OH.SalesOrderID)
INNER JOIN Production.Product as P ON OD.ProductID=P.ProductID)
WHERE
 YEAR(OH.OrderDate)=@year AND
 MONTH(OH.OrderDate)=@month AND
 P.Name=@productName 
GROUP BY ST.Name HAVING COUNT(ST.Name)>1
);
GO

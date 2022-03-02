--Elaheh Toulabi Nejad  9631243 Session2




-----------q1

SELECT  OH.SalesOrderID,
        OH.RevisionNumber,
        OH.OrderDate,
        OH.DueDate,
        OH.ShipDate,
        OH.[Status],
        OH.OnlineOrderFlag,
        OH.SalesOrderNumber,
        OH.PurchaseOrderNumber,
        OH.AccountNumber,
        OH.CustomerID,
        OH.SalesPersonID,
        OH.TerritoryID,
        T.CountryRegionCode as CountryRegion,
        T.[Group],
        OH.BillToAddressID,
        OH.ShipToAddressID,
        OH.ShipMethodID,
        OH.CreditCardID,
        OH.CreditCardApprovalCode,
        OH.CurrencyRateID,
        OH.SubTotal,
        OH.TaxAmt,
        OH.Freight,
        OH.TotalDue,
        OH.Comment,
        OH.rowguid,
        OH.ModifiedDate
FROM    Sales.SalesOrderHeader as OH LEFT JOIN Sales.SalesTerritory as T ON OH.TerritoryID = T.TerritoryID 
WHERE 
        OH.[Status]='5'
        AND
        OH.SubTotal  BETWEEN 100000 AND 500000 
        AND
        (T.CountryRegionCode = 'FR' OR T.[Group] = 'North America')





----q2

SELECT  OH.SalesOrderID,
        OH.CustomerID,
        OH.SubTotal,
        OH.OrderDate,
        case
        when S.Name is null then 'No Store'
        else S.Name
        end as StoreName
FROM    Sales.SalesOrderHeader OH JOIN  Sales.Customer C ON  OH.CustomerID = C.CustomerID JOIN Sales.Store as S ON s.BusinessEntityID=C.StoreID


-----------q3

SELECT first.ProductID,first.Name,first.[Max],second.CountryRegionCode
FROM
        (SELECT L.ProductID,L.Name,MAX(L.TotalQty)as Max
        FROM (SELECT res.ProductID,res.Name,SUM(res.OrderQty)as TotalQty
        FROM
        (SELECT  P.ProductID , P.Name, D.OrderQty ,OH.TerritoryID,ST.CountryRegionCode
        FROM Production.Product P INNER JOIN Sales.SalesOrderDetail D ON P.ProductID=D.ProductID FULL JOIN Sales.SalesOrderHeader as OH ON OH.SalesOrderID=D.SalesOrderID LEFT JOIN Sales.SalesTerritory as ST ON OH.TerritoryID=ST.TerritoryID)as res
        GROUP BY  res.ProductID,res.Name,res.CountryRegionCode)as L
        GROUP By L.ProductID,L.Name) as first 
INNER JOIN 
        (SELECT res.ProductID,SUM(res.OrderQty)as TotalQty,res.CountryRegionCode
        FROM
        (SELECT  P.ProductID ,D.OrderQty ,OH.TerritoryID,ST.CountryRegionCode
        FROM Production.Product P INNER JOIN Sales.SalesOrderDetail D ON P.ProductID=D.ProductID FULL JOIN Sales.SalesOrderHeader as OH ON OH.SalesOrderID=D.SalesOrderID LEFT JOIN Sales.SalesTerritory as ST ON OH.TerritoryID=ST.TerritoryID)as res
        GROUP BY  res.ProductID,res.CountryRegionCode) as second
ON (first.ProductID = second.ProductID AND first.[Max]=second.TotalQty)
ORDER BY first.ProductID


----use the query below to check the answer
-- SELECT res.ProductID,res.Name,SUM(res.OrderQty)as TotalQty,res.CountryRegionCode
-- FROM
-- (SELECT  P.ProductID , P.Name, D.OrderQty ,OH.TerritoryID,ST.CountryRegionCode
-- FROM Production.Product P INNER JOIN Sales.SalesOrderDetail D ON P.ProductID=D.ProductID FULL JOIN Sales.SalesOrderHeader as OH ON OH.SalesOrderID=D.SalesOrderID LEFT JOIN Sales.SalesTerritory as ST ON OH.TerritoryID=ST.TerritoryID)as res
-- GROUP BY  res.ProductID,res.Name,res.CountryRegionCode
-- ORDER BY res.ProductID ASC





-----------q4

CREATE TABLE NAmerica_Sales (
	SalesOrderID    int primary key NOT NULL,
	OrderDate       DateTime NOT NULL,
	Status          tinyint NOT NULL,
	CustomerID      int NOT NULL foreign key references Sales.Customer(CustomerID),
	TerritoryID     int NOT NULL foreign key references Sales.SalesTerritory(TerritoryID),
	SubTotal        money NOT NULL,
        TotalDue        money NOT NULL
        --but based on original table should be like :
	-- TaxAmt money NOT NULL,
	-- Freight money NOT NULL,
	-- TotalDue  AS (isnull((SubTotal+TaxAmt)+Freight,(0)))
)

INSERT INTO NAmerica_Sales  
SELECT OH.SalesOrderID,OH.OrderDate,OH.[Status],OH.CustomerID,OH.TerritoryID,OH.SubTotal,OH.TotalDue
FROM    Sales.SalesOrderHeader as OH INNER JOIN Sales.SalesTerritory as T ON OH.TerritoryID = T.TerritoryID 
WHERE 
        OH.[Status]='5'
        AND
        OH.SubTotal  BETWEEN 100000 AND 500000 
        AND
        (T.[Group] = 'North America')


ALTER TABLE NAmerica_Sales add TypeOfPrice  CHAR(4) check (TypeOfPrice in ('LOW','Mid','High'))   

UPDATE NAmerica_Sales SET TypeOfPrice = CASE    
                                        WHEN TotalDue <(SELECT AVG(TotalDue) FROM NAmerica_Sales) THEN 'LOW'
                                        WHEN TotalDue =(SELECT AVG(TotalDue) FROM NAmerica_Sales) THEN 'Mid'
                                        ELSE 'High'
                                        END





-----------q5

with h AS (
        SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate 
        FROM HumanResources.EmployeePayHistory 
        GROUP BY BusinessEntityID
)
SELECT  h.BEI,
        CASE 
        WHEN h.MaxRate < ((select max(MaxRate) FROM h )-(select min(MaxRate) FROM h))*0.25 THEN h.MaxRate*1.2
        WHEN h.MaxRate BETWEEN ((select max(MaxRate) FROM h )-(select min(MaxRate) FROM h))*0.25 and ((select max(MaxRate) FROM h )-(select min(MaxRate) FROM h))*0.5 THEN h.MaxRate*1.15
        WHEN h.MaxRate BETWEEN ((select max(MaxRate) FROM h )-(select min(MaxRate) FROM h))*0.5 and ((select max(MaxRate) FROM h )-(select min(MaxRate) FROM h))*0.75 THEN h.MaxRate*1.1
        else h.MaxRate*1.05
        end as NewPay,
        CASE 
        WHEN h.MaxRate <29 THEN '3'
        WHEN h.MaxRate BETWEEN 29 AND 50 THEN '2'
        ELSE '1'
        end as LEVEL
FROM h

--note :
--      max-min = length of range
--       min___length*(1/4)___length*(2/4){mid}___length*(3/4)___max


----without using "with"
SELECT  h.BEI,
        CASE 
        WHEN h.MaxRate < ((select max(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as a)-(select min(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as b))*0.25 THEN h.MaxRate*1.2
        WHEN h.MaxRate BETWEEN ((select max(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as c )-(select min(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as f))*0.25 and ((select max(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as s )-(select min(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as z))*0.5 THEN h.MaxRate*1.15
        WHEN h.MaxRate BETWEEN ((select max(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as d )-(select min(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as g))*0.5 and ((select max(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as v )-(select min(MaxRate) FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate FROM HumanResources.EmployeePayHistory GROUP BY BusinessEntityID) as n))*0.75 THEN h.MaxRate*1.1
        else h.MaxRate*1.05
        end as NewPay,
        CASE 
        WHEN h.MaxRate <29 THEN '3'
        WHEN h.MaxRate BETWEEN 29 AND 50 THEN '2'
        ELSE '1'
        end as LEVEL
FROM (SELECT BusinessEntityID as BEI,MAX(Rate) as MaxRate 
        FROM HumanResources.EmployeePayHistory 
        GROUP BY BusinessEntityID) as h
-- Session 4
-- Elaheh Toulabi Nejad 9631243


--q2

SELECT  CASE  
            WHEN t.Name IS NULL THEN 'All Territries'
            ELSE t.Name
        END as TerritoryName,
        CASE 
            WHEN t.[Group] IS NULL THEN 'All Regions'
            ELSE t.[Group]
        END as Region,
        SUM(h.SubTotal)as SalesTotal,
        COUNT(h.SalesOrderID)as SalesCount
FROM Sales.SalesOrderHeader as h  INNER JOIN  Sales.SalesTerritory as t ON h.TerritoryID=t.TerritoryID
GROUP BY rollup(t.[Group],t.Name)


--q3

SELECT  CASE
            WHEN psc.Name IS NULL THEN 'All Subcategories'
            ELSE psc.Name 
        END as SubCategory,
        CASE 
            WHEN pc.Name IS NULL THEN 'All Categories'
            ELSE pc.Name
        END as Category,
        SUM(d.OrderQty) as SalesCount,
        SUM(d.LineTotal) as SalesTotal
FROM (Sales.SalesOrderHeader as h 
        INNER JOIN Sales.SalesOrderDetail as d ON h.SalesOrderID=d.SalesOrderID
        INNER JOIN Production.Product as p ON d.ProductID=p.ProductID 
        INNER JOIN Production.ProductSubcategory as psc ON p.ProductSubcategoryID=psc.ProductSubcategoryID
        INNER JOIN Production.ProductCategory as pc ON psc.ProductCategoryID=pc.ProductCategoryID
)
GROUP BY rollup(pc.Name,psc.Name)

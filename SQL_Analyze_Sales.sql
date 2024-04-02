-- TIME
-- Revenue by month
SELECT 
    MONTH([OrderDate]) as month,
    SUM([Sales]) as total_revenue
FROM SALES
GROUP BY MONTH([OrderDate])
ORDER BY 1

-- Top 5 months have the highest total revenue
SELECT TOP 5
    MONTH([OrderDate]) as MONTH,
    SUM([Sales]) as total_revenue
FROM SALES
GROUP BY MONTH([OrderDate])
ORDER BY 2 DESC

-- Profit by month
SELECT 
    MONTH([OrderDate]) as MONTH,
    SUM([Sales]) - SUM(Cost) as TOTAL_PROFIT
FROM SALES
GROUP BY MONTH([OrderDate])
ORDER BY 1

-- If the month has a profit, write '(+)', if the month has a loss, write '(-)'
WITH [profit and loss]
AS 
    (SELECT 
        MONTH([OrderDate]) as  [MONTH],
        SUM([Sales]) - SUM(Cost) AS [TOTAL_PROFIT]
    FROM [Sales]
    GROUP BY MONTH([OrderDate])
)
SELECT 
    [MONTH],
    [TOTAL_PROFIT],
    (CASE
    WHEN ([TOTAL_PROFIT]) > 0 THEN '(+)'
        ELSE '(-)'
    END) AS PROFIT_LOSS
FROM [profit and loss]
ORDER BY 1


--  PRODUCT
-- Product sells the most
SELECT TOP 1
SUM(S.[Quantity]) as TOTAL_P,P.[Product]
FROM [dbo].[Sales] as S
LEFT JOIN [dbo].[Product] as P
ON S.[ProductKey] = P.[ProductKey]
GROUP BY P.Product
ORDER BY 1 DESC

-- Product sells the least
SELECT TOP 1
SUM(S.[Quantity]) as TOTAL_P, P.[Product]
FROM [dbo].[Sales] as S
LEFT JOIN [dbo].[Product] as P
ON S.[ProductKey] = P.[ProductKey]
GROUP BY P.Product
ORDER BY 1 ASC

-- Product achieves the highest revenue
SELECT TOP 1
    SUM(S.[SALES]) as TOTAL_REVENUE,
    P.PRODUCT,
    P.Category,
    P.Color,
    P.ProductKey
FROM Sales S
LEFT JOIN [dbo].[Product] P
ON P.[ProductKey] = S.ProductKey
GROUP BY P.PRODUCT, P.PRODUCT,
    P.Category,P.Color,
    P.ProductKey
ORDER BY 1 DESC

-- Product achieves the lowest revenue
SELECT TOP 1
    SUM(S.[SALES]) as TOTAL_REVENUE,
    P.PRODUCT,
    P.Category,
    P.Color,
    P.ProductKey
FROM Sales S
LEFT JOIN [dbo].[Product] P
ON P.[ProductKey] = S.ProductKey
GROUP BY P.PRODUCT, P.PRODUCT,
    P.Category,P.Color,
    P.ProductKey
ORDER BY 1 ASC

-- Which product line has an average revenue classified by Productkey that is above average total revenue to GOOD, 
-- below average to BAD
SELECT 
    (SELECT AVG(SALES) FROM SALES) as AVG_S,
    AVG(Sales) as AVG_S_PRODUCTKEY,
    [ProductKey], 
(CASE
    WHEN AVG(Sales) > (SELECT AVG(SALES) FROM SALES) THEN 'GOOD'
    ELSE 'BAD'
END) as E
FROM SALES
GROUP BY [ProductKey]
ORDER BY 3 

-- How many productkey have "GOOD" state
WITH E as (
    SELECT 
        (CasE
            WHEN AVG(Sales) > (SELECT AVG(SALES) FROM SALES) THEN 'GOOD'
            ELSE 'BAD'
        END) as STATE
    FROM SALES
    GROUP BY ProductKey)
SELECT DISTINCT 
    COUNT(STATE) as QUANTITY,
    STATE 
FROM E 
GROUP BY STATE

--Top 10 products with the highest revenue sorted by color 
SELECT TOP 10
    SUM(S.[SALES]) as TOTAL,
    P.[Product],
    P.[Color]
FROM Sales S
    LEFT JOIN [dbo].[Product] as P
    ON P.[ProductKey] = S.[ProductKey]
GROUP BY  P.[Product], P.[Color]
ORDER BY 1 DESC


--  TERRITORIES
-- Revenue and Number of products sold according to TerritoryKey
SELECT 
    S.[SalesTerritoryKey], 
    R.[Region],
    R.[Country],
    R.[Group],
    SUM(S.[Quantity]) as TOTAL_QUANTITY,
    SUM(S.[SALES]) as TOTAL_REVENUE
FROM Sales as S
LEFT JOIN REGION as R
ON S.SalesTerritoryKey = R.SalesTerritoryKey
GROUP BY  
    S.[SalesTerritoryKey], R.[Region],
    R.[Country], R.[Group]
ORDER BY 1

-- Number of employees by each area
SELECT 
    SPR.SalesTerritoryKey,
    R.[Region],
    R.[Country],
    R.[Group],
    COUNT(SP.[EmployeeKey]) as QUANTITY_EM
FROM [dbo].[Salesperson] as SP
LEFT JOIN [dbo].[SalespersonRegion] as SPR
ON SP.[EmployeeKey] = SPR.EmployeeKey
LEFT JOIN [dbo].[Region] as R
ON SPR.SalesTerritoryKey = R.SalesTerritoryKey
GROUP BY SPR.SalesTerritoryKey,
    R.[Region],
    R.[Country],
    R.[Group]

-- Area has the largest number of employees
SELECT TOP 3
    SPR.SalesTerritoryKey,
    R.[Region],
    R.[Country],
    R.[Group],
    COUNT(SP.[EmployeeKey]) as QUANTITY_EM
FROM [dbo].[Salesperson] as SP
LEFT JOIN [dbo].[SalespersonRegion] as SPR
ON SP.[EmployeeKey] = SPR.EmployeeKey
LEFT JOIN [dbo].[Region] as R
ON SPR.SalesTerritoryKey = R.SalesTerritoryKey
GROUP BY SPR.SalesTerritoryKey,
    R.[Region],
    R.[Country],
    R.[Group]
ORDER BY 5 DESC


--  SALESPERSON
-- Who sells the most products?
SELECT TOP 5
    SUM(S.[QUANTITY]) as TOTAL_QUANTITY,
    S.EmployeeKey,
    SP.[EmployeeID],
    SP.[Salesperson],
    SP.Title
FROM Sales as S
LEFT JOIN [dbo].[Salesperson] as SP
ON S.EmployeeKey = SP.EmployeeKey
GROUP BY S.EmployeeKey, SP.[EmployeeID],
    SP.[Salesperson], SP.Title
ORDER BY 1 DESC

-- Who brings in the highest total revenue
SELECT TOP 5
    SUM(S.[Sales]) as TOTAL_REVENUE,
    S.EmployeeKey,
    SP.[EmployeeID],
    SP.[Salesperson],
    SP.Title
FROM Sales as S
LEFT JOIN [dbo].[Salesperson] as SP
ON S.EmployeeKey = SP.EmployeeKey
GROUP BY S.EmployeeKey, SP.[EmployeeID],
    SP.[Salesperson], SP.Title
ORDER BY 1 DESC

-- Rank employees in each region based on revenue results
SELECT
    DENSE_RANK() OVER (PARTITION BY (S.[SalesTerritoryKey]) ORDER BY SUM(S.[Sales]) DESC) as RANKING,
    SUM(S.[Sales]) as TOTAL_REVENUE,
    S.EmployeeKey,
    SP.[EmployeeID],
    SP.[Salesperson],
    SP.Title,
    S.[SalesTerritoryKey],
    R.[Region],
    R.[Country]
FROM Sales as S
LEFT JOIN Salesperson as SP
ON S.EmployeeKey = SP.EmployeeKey
LEFT JOIN Region as R
ON R.[SalesTerritoryKey] = S.[SalesTerritoryKey]
GROUP BY  S.EmployeeKey,
    SP.[EmployeeID],
    SP.[Salesperson],
    SP.Title,
    S.[SalesTerritoryKey],
    R.[Region],
    R.[Country]






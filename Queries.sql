--Ex1:

select top 5 p.Name, 
       SUM(sod.LineTotal) as [Total Sales]
from Product as p 
join SalesOrderDetail as sod
    on p.ProductID = sod.ProductID
group by p.Name
order by [Total Sales] DESC;

--Explanation: 
--This query retrieves the top 5 products with the highest total sales. 
--It joins the `Product` and `SalesOrderDetail` tables on the `ProductID` and sums the `LineTotal` for each product. 
--The results are grouped by `Product Name` and ordered in descending order of total sales.

----------------------------------------

--Ex2:

select pc.Name, 
       AVG(sod.UnitPrice) as [Average Price]
from SalesOrderDetail sod 
join Product as p 
    on p.ProductID = sod.ProductID 
join ProductSubcategory as psc 
    on p.ProductSubcategoryID = psc.ProductSubcategoryID
join ProductCategory as pc 
    on psc.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
having pc.Name in ('Bikes','Components');

--Explanation: 
--This query calculates the average unit price for products in the 'Bikes' and 'Components' categories. 
--It joins the `SalesOrderDetail`, `Product`, `ProductSubcategory`, and `ProductCategory` tables, 
--grouping by `ProductCategory Name` and filtering for specific categories ('Bikes' and 'Components').

----------------------------------------

--Ex3:

select p.Name, 
       SUM(sod.OrderQty) as [Amount Ordered], 
       pc.Name
from SalesOrderDetail sod 
join Product as p 
    on p.ProductID = sod.ProductID 
join ProductSubcategory as psc 
    on p.ProductSubcategoryID = psc.ProductSubcategoryID
join ProductCategory as pc 
    on psc.ProductCategoryID = pc.ProductCategoryID
group by p.Name, pc.Name
having pc.Name not in ('Clothing','Components');

--Explanation: 
--This query retrieves the amount ordered for each product, 
--excluding those in the 'Clothing' and 'Components' categories. 
--It joins the `SalesOrderDetail`, `Product`, `ProductSubcategory`, and `ProductCategory` tables, 
--grouping by `Product Name` and `Category Name`.

----------------------------------------

--Ex4:

select top 3 st.Name, 
       SUM(soh.TotalDue) as [Sum Of Sales]
from SalesOrderHeader as soh 
join SalesTerritory as st
    on soh.TerritoryID = st.TerritoryID
group by st.Name
order by [Sum Of Sales] DESC;

--Explanation: 
--This query retrieves the top 3 sales territories with the highest total sales. 
--It joins the `SalesOrderHeader` and `SalesTerritory` tables on the `TerritoryID` and sums the `TotalDue` for each territory. 
--The results are grouped by `Territory Name` and ordered in descending order of total sales.

----------------------------------------

--Ex5:

select p.BusinessEntityID,
       p.FirstName+' '+p.LastName as [Full Name], 
       t.[Sum Of Orders]
from Person as p  
right join
    (select c.CustomerID, 
            COUNT(soh.SalesOrderID) as [Sum Of Orders]
     from Customer as c 
     left join SalesOrderHeader as soh  
         on c.CustomerID = soh.CustomerID
     group by c.CustomerID
     having COUNT(soh.SalesOrderID) = 0) as t
on p.BusinessEntityID = t.CustomerID
order by BusinessEntityID;

--Explanation: 
--This query returns the full name of persons who do not have any orders. 
--It uses a `RIGHT JOIN` between the `Person` table and a subquery that counts the orders for each customer. 
--The subquery filters customers who have zero orders. The result is ordered by `BusinessEntityID`.

----------------------------------------

--Ex6:

delete from SalesTerritory 
where TerritoryID = any (
    select st.TerritoryID
    from SalesPerson as sp 
    join SalesTerritory as st
        on sp.TerritoryID = st.TerritoryID
    group by st.TerritoryID
    having COUNT(sp.BusinessEntityID) = 0
);

--Explanation: 
--This query deletes records from the `SalesTerritory` table where there are no associated `SalesPerson` records. 
--It identifies territories with no salespeople and deletes them. 
--(Note: No Territory line deleted as per the results).

----------------------------------------

--Ex7:

--set identity_insert SalesTerritory on;

insert into SalesTerritory 
    ([TerritoryID], [Name], [CountryRegionCode], [Group], [SalesYTD], 
     [SalesLastYear], [CostYTD], [CostLastYear], [rowguid], [ModifiedDate])
    (
        select st.TerritoryID, st.[Name], st.CountryRegionCode, st.[Group], 
               st.SalesYTD, st.SalesLastYear, st.CostYTD, st.CostLastYear, 
               st.rowguid, st.ModifiedDate
        from [AdventureWorks2022].[Sales].[SalesPerson] as sp 
        join [AdventureWorks2022].[Sales].[SalesTerritory] as st
            on sp.TerritoryID = st.TerritoryID
        group by st.TerritoryID, st.[Name], st.CountryRegionCode, 
                 st.[Group], st.SalesYTD, st.SalesLastYear, st.CostYTD, 
                 st.CostLastYear, st.rowguid, st.ModifiedDate
        having COUNT(sp.BusinessEntityID) = 0
    );

--set identity_insert SalesTerritory off;

--Explanation: 
--This query inserts records into the `SalesTerritory` table, using the `SalesTerritory` data for territories with no assigned salespeople. 
--The `set identity_insert` is enabled to allow insertion into an identity column (TerritoryID), and it is turned off after the insertion.

----------------------------------------

--Ex8:

select p.FirstName+' '+p.LastName as [Full Name], 
       t.CustomerID, t.[Num of Orders]
from Person as p 
join 
    (select c.CustomerID, COUNT(soh.SalesOrderID) as [Num of Orders]
     from SalesOrderHeader as soh 
     join Customer as c
         on soh.CustomerID = c.CustomerID 
     group by c.CustomerID
     having COUNT(soh.SalesOrderID) > 20) as t 
on p.BusinessEntityID = t.CustomerID;

--Explanation: 
--This query retrieves the full name, customer ID, and the number of orders for customers who have made more than 20 orders. 
--It joins the `Person` table with a subquery that calculates the number of orders for each customer, filtering for customers with more than 20 orders.

----------------------------------------

--Ex9:

select GroupName, 
       COUNT(DepartmentID) as [Count Of Dep]
from Department
group by GroupName
having COUNT(DepartmentID) > 2;

--Explanation: 
--This query returns the count of departments in each group, but only for groups with more than 2 departments. 
--It groups the result by `GroupName` and filters to include only those groups where the department count is greater than 2.

----------------------------------------

--Ex10:

select p.FirstName+' '+p.LastName as [Full Name], 
       d.Name, s.Name, YEAR(e.HireDate) as [Hire Year], d.GroupName
from Employee as e 
join EmployeeDepartmentHistory edh
    on e.BusinessEntityID = edh.BusinessEntityID 
join Department as d
    on edh.DepartmentID = d.DepartmentID 
join [Shift] as s 
    on edh.ShiftID = s.ShiftID
join Person as p 
    on e.BusinessEntityID = p.BusinessEntityID
where YEAR(e.HireDate) > 2010 
  and (d.GroupName in ('Quality Assurance', 'Manufacturing'));

--Explanation: 
--This query retrieves the full name, department, shift, hire year, and group name for employees hired after 2010, 
--who belong to the 'Quality Assurance' or 'Manufacturing' departments. 
--The results are filtered by the hire year and group name.

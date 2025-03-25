-- Project 2 - Wide World Importers

use WideWorldImporters

-- Ex1: Growth Rate Calculation

-- This query calculates the growth rate of yearly income from sales for each year.
-- The growth rate is based on the difference between the current year's and the previous year's yearly linear income, expressed as a percentage.

select *, convert(DECIMAL(10,2),(YearlyLinearIncome/lag(a.YearlyLinearIncome) over(order by Year)-1)*100) as GrowthRate
from
(select year(OrderDate) as Year, sum(Quantity*UnitPrice) as IncomePerYear,
		count(distinct month(orderdate)) as NumberOfDistinctMonths,
		convert(DECIMAL(10,2),sum(Quantity*UnitPrice)/count(distinct month(orderdate))*12) as YearlyLinearIncome
from Sales.Orders o inner join Sales.Invoices i on o.OrderID=i.OrderID 
		inner join Sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
group by year(OrderDate)) a

----------------------------------------------

-- Ex2: Top 5 Customers by Quarterly Income

-- This query retrieves the top 5 customers by income per quarter for each year. 
-- It ranks customers within each quarter and filters out those ranked higher than 5.


select * from 
	(select YEAR(o.OrderDate) as [TheYear], DATEPART(QUARTER,o.orderDate) as [TheQuarter] ,c.CustomerName, 
				SUM (il.Quantity*il.UnitPrice) as [IncomePerYear],
				dense_rank() over (partition by YEAR(o.OrderDate), DATEPART(QUARTER,o.orderDate) order by SUM (il.Quantity*il.UnitPrice) desc) as [RNK]
	from [Sales].[Orders] as o join [Sales].[Invoices] as i
		on o.OrderID=i.OrderID join [Sales].[InvoiceLines] as il
		on i.InvoiceID=il.InvoiceID join  [Sales].[Customers] as c
		on o.CustomerID=c.CustomerID
		group by YEAR(o.OrderDate), DATEPART(QUARTER,o.orderDate),c.CustomerName) as src
		where src.RNK<=5

----------------------------------------------

-- Ex3: Top 10 Products by Income

-- This query selects the top 10 products (stock items) based on total profit (difference between extended price and tax amount).
-- It ranks the products by sales volume and filters out the top 10.


select src.StockItemID,src.StockItemName,src.TotalProfit
from (
	select si.StockItemID,si.StockItemName, 
			SUM (il.ExtendedPrice-il.TaxAmount) as [TotalProfit],
			dense_rank() over (order by SUM (il.Quantity*il.UnitPrice) desc) as [RNK]
	from [Sales].[Orders] as o join [Sales].[Invoices] as i
	on o.OrderID=i.OrderID join [Sales].[InvoiceLines] as il
	on i.InvoiceID=il.InvoiceID join [Warehouse].[StockItems] as si 
	on il.StockItemID=si.StockItemID
	group by si.StockItemID,si.StockItemName) as src
where RNK<=10;

----------------------------------------------

-- Ex4: Product Profit Ranking

-- This query ranks products by the difference between their recommended retail price and unit price (nominal profit).
-- It includes both row_number and dense rank for the products.


select ROW_NUMBER() over (order by (RecommendedRetailPrice-UnitPrice) desc) as [Rn],
	   StockItemID,StockItemName,UnitPrice,RecommendedRetailPrice,
	   (RecommendedRetailPrice-UnitPrice) as [NominalProductProfit],
	   DENSE_RANK () over (partition by NULL order by (RecommendedRetailPrice-UnitPrice) desc) as [DNR]
from [Warehouse].[StockItems] 
where GETDATE()<=ValidTo;

----------------------------------------------

-- Ex5: Supplier Aggregated Stock Items

-- This query groups suppliers and aggregates the stock items they supply.
-- It lists the stock items for each supplier in a concatenated string, filtered by transactions with quantity greater than or equal to 1.


select CONCAT(s.SupplierID,' - ',s.SupplierName) as [SupplierDetails], STRING_AGG(
        CAST(si.StockItemID AS VARCHAR(MAX)) + ' ' + si.StockItemName, ' /, ' )
		WITHIN GROUP (ORDER BY si.StockItemID) AS AggregatedStockItems
from [Purchasing].[Suppliers] as s join [Warehouse].[StockItems] as si
on s.SupplierID=si.SupplierID join [Warehouse].[StockItemTransactions] as sit
on si.StockItemID=sit.StockItemID
where sit.Quantity>=1
group by s.SupplierID,s.SupplierName;

----------------------------------------------

-- Ex6: Top 5 Customers by Total Sales

-- This query retrieves the top 5 customers based on the total extended price of their orders.
-- It includes customer details like city, country, continent, and region, and sorts by total sales amount.

select top 5 c.CustomerID,ci.CityName,co.CountryName,co.Continent,co.Region,format(SUM(il.ExtendedPrice),'n2') as [TotalExtendedPrice]
from [Sales].[Orders] as o join [Sales].[Invoices] as i
		on o.OrderID=i.OrderID join [Sales].[InvoiceLines] as il
		on i.InvoiceID=il.InvoiceID join  [Sales].[Customers] as c
		on o.CustomerID=c.CustomerID join [Application].[Cities] as ci
		on c.DeliveryCityID=ci.CityID join [Application].[StateProvinces] as sp
		on ci.StateProvinceID=sp.StateProvinceID join [Application].[Countries] as co
		on sp.CountryID=co.CountryID
		group by c.CustomerID,ci.CityName,co.CountryName,co.Continent,co.Region
		order by SUM(il.ExtendedPrice) desc;

----------------------------------------------

-- Ex7: Monthly and Cumulative Sales Total

-- This query calculates both monthly and cumulative sales totals per year and month.
-- It also includes a grand total row for each year and ensures the months are ordered correctly even with "Grand Total" in the results.

select *
from
(select OrderYear, convert(nvarchar,OrderMonth) as OrderMonth, format(MonthlyTotal,'N2') as MonthlyTotal,
		format(CumulativeTotal,'N2') as CumulativeTotal
from
(select *, sum(MonthlyTotal) over(partition by orderyear order by ordermonth rows between
													unbounded preceding and current row) as CumulativeTotal
from
(select year(orderdate) as OrderYear, month(orderdate) as OrderMonth, sum(Quantity*UnitPrice) as MonthlyTotal
from Sales.Orders o inner join Sales.Invoices i on o.OrderID=i.OrderID
		inner join Sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
group by year(orderdate),  month(orderdate))a)b
union all
select OrderYear, OrderMonth, format(MonthlyTotal,'N2') as MonthlyTotal, format(CumulativeTotal,'N2') as CumulativeTotal
from
(select distinct OrderYear, 'Grand Total' as OrderMonth, sum(MonthlyTotal) over(partition by orderyear) as MonthlyTotal,
		sum(MonthlyTotal) over(partition by orderyear) as CumulativeTotal
from
(select year(orderdate) as OrderYear, month(orderdate) as OrderMonth, sum(Quantity*UnitPrice) as MonthlyTotal
from Sales.Orders o inner join Sales.Invoices i on o.OrderID=i.OrderID
		inner join Sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
group by year(orderdate),  month(orderdate))a)b)c
order by OrderYear, case 
					when isnumeric(OrderMonth) = 1 then cast(OrderMonth as int) 
					else 13 end

----------------------------------------------

-- Ex8: Orders Count Pivoted by Year

-- This query generates a pivot table showing the count of orders for each month across different years (2013-2016), 
-- with missing data replaced by zeros.


select OrderMonth, isNull([2013],0) as '2013', isNull([2014],0) as '2014',
	isNull([2015],0) as '2015', isNull([2016],0) as '2016' from (
select YEAR(o.orderDate) as [OrderYear], MONTH(o.OrderDate) as  [OrderMonth], COUNT(o.OrderID) as [CountOrders]
from [Sales].[Orders] as o
group by YEAR(o.orderDate), MONTH(o.OrderDate)) as src
pivot (sum(src.CountOrders) for [OrderYear] in ([2013],[2014],[2015],[2016])) as t


----------------------------------------------

-- Ex9: Customer Churn Analysis

-- This query identifies potential churn customers based on the number of days since their last order compared to the average days between orders.
-- If the days since the last order is more than twice the average, they are labeled as "Potential Churn," otherwise "Active."

-- Approach A:

select CustomerID,CustomerName,OrderDate,PreviousOrderDate,DaysSinceLastOrder, 
avg(a.Diff) over (partition by a.CustomerID) as [AvgDaysBetweenOrders],
case when DaysSinceLastOrder > 2*avg(a.Diff) over (partition by a.CustomerID) then 'Potential Churn'
else 'Active' end as [CustomerStatus]
from 
	(select c.CustomerID, c.CustomerName, o.OrderDate,
			LAG(o.OrderDate) over ( partition by c.customerID order by o.orderDate ) as [PreviousOrderDate],
			DATEDIFF(DAY,(MAX(OrderDate) over (partition by c.customerID)),(select MAX(OrderDate)
			from [Sales].[Customers] as c join [Sales].[Orders] as o
			on c.CustomerID=o.CustomerID)) as [DaysSinceLastOrder],
			DATEDIFF(DAY,LAG(o.OrderDate) over ( partition by c.customerID order by o.orderDate ),o.OrderDate) [Diff]
	from [Sales].[Customers] as c join [Sales].[Orders] as o
		on c.CustomerID=o.CustomerID) as a

--Approach B (Showing without duplicates):

select CustomerID, CustomerName, OrderDate, PreviousOrderDate, DaysSinceLastOrder, AvgDaysBetweenOrders, 
		case when DaysSinceLastOrder>(AvgDaysBetweenOrders*2) then 'Potential Churn'
				else 'Active' end
		as CustomerStatus
from(
	select  *,row_number() over(partition by CustomerID order by PreviousOrderDate desc) as Rn,
			datediff(day,OrderDate,(select max(orderdate) from Sales.Orders)) as DaysSinceLastOrder
	from(
		select CustomerID, CustomerName, OrderDate, PreviousOrderDate,
			(sum(DaysSinceLastOrder) over(partition by customerid))/OrderCount as AvgDaysBetweenOrders
		from(
			select o.CustomerID, c.CustomerName, OrderDate,
				lag(orderdate) over(partition by o.customerid order by orderdate) as PreviousOrderDate,
				datediff(day,lag(orderdate) over(partition by o.customerid order by orderdate),orderdate)
					as DaysSinceLastOrder, count(orderid) over(partition by o.customerid) OrderCount
			from Sales.Orders o inner join Sales.Customers c on o.CustomerID=c.CustomerID
			)a
		)b
	)c
where rn=1

----------------------------------------------

-- Ex10: Customer Distribution Factor

-- This query calculates the distribution factor for customer categories based on the proportion of customers belonging to two specific categories:
-- "Tailspin Toys" and "Wingtip Toys." It expresses this factor as a percentage of the total customer count.

select *, concat(round(cast(DistinctCustomerCount as float)/CAST(TotalCustCount as float)*100,2),' %') as [DistributionFactor]
from (
select cc.CustomerCategoryName,count(distinct 
											case 
											when CustomerName like 'Tailspin Toys%' then 'Tailspin Toys'
											when CustomerName like 'Wingtip Toys%' then 'Wingtip Toys'
											else CustomerName end) as DistinctCustomerCount,
sum(count(distinct case 
            when CustomerName like 'Tailspin Toys%' then 'Tailspin Toys'
            when CustomerName like 'Wingtip Toys%' then 'Wingtip Toys'
            else CustomerName end)) over () as TotalCustCount
from [Sales].[CustomerCategories] as cc join [Sales].[Customers] as c
on cc.CustomerCategoryID=c.CustomerCategoryID
group by cc.CustomerCategoryName
) as a
order by CustomerCategoryName;

--The "Novelty Shop" category presents the highest risk due to customer concentration.
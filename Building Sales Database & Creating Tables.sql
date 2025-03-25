create database Sales;

use Sales;
-------------

--Creating Types

CREATE TYPE [dbo].[AccountNumber] FROM [nvarchar](15) NULL
GO

CREATE TYPE [dbo].[Flag] FROM [bit] NOT NULL
GO

CREATE TYPE [dbo].[Name] FROM [nvarchar](50) NULL
GO

CREATE TYPE [dbo].[NameStyle] FROM [bit] NOT NULL
GO

CREATE TYPE [dbo].[OrderNumber] FROM [nvarchar](25) NULL
GO

CREATE TYPE [dbo].[Phone] FROM [nvarchar](25) NULL
GO


--create table salesTerritory and put input in


CREATE TABLE SalesTerritory
(
	[TerritoryID] [int] IDENTITY(1,1) primary key,
	[Name] [dbo].[Name] NOT NULL,
	[CountryRegionCode] [nvarchar](3) NOT NULL,
	[Group] [nvarchar](50) NOT NULL,
	[SalesYTD] [money] NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[CostYTD] [money] NOT NULL,
	[CostLastYear] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] default getDate() NOT NULL
)

set IDENTITY_INSERT SalesTerritory on
Insert into SalesTerritory([TerritoryID],[Name], [CountryRegionCode], [Group],
	[SalesYTD], [SalesLastYear],[CostYTD], [CostLastYear], [rowguid], [ModifiedDate])
select [TerritoryID],[Name], [CountryRegionCode], [Group],
	[SalesYTD], [SalesLastYear],[CostYTD], [CostLastYear], [rowguid], [ModifiedDate]
from [AdventureWorks2022].[Sales].[SalesTerritory]
set IDENTITY_INSERT SalesTerritory Off

--create table salesPerson and put input in

CREATE TABLE [SalesPerson]
(
	[BusinessEntityID] [int] primary key,
	[TerritoryID] [int] references SalesTerritory(TerritoryID),
	[SalesQuota] [money] NULL,
	[Bonus] [money] default (0.00),
	[CommissionPct] [smallmoney] NOT NULL,
	[SalesYTD] [money] NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)

Insert into SalesPerson([BusinessEntityID], [TerritoryID], [SalesQuota], [Bonus], [CommissionPct],
	[SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate])
select [BusinessEntityID], [TerritoryID], [SalesQuota], [Bonus], [CommissionPct],
	[SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate]
from [AdventureWorks2022].[Sales].[SalesPerson]

--create table customer and put input in
CREATE FUNCTION [dbo].[ufnLeadingZeros](@Value int) 
RETURNS varchar(8) 
WITH SCHEMABINDING 
AS 
BEGIN
    DECLARE @ReturnValue varchar(8);

    SET @ReturnValue = CONVERT(varchar(8), @Value);
    SET @ReturnValue = REPLICATE('0', 8 - DATALENGTH(@ReturnValue)) + @ReturnValue;

    RETURN (@ReturnValue);
END;


CREATE TABLE [Customer]
(
	[CustomerID] [int] IDENTITY(1,1) NOT FOR REPLICATION primary  key,
	[PersonID] [int] NULL,
	[StoreID] [int] NULL,
	[TerritoryID] [int] references SalesTerritory(TerritoryID),
	[AccountNumber]  AS (isnull('AW'+[dbo].[ufnLeadingZeros]([CustomerID]),'')),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)

set IDENTITY_INSERT customer on
Insert into customer(CustomerID,PersonID,StoreID,TerritoryID,rowguid,ModifiedDate)
select CustomerID,PersonID,StoreID,TerritoryID,rowguid,ModifiedDate
from [AdventureWorks2022].[Sales].[Customer]
set IDENTITY_INSERT customer off

--create table cresitCard and put input in
CREATE TABLE [CreditCard]
(
	[CreditCardID] [int] IDENTITY(1,1) primary key,
	[CardType] [nvarchar](50) NOT NULL,
	[CardNumber] [nvarchar](25) NOT NULL,
	[ExpMonth] [tinyint] NOT NULL,
	[ExpYear] [smallint] NOT NULL,
	[ModifiedDate] [datetime] default getdate()
)

set identity_insert creditcard on
Insert into creditCard(CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate)
select CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate
from [AdventureWorks2022].[Sales].[CreditCard]
set identity_insert creditcard off

--create table address and put intput in
CREATE TABLE [Address]
(
	[AddressID] [int] IDENTITY(1,1) NOT FOR REPLICATION primary key,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[PostalCode] [nvarchar](15) NOT NULL,
	[SpatialLocation] [geography] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] default getdate()
)

set identity_insert [address] on
Insert into [address](AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation,
	rowguid, ModifiedDate)
select AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation,
	rowguid, ModifiedDate
from [AdventureWorks2022].[Person].[Address]
set identity_insert address off

--create table shipMethod and put input in
CREATE TABLE [ShipMethod]
(
	[ShipMethodID] [int] IDENTITY(1,1) primary key,
	[Name] [dbo].[Name] NOT NULL,
	[ShipBase] [money] NOT NULL,
	[ShipRate] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] default getdate()
)

set identity_insert shipMethod on
Insert into shipMethod(ShipMethodID, [Name], ShipBase, ShipRate, rowguid, ModifiedDate)
select ShipMethodID, [Name], ShipBase, ShipRate, rowguid, ModifiedDate
from [AdventureWorks2022].[Purchasing].ShipMethod
set identity_insert shipMethod off

--create table CurrencyRate and put input in
CREATE TABLE [CurrencyRate]
(
	[CurrencyRateID] [int] IDENTITY(1,1) primary key,
	[CurrencyRateDate] [datetime] NOT NULL,
	[FromCurrencyCode] [nchar](3) NOT NULL,
	[ToCurrencyCode] [nchar](3) NOT NULL,
	[AverageRate] [money] NOT NULL,
	[EndOfDayRate] [money] NOT NULL,
	[ModifiedDate] [datetime] default getdate()
)

set identity_insert [CurrencyRate] on
Insert into currencyRate(CurrencyRateID, CurrencyRateDate, FromCurrencyCode, ToCurrencyCode, AverageRate, 
	EndOfDayRate, ModifiedDate)
select CurrencyRateID, CurrencyRateDate, FromCurrencyCode, ToCurrencyCode, AverageRate, 
	EndOfDayRate, ModifiedDate
from [AdventureWorks2022].[Sales].[CurrencyRate]
set identity_insert [CurrencyRate] off

--create table salesOrderHeader and put input in


CREATE TABLE [SalesOrderHeader]
(
	[SalesOrderID] [int] IDENTITY(1,1) NOT FOR REPLICATION primary key,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderDate] [datetime] default getdate(),
	[DueDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
	[OnlineOrderFlag] [dbo].[Flag] NOT NULL,
	[SalesOrderNumber]  AS (isnull(N'SO'+CONVERT([nvarchar](23),[SalesOrderID]),N'*** ERROR ***')),
	[PurchaseOrderNumber] [dbo].[OrderNumber] NULL,
	[AccountNumber] [dbo].[AccountNumber] NULL,
	[CustomerID] [int] references Customer(CustomerID) NOT NULL,
	[SalesPersonID] [int] references SalesPerson(BusinessEntityID) NULL,
	[TerritoryID] [int] references salesTerritory(TerritoryID) NULL,
	[BillToAddressID] [int] references [Address](AddressID) NOT NULL,
	[ShipToAddressID] [int] references [Address](AddressID) NOT NULL,
	[ShipMethodID] [int] references ShipMethod(ShipMethodID) NOT NULL,
	[CreditCardID] [int] references CreditCard(CreditCardID) NULL,
	[CreditCardApprovalCode] [varchar](15) NULL,
	[CurrencyRateID] [int] references CurrencyRate(CurrencyRateID) Null,
	[SubTotal] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	[TotalDue]  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
	[Comment] [nvarchar](128) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)

set identity_insert SalesOrderHeader on
Insert into SalesOrderHeader ([SalesOrderID], [RevisionNumber], [OrderDate], [DueDate],
	[ShipDate], [Status], [OnlineOrderFlag], [PurchaseOrderNumber],
	[AccountNumber], [CustomerID], [SalesPersonID], [TerritoryID], [BillToAddressID],
	[ShipToAddressID], [ShipMethodID], [CreditCardID], [CreditCardApprovalCode], [CurrencyRateID],
	[SubTotal], [TaxAmt], [Freight], [Comment], [rowguid], [ModifiedDate])
select [SalesOrderID], [RevisionNumber], [OrderDate], [DueDate],
	[ShipDate], [Status], [OnlineOrderFlag], [PurchaseOrderNumber],
	[AccountNumber], [CustomerID], [SalesPersonID], [TerritoryID], [BillToAddressID],
	[ShipToAddressID], [ShipMethodID], [CreditCardID], [CreditCardApprovalCode], [CurrencyRateID],
	[SubTotal], [TaxAmt], [Freight], [Comment], [rowguid], [ModifiedDate]
from [AdventureWorks2022].[Sales].[SalesOrderHeader]
set identity_insert SalesOrderHeader off

--create table product and put input in
CREATE TABLE [Product]
(
	[ProductID] [int] IDENTITY(1,1) primary key,
	[Name] [dbo].[Name] NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[MakeFlag] [dbo].[Flag] NOT NULL,
	[FinishedGoodsFlag] [dbo].[Flag] NOT NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
)

set identity_insert [product] on
insert into [product]([ProductID], [Name], [ProductNumber], [MakeFlag],
	[FinishedGoodsFlag], [Color], [SafetyStockLevel], [ReorderPoint],
	[StandardCost], [ListPrice], [Size], [SizeUnitMeasureCode], [WeightUnitMeasureCode],
	[Weight], [DaysToManufacture], [ProductLine], [Class], [Style],
	[ProductSubcategoryID], [ProductModelID], [SellStartDate], [SellEndDate],
	[DiscontinuedDate], [rowguid], [ModifiedDate])
select [ProductID], [Name], [ProductNumber], [MakeFlag],
	[FinishedGoodsFlag], [Color], [SafetyStockLevel], [ReorderPoint],
	[StandardCost], [ListPrice], [Size], [SizeUnitMeasureCode], [WeightUnitMeasureCode],
	[Weight], [DaysToManufacture], [ProductLine], [Class], [Style],
	[ProductSubcategoryID], [ProductModelID], [SellStartDate], [SellEndDate],
	[DiscontinuedDate], [rowguid], [ModifiedDate]
from [AdventureWorks2022].[Production].[Product]
set identity_insert [product] off

--create table specialOfferProduct and put input in
CREATE TABLE [SpecialOfferProduct]
(
	[SpecialOfferID] [int] Not null,
	[ProductID] [int] references product(productID),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] default getdate(),
	primary key(specialOfferID,ProductID)
)

Insert into SpecialOfferProduct(SpecialOfferID, ProductID, rowguid, ModifiedDate)
select SpecialOfferID, ProductID, rowguid, ModifiedDate
from [AdventureWorks2022].[Sales].[SpecialOfferProduct]

--create table salesOrderDetail and put input in
CREATE TABLE [SalesOrderDetail]
(
	[SalesOrderID] [int] references SalesOrderHeader(SalesOrderID),
	[SalesOrderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] not null,
	[SpecialOfferID] [int] not null,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal]  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	primary key([SalesOrderID],[SalesOrderDetailID])
)
ALTER TABLE SalesOrderDetail
ADD CONSTRAINT FK_SalesOrderDetails_SpecialOfferProduct
FOREIGN KEY (specialOfferID, productID)
REFERENCES SpecialOfferProduct(specialOfferID, productID)


set identity_insert salesOrderDetail on
Insert into salesOrderDetail(SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty,
	ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
select SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty,
	ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
from [AdventureWorks2022].[Sales].[SalesOrderDetail]
set identity_insert salesOrderDetail off

--create table [ProductCategory] and put input in
CREATE TABLE [ProductCategory]
(
	[ProductCategoryID] [int] IDENTITY(1,1) primary key,
	[Name] [dbo].[Name] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)

set identity_insert [ProductCategory] on
Insert into [ProductCategory](ProductCategoryID, [Name], rowguid, ModifiedDate)
select ProductCategoryID, [Name], rowguid, ModifiedDate
from AdventureWorks2022.Production.ProductCategory
set identity_insert [ProductCategory] off

--create tbale [ProductSubcategory] and put input in
CREATE TABLE [ProductSubcategory](
	[ProductSubcategoryID] [int] IDENTITY(1,1) primary key,
	[ProductCategoryID] [int] references [Productcategory]([ProductCategoryID]) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
)

set identity_insert ProductSubcategory on
Insert into ProductSubcategory(ProductSubcategoryID, ProductCategoryID, [Name], rowguid, ModifiedDate)
select ProductSubcategoryID, ProductCategoryID, [Name], rowguid, ModifiedDate
from [AdventureWorks2022].[Production].[ProductSubcategory]
set identity_insert ProductSubcategory off

--fix fk in table [product]
ALTER TABLE [Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_ProductSubcategory_ProductSubcategoryID] FOREIGN KEY([ProductSubcategoryID])
REFERENCES [ProductSubcategory] ([ProductSubcategoryID])


CREATE TABLE [Person](
	[BusinessEntityID] [int] primary key,
	[PersonType] [nchar](2) NOT NULL,
	[NameStyle] [dbo].[NameStyle] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailPromotion] [int] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)

insert into person([BusinessEntityID],	[PersonType], [NameStyle], [Title], [FirstName],
	[MiddleName], [LastName], [Suffix],	[EmailPromotion], [rowguid], [ModifiedDate])
select [BusinessEntityID],	[PersonType], [NameStyle], [Title], [FirstName],
	[MiddleName], [LastName], [Suffix],	[EmailPromotion], [rowguid], [ModifiedDate]
from AdventureWorks2022.Person.Person

--add fk to customer
ALTER TABLE [Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Person_PersonID] FOREIGN KEY([PersonID])
REFERENCES [Person] ([BusinessEntityID])

--create table and [Department] put input in
CREATE TABLE [Department](
	[DepartmentID] [smallint] IDENTITY(1,1) primary key,
	[Name] [dbo].[Name] NOT NULL,
	[GroupName] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
)

set identity_insert [Department] on
Insert into department(DepartmentID, [Name], GroupName, ModifiedDate)
select DepartmentID, [Name], GroupName, ModifiedDate
from AdventureWorks2022.HumanResources.Department
set identity_insert [Department] off

--create table shift and put input in
CREATE TABLE [Shift](
	[ShiftID] [tinyint] IDENTITY(1,1) primary key,
	[Name] [dbo].[Name] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
)

set identity_insert [shift] on
Insert into [shift](ShiftID, [Name], StartTime,  EndTime, ModifiedDate)
select ShiftID, [Name], StartTime,  EndTime, ModifiedDate
from AdventureWorks2022.HumanResources.Shift
set identity_insert [shift] off

--create table [Employee] and put input in
CREATE TABLE [Employee](
	[BusinessEntityID] [int] references person(BusinessEntityID) primary key,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[LoginID] [nvarchar](256) NOT NULL,
	[OrganizationNode] [hierarchyid] NULL,
	[OrganizationLevel]  AS ([OrganizationNode].[GetLevel]()),
	[JobTitle] [nvarchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar](1) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[HireDate] [date] NOT NULL,
	[SalariedFlag] [dbo].[Flag] NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[CurrentFlag] [dbo].[Flag] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
	)

Insert into employee([BusinessEntityID], NationalIDNumber, [LoginID], [OrganizationNode], [JobTitle], [BirthDate],
	[MaritalStatus], [Gender], [HireDate], [SalariedFlag], [VacationHours], [SickLeaveHours],
	[CurrentFlag], [rowguid], [ModifiedDate])
select [BusinessEntityID], NationalIDNumber, [LoginID], [OrganizationNode], [JobTitle], [BirthDate],
	[MaritalStatus], [Gender], [HireDate], [SalariedFlag], [VacationHours], [SickLeaveHours],
	[CurrentFlag], [rowguid], [ModifiedDate]
from AdventureWorks2022.HumanResources.Employee

--create table [EmployeeDepartmentHistory] and put input in
CREATE TABLE [EmployeeDepartmentHistory](
	[BusinessEntityID] [int] references [Employee]([BusinessEntityID]) NOT NULL,
	[DepartmentID] [smallint] references [Department]([DepartmentID]) NOT NULL,
	[ShiftID] [tinyint] references [shift]([ShiftID]) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	primary key([BusinessEntityID], [StartDate], [DepartmentID], [ShiftID])
	)

Insert into EmployeeDepartmentHistory(BusinessEntityID, DepartmentID, ShiftID, StartDate, EndDate, ModifiedDate)
select BusinessEntityID, DepartmentID, ShiftID, StartDate, EndDate, ModifiedDate
from AdventureWorks2022.HumanResources.EmployeeDepartmentHistory

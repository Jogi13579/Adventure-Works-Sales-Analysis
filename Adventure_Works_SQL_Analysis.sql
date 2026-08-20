CREATE DATABASE AdventureWorks;
USE AdventureWorks;

-- To see the count of rows of all the imported tables (Whether the rows have been imported successfully or not?) -- 

select count(*) from dimcustomer;
select count(*) from dimdate;
select count(*) from dimproduct;
select count(*) from dimproductcategory;
select count(*) from dimproductsubcategory;
select count(*) from dimsalesterritory;
select count(*) from fact_internet_sales_new;
select count(*) from factinternetsales;

-- UNION --

CREATE TABLE FactSales_Combined 
AS
SELECT * FROM FactInternetSales
UNION ALL
SELECT * FROM Fact_Internet_Sales_New;

SELECT COUNT(*) FROM FactSales_Combined;

-- PRODUCT NAME --

ALTER TABLE FactSales_Combined
ADD COLUMN ProductName VARCHAR(255);

UPDATE FactSales_Combined FSC
JOIN DimProduct DP
ON FSC.ProductKey = DP.ProductKey
SET FSC.ProductName = DP.EnglishProductName;

SELECT ProductKey, ProductName
FROM FactSales_Combined
LIMIT 10;

-- CUSTOMER FULL NAME --

UPDATE FactSales_Combined FSC
JOIN DimCustomer DC
ON FSC.CustomerKey = DC.CustomerKey
SET FSC.CustomerFullName =
TRIM(CONCAT(DC.FirstName,' ',IFNULL(CONCAT(DC.MiddleName, ' '), ''),DC.LastName));

SELECT CustomerKey, CustomerFullName 
FROM FactSales_Combined
LIMIT 10;

-- UNIT PRICE --

ALTER TABLE FactSales_Combined
ADD COLUMN ProductUnitPrice DECIMAL(10,2);

UPDATE FactSales_Combined FSC
JOIN DimProduct DP
ON FSC.ProductKey = DP.ProductKey
SET FSC.ProductUnitPrice = DP.ListPrice;

SELECT ProductKey, ProductUnitPrice 
FROM FactSales_Combined
LIMIT 10;

--  DATE FIELD (OrderDate)   --

ALTER TABLE FactSales_Combined
MODIFY COLUMN OrderDate DATE;

UPDATE FactSales_Combined
SET OrderDate = STR_TO_DATE(OrderDateKey, '%Y%m%d');

SELECT OrderDateKey,
OrderDate
FROM FactSales_Combined
LIMIT 10;

-- YEAR --

ALTER TABLE FactSales_Combined
ADD COLUMN Year INT;

UPDATE FactSales_Combined
SET Year = YEAR(OrderDate);

SELECT OrderDate, Year FROM FactSales_Combined LIMIT 20;

-- MONTH NO --

ALTER TABLE FactSales_Combined
ADD COLUMN MonthNo INT;

UPDATE FactSales_Combined
SET MonthNo = MONTH(OrderDate);

SELECT OrderDate, MonthNo
FROM FactSales_Combined
LIMIT 20;

-- MONTH FULL NAME --

ALTER TABLE FactSales_Combined
ADD COLUMN MonthFullName VARCHAR(20);

UPDATE FactSales_Combined
SET MonthFullName = MONTHNAME(OrderDate);

SELECT OrderDate, MonthFullName FROM FactSales_Combined LIMIT 20;

-- QUARTER(Q1,Q2,Q3,Q4) --

ALTER TABLE FactSales_Combined
ADD COLUMN Quarter VARCHAR(2);

UPDATE FactSales_Combined
SET Quarter = CONCAT('Q', QUARTER(OrderDate));

SELECT OrderDate, Quarter FROM FactSales_Combined LIMIT 20;

-- YEAR MONTH (YYYY-MMM) --

ALTER TABLE FactSales_Combined
ADD COLUMN YearMonth VARCHAR(8);

UPDATE FactSales_Combined
SET YearMonth = DATE_FORMAT(OrderDate, '%Y-%b');

SELECT OrderDate, YearMonth FROM FactSales_Combined LIMIT 20;

-- WEEK DAY NO --

ALTER TABLE FactSales_Combined
ADD COLUMN WeekDayNo INT;

UPDATE FactSales_Combined
SET WeekDayNo = WEEKDAY(OrderDate) + 1;

SELECT OrderDate, WeekDayNo FROM FactSales_Combined LIMIT 20;

-- WEEK DAY NAME --

ALTER TABLE FactSales_Combined
ADD COLUMN WeekDayName VARCHAR(20);

UPDATE FactSales_Combined
SET WeekDayName = DAYNAME(OrderDate);

SELECT OrderDate, WeekDayName FROM FactSales_Combined LIMIT 20;

-- FINANCIAL MONTH --

ALTER TABLE FactSales_Combined
ADD COLUMN FinancialMonth INT;

UPDATE FactSales_Combined
SET FinancialMonth =
CASE
WHEN MONTH(OrderDate) >= 4 THEN MONTH(OrderDate) - 3
ELSE MONTH(OrderDate) + 9
END;

SELECT OrderDate, FinancialMonth FROM FactSales_Combined LIMIT 20;

-- FINANCIAL QUARTER --

ALTER TABLE FactSales_Combined
ADD COLUMN FinancialQuarter VARCHAR(2);

UPDATE FactSales_Combined
SET FinancialQuarter =
CASE
WHEN MONTH(OrderDate) BETWEEN 4 AND 6 THEN 'Q1'
WHEN MONTH(OrderDate) BETWEEN 7 AND 9 THEN 'Q2'
WHEN MONTH(OrderDate) BETWEEN 10 AND 12 THEN 'Q3'
ELSE 'Q4'
END;

SELECT OrderDate, FinancialQuarter FROM FactSales_Combined LIMIT 20;

-- SALES AMOUNT --

Select UnitPrice, OrderQuantity, UnitPriceDiscountPct, SalesAmount as ExistingSalesAmount, 
UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct) AS CalculatedSalesAmount 
FROM FactSales_Combined 
LIMIT 20;

SELECT
    UnitPrice,
    OrderQuantity,
    UnitPriceDiscountPct,
    UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct) AS CalculatedSalesAmount
FROM FactSales_Combined;

-- PRODUCTION COST --

SELECT ProductStandardCost, OrderQuantity, 
TotalProductCost AS ExistingProductionCost, 
ProductStandardCost * OrderQuantity AS CalculatedProductionCost
FROM FactSales_Combined
LIMIT 20;

SELECT ProductStandardCost, OrderQuantity, 
ProductStandardCost * OrderQuantity AS ProductionCost
FROM FactSales_Combined
LIMIT 20;

-- PROFIT -- 

ALTER TABLE FactSales_Combined
ADD COLUMN Profit DECIMAL(18,2);

UPDATE FactSales_Combined
SET Profit = SalesAmount - TotalProductCost;

SELECT SalesAmount, TotalProductCost, Profit FROM FactSales_Combined LIMIT 20;

































 

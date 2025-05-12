Create database Adventure_work;
#Q0
CREATE TABLE Sales AS
SELECT *
FROM Fact_Internet_Sales
WHERE 1 = 0;  # where 1 = 0 ensures only table sutucture is copied not the data.

INSERT INTO Sales
SELECT *
FROM fact_internet_sales
UNION ALL
SELECT *
FROM fact_internet_sales_new;
Select * from sales;
#Q1
Select sales.*,dimproduct.EnglishProductName FROM
sales
INNER JOIN
dimproduct
ON
sales.ProductKey = dimproduct.ProductKey;

#Q2
ALTER TABLE dimcustomer
ADD CustomerName Varchar(100);

UPDATE dimcustomer
SET CustomerName = CONCAT(FirstName, ' ', COALESCE(MiddleName, ''), ' ', LastName);

Select sales.*,dimcustomer.CustomerName,dimproduct.Unitprice FROM
sales
INNER JOIN
dimcustomer
ON 
sales.CustomerKey = dimcustomer.CustomerKey
INNER JOIN
dimproduct
ON
sales.ProductKey = dimproduct.ProductKey;

#Q3
ALTER TABLE sales
ADD DateField DATE;

UPDATE sales
SET DateField = STR_TO_DATE(OrderDateKey, '%Y%m%d');

#A 
ALTER TABLE sales
ADD Years int;
UPDATE sales
SET Years = YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d'));

#B
ALTER TABLE sales
ADD Monthno int;
UPDATE sales
SET Monthno = MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d'));

#C
ALTER TABLE sales
ADD MonthFullName Varchar(20);
UPDATE sales
SET MonthFullName = DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%M');
select * from sales;
#D 
ALTER TABLE sales
ADD Quarters Varchar(5);
UPDATE sales
SET Quarters = CONCAT('Q',QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d')));

#E 
ALTER TABLE sales
ADD YearMonth VARCHAR(10);
UPDATE sales
SET YearMonth = DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%b');

#F
ALTER TABLE sales
ADD WeekdayNo INT;
UPDATE sales
SET WeekdayNo = (WEEKDAY(STR_TO_DATE(OrderDateKey, '%Y%m%d')) + 1) % 7 + 1;

#G 
ALTER TABLE sales
ADD WeekdayName Varchar(15);
UPDATE sales
SET WeekdayName = DAYNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d'));

#H 
ALTER TABLE sales
ADD FinancialMonth INT;
UPDATE sales
SET FinancialMonth = (MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) + 9) % 12 + 1;  #In India Financial Month starts from month of April.

select * from sales LIMIT 1000000;
#I 
ALTER TABLE sales
ADD FinancialQuarter INT;
UPDATE sales
SET FinancialQuarter = CASE
    WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) IN (4, 5, 6) THEN 1  #In India Financial Month starts from month of April.
    WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) IN (7, 8, 9) THEN 2
    WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) IN (10, 11, 12) THEN 3
    WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) IN (1, 2, 3) THEN 4
END;

#4
ALTER TABLE sales
ADD SalesAmount_calc DECIMAL(10, 2);
UPDATE sales
SET SalesAmount_calc = OrderQuantity * UnitPrice * (1 - UnitPriceDiscountPct);

#5
ALTER TABLE sales
ADD ProductionCost DECIMAL(10, 2);
UPDATE sales
SET ProductionCost = OrderQuantity * UnitPrice;


#6
ALTER TABLE sales
ADD Profit DECIMAL(10, 2);
UPDATE sales
SET Profit = SalesAmount - (TotalProductCost + TaxAmt + Freight);

#7
SELECT 
	YEAR(DateField) AS Year,
	MonthFullName AS Month,
	ROUND(SUM(SalesAmount_calc),2) AS TotalSales
FROM 
sales
WHERE 
YEAR(DateField) = 2013   
GROUP BY 
YEAR(DateField), MonthFullName
ORDER BY 
MonthFullName;
    
#8
SELECT 
	YEAR(DateField) AS Years,
	ROUND(SUM(SalesAmount_calc),2) AS TotalSales
FROM 
sales
GROUP BY 
YEAR(DateField)
ORDER BY 
Years;

#9
SELECT 
	Month(DateField) AS Month_no,
    MonthFullName,
	ROUND(SUM(SalesAmount_calc),2) AS TotalSales
FROM 
sales
GROUP BY 
Month(DateField),MonthFullName
ORDER BY 
Month_no,MonthFullName;

#10
SELECT 
    Quarters,
	ROUND(SUM(SalesAmount_calc),2) AS TotalSales
FROM 
sales
GROUP BY 
Quarters
ORDER BY 
Quarters;

#11
Select
YEAR(DateField) AS Years,
ROUND(SUM(SalesAmount_calc),2) AS Total_Sales,
ROUND(SUM(TotalProductCost),2) AS Production_Cost
From
sales
GROUP BY
YEAR(DateField);

#12
# TOP 5 Product Highest sales
SELECT 
    EnglishProductName,
    ROUND(SUM(SalesAmount_calc),2) AS TotalSales
FROM 
sales
INNER JOIN
dimproduct
ON
sales.ProductKey = dimproduct.ProductKey
GROUP BY 
EnglishProductName
ORDER BY 
ROUND(SUM(SalesAmount_calc),2) DESC
LIMIT 5;  

#TOP 10 Customer with Highest Purchase Amount
SELECT 
	CustomerName,
    ROUND(SUM(SalesAmount_calc),2) AS TotalSales
FROM
sales
INNER JOIN
dimcustomer
ON 
sales.CustomerKey = dimcustomer.CustomerKey
GROUP BY
CustomerName
ORDER BY
ROUND(SUM(SalesAmount_calc),2) DESC
LIMIT 10;
	
#Region wise Highest Sales
SELECT
	SalesTerritoryRegion AS Region,
    ROUND(SUM(SalesAmount_calc),2) AS TotalSales
FROM
sales
INNER JOIN
dimsalesterritory
ON
sales.SalesTerritoryKey = dimsalesterritory.SalesTerritoryKey
GROUP BY
SalesTerritoryRegion
ORDER BY 
ROUND(SUM(SalesAmount_calc),2) DESC;


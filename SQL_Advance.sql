

use DataWarehouseAnalytics;

-- SQL TASK 

-- Analyze Sales Performance 

select * from gold.dim_products;
select * from gold.dim_customers;
select * from gold.fact_sales;

-- Change over time Trend Analysis

-- 1 - Find the Total Sales amount for each order date 

select order_date, sum(sales_amount) as Total_sales
from gold.fact_sales
where order_date is not null
group by order_date
order by order_date;


-- 2 - Find the Total Sales amount for each Year

select 
year(order_date) as order_year, 
sum(sales_amount) as Total_sales
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);


-- 3 - Find the Total Sales amount for each Year and Count of customers over the time

select 
year(order_date) as order_year, 
sum(sales_amount) as Total_Sales,
count(Distinct customer_key) as Total_Customers
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);


-- 4 - Find the Total Sales amount and Total Quantity for each Year and Count of customers over the time

select 
year(order_date) as order_year, 
sum(sales_amount) as Total_Sales,
count(Distinct customer_key) as Total_Customers,
sum(quantity) as Total_Quantity
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);



-- 5 - Find the Total Sales amount and Total Quantity for each Month and Count of customers over the time

-- Detailed insight to discover the seasonality for our business and trend pattern 

select 
Month(order_date) as order_Month, 
sum(sales_amount) as Total_Sales,
count(Distinct customer_key) as Total_Customers,
sum(quantity) as Total_Quantity
from gold.fact_sales
where order_date is not null
group by Month(order_date)
order by Month(order_date);


-- 6 - Find the Total Sales amount and Total Quantity for each Month and Count of customers over the time


select 
year(order_date) as order_year,
Month(order_date) as order_Month, 
sum(sales_amount) as Total_Sales,
count(Distinct customer_key) as Total_Customers,
sum(quantity) as Total_Quantity
from gold.fact_sales
where order_date is not null
group by year(order_date), Month(order_date)
order by year(order_date), Month(order_date);


select 
Datetrunc(MONTH,order_date) as order_date,
sum(sales_amount) as Total_Sales,
count(Distinct customer_key) as Total_Customers,
sum(quantity) as Total_Quantity 
from gold.fact_sales
where order_date is not null
group by Datetrunc(MONTH,order_date)
order by Datetrunc(MONTH,order_date);


-- How many customer were added each year 

select DATETRUNC(YEAR, create_date) as create_year, 
COUNT(customer_key) as total_customer
from gold.dim_customers
group by DATETRUNC(YEAR, create_date)
order by DATETRUNC(YEAR, create_date);


-- Cumulative Analysis -- Use of Window Functions
-- Aggregate the data progressively over time. 
-- Helps to understand whether our business is growing or declining

-- Running Total Sales by Year
-- Moving Average of Sales by Month


-- Calulate the total sales per Month and the running total of sales over time 

select 
order_date, 
Total_Sales, 
sum(Total_Sales) over(order by order_date) as running_Total_Sales
from 
(
select 
datetrunc(Month, order_date) as order_Date,
sum(sales_amount) as Total_Sales
from gold.fact_sales
where order_date is not null
group by datetrunc(Month, order_date)
) t; 


select 
Order_Date, 
Total_Sales, 
sum(Total_Sales) over(partition by order_date order by order_date) as Running_Total_Sales
from 
(
select 
datetrunc(Month, order_date) as Order_Date,
sum(sales_amount) as Total_Sales
from gold.fact_sales
where order_date is not null
group by datetrunc(Month, order_date)
) t; 


-- Calulate the total sales per Year and the running total of sales over time 

select Order_date, Total_Sales,
sum(Total_Sales) over(order by order_date) as Running_total_sales
from
(
select 
DATETRUNC(year, order_date) as Order_date,
sum(sales_amount) as Total_Sales
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year, order_date)
) t;


-- Calulate the total sales per Year and the Moveing Average sales over year

select Order_date, Total_Sales, avgrage,
sum(Total_Sales) over(order by order_date) as Running_total_sales,
avg(avgrage) over(order by order_date) as Running_total_sales
from
(
select 
DATETRUNC(year, order_date) as Order_date,
sum(sales_amount) as Total_Sales,
avg(sales_amount) as avgrage
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year, order_date)
) t;


-- Calulate the total sales per Year and the Moveing Average sales over month

-- Calulate the total sales per Year and the Moveing Average sales over year

select Order_date, Total_Sales,
sum(Total_Sales) over(order by Order_date) as Running_total_sales,
 Avgrage,
avg(Avgrage) over(order by Order_date) as Moving_Average_sales
from
(
select 
DATETRUNC(month, order_date) as Order_date,
sum(sales_amount) as Total_Sales,
avg(sales_amount) as Avgrage
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month, order_date)
) t;


SELECT 
    Order_date, 
    Total_Sales,
    SUM(Total_Sales) OVER (ORDER BY Order_date) AS Running_total_sales,
    AVG(Total_Sales) OVER (ORDER BY Order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Moving_Average_sales
FROM (
    SELECT 
        DATETRUNC(month, order_date) AS Order_date,
        SUM(sales_amount) AS Total_Sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t
ORDER BY Order_date;


SELECT 
    Order_date, 
    Total_Sales,
    SUM(Total_Sales) OVER (ORDER BY Order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Running_6Month_Sales
FROM (
    SELECT 
        DATETRUNC(month, order_date) AS Order_date,
        SUM(sales_amount) AS Total_Sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) 
t ;


-- Performance Analysis 
-- This is the process of comparing the current value to target value to a target value of specific category.
-- Helps measure success and compare 


-- Year-Over-Year Sales Analysis 
with yearly_product_sales as 
(
select 
YEAR(f.order_date) as Order_year,
p.product_name,
SUM(f.sales_amount) as Current_Sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key 
where f.order_date is not null
group by YEAR(f.order_date), p.product_name
)
select Order_year, product_name, Current_Sales, 
AVG(Current_Sales) over(partition by product_name) as avg_sales,
Current_Sales - AVG(Current_Sales) over(partition by product_name) as avg_difference,
CASE 
WHEN Current_Sales - AVG(Current_Sales) over(partition by product_name) > 0 THEN 'Above Avg'
WHEN Current_Sales - AVG(Current_Sales) over(partition by product_name) < 0 THEN 'Below Avg'
else 'Avg'
end 'Avg_chage',
lag(Current_Sales) over(partition by product_name order by Order_year) as Previous_Year_sales,
Current_Sales - lag(Current_Sales) over(partition by product_name order by Order_year) as Diffrence_Year,
CASE 
WHEN Current_Sales - lag(Current_Sales) over(partition by product_name order by Order_year) > 0 THEN 'Increase'
WHEN Current_Sales - lag(Current_Sales) over(partition by product_name order by Order_year) < 0 THEN 'Decrease'
ELSE 'No_Change'
END AS Pay_Change
from yearly_product_sales
order by product_name, Order_year;


-- Part to whole Analysis ( Propotional Analysis )

-- analyze how an individual part is performing compared to the overall, 
-- allowing us to undrstand which categoory has bthe greatest impact on the business

-- Which category contribute the most to overall sales ? 

select p.category,
sum(f.sales_amount) as Total_Sales
from gold.fact_sales f
join gold.dim_products p
on f.product_key = p.product_key
group by p.category;


with category_sales as 
(
select p.category as Category,
sum(f.sales_amount) as Total_Sales
from gold.fact_sales f
join gold.dim_products p
on f.product_key = p.product_key
group by p.category
) 
select 
Category, 
Total_Sales, 
sum(Total_Sales) over() as Over_All_Sales,
Concat(Round((Cast (Total_Sales as float) / sum(Total_Sales) over())*100,2), '%')  as Percentage_of_total
from category_sales
order by Percentage_of_total desc;




use DataWarehouseAnalytics;
select * from gold.fact_sales;
select * from gold.dim_products;
select * from gold.dim_customers;


-- Data Segmentation 
-- Group the data based on a specific range help understand the correlation between two measures.

-- Segment products into cost range and count how many products fall into segment 


select 
product_name, 
cost,
case when cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 500 AND 10000 THEN '500-1000'
     ELSE '1000 Above'
	 END COST_RANGE
 from gold.dim_products;



SELECT 
   COST_RANGE,
   COUNT(product_name) AS COUNT_OF_Product
   from 
(
select 
product_name, 
cost,
case when cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE '1000 Above'
	 END COST_RANGE
 from gold.dim_products) AS B
 group by COST_RANGE
 order by COUNT_OF_Product desc;


-- Group the customers into three segment based on their sending behavior
   -- VIP: Customer with at least 12 month history and spending more then $5000. 
   -- Regular: Customer with at least 12 month history and spending more then $5000 or less. 
   -- New: Customer lifespan less than 12 months.
   -- also find the number of customer in each group


select c.customer_key,
sum(f.sales_amount) as Total_sales,
case when sum(f.sales_amount) > 5000 then 'VIP Customer'
	 when sum(f.sales_amount) < 5000 then 'Regular Customer'
	 else 'New'
	 end COST_RANGE
from gold.dim_customers c
left join gold.fact_sales f
on c.customer_key = f.customer_key
group by customer_id
;


select c.customer_key,
sum(f.sales_amount) as total_sales,
min(f.order_date) as Min_date,
max(f.order_date) as Max_date,
DATEDIFF(month, min(f.order_date), max(f.order_date)) as Lifespan
from gold.dim_customers c
left join gold.fact_sales f
on c.customer_key = f.customer_key
group by c.customer_key
;


with Customer_spending as
(
select c.customer_key,
sum(f.sales_amount) as total_spend,
min(f.order_date) as Min_date,
max(f.order_date) as Max_date,
DATEDIFF(month, min(f.order_date), max(f.order_date)) as Lifespan
from gold.dim_customers c
left join gold.fact_sales f
on c.customer_key = f.customer_key
group by c.customer_key
) 
select customer_key, Lifespan, total_spend,
case when Lifespan > 12 and total_spend > 5000 then 'VIP Customer'
	 when Lifespan > 12 and total_spend < 5000 then 'Regular Customer'
	 else 'New'
	 end Customer_Segment
	 from Customer_spending;
	 
-- Simple Query 

with Customer_spending as
(
select c.customer_key,
sum(f.sales_amount) as total_spend,
min(f.order_date) as Min_date,
max(f.order_date) as Max_date,
DATEDIFF(month, min(f.order_date), max(f.order_date)) as Lifespan
from gold.dim_customers c
left join gold.fact_sales f
on c.customer_key = f.customer_key
group by c.customer_key
) 
select 
case when Lifespan > 12 and total_spend > 5000 then 'VIP Customer'
	 when Lifespan > 12 and total_spend < 5000 then 'Regular Customer'
	 else 'New'
	 end as Customer_Segment,
	 count(customer_key) as Total_customer
	 from Customer_spending
	 group by case when Lifespan > 12 and total_spend > 5000 then 'VIP Customer'
	 when Lifespan > 12 and total_spend < 5000 then 'Regular Customer'
	 else 'New'
	 end;


-- Complex Query but easy to understand

with Customer_spending as
(
select c.customer_key,
sum(f.sales_amount) as total_spend,
min(f.order_date) as Min_date,
max(f.order_date) as Max_date,
DATEDIFF(month, min(f.order_date), max(f.order_date)) as Lifespan
from gold.dim_customers c
left join gold.fact_sales f
on c.customer_key = f.customer_key
group by c.customer_key
) 
select Customer_Segment, count(customer_key) as No_of_customer from
(
select case when Lifespan > 12 and total_spend > 5000 then 'VIP Customer'
	 when Lifespan > 12 and total_spend < 5000 then 'Regular Customer'
	 else 'New'
	 end as Customer_Segment,
	 customer_key
	 from Customer_spending ) as b
	 group by Customer_Segment
	 order by No_of_customer desc;


-- Make the Report 
/*
===================================================================================================================================
Customer Report
===================================================================================================================================
Purpose
 - This report consolidates key customer metrics and behaviors 
 
Highlights:

      1. Gathers essential fields such as names, ages, and transaction details.
	  
	  2. Segments customer into categories (VIP, Regular, New) and Age groups.
	  
	  3. Aggregates customer-level metrics:
	     - Total Sales 
		 - Total Orders
		 - Total Products
		 - Total Quantities Purchased 
		 - Lifespan (in Months)

      4. Calulates valuable KPI's 
	     - Recency (Month Since last order)
		 - Average order value
		 - Average Monthly spend

===================================================================================================================================
*/

-- ================================================================================================================================
-- 1 - Base Query: Retrives core columns from Tables 
-- ================================================================================================================================
select * from gold.fact_sales
select * from gold.dim_customers
select * from gold.dim_products

CREATE VIEW gold.report_customer as 
WITH basequery as 
(
select f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
f.price,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ', c.last_name) as Customer_Name,
c.country,
c.gender,
datediff(year, c.birthdate, GETDATE()) as Age
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
where f.order_date is not null)
,customer_aggregation as (
select 
customer_key,
customer_number,
Customer_Name,
Age,
COUNT(Distinct order_number) as Total_Order,
Sum(sales_amount) AS Total_Seles,
Sum(quantity) as Total_Quantity,
Count(Distinct product_key) as Total_Products,
Max(order_date) as last_order,
Datediff(Month, Min(order_date), Max(order_date)) as Lifespan
from basequery
group by customer_key,
customer_number,
Customer_Name,
Age
)
select customer_key,
customer_number,
Customer_Name,
Age,
CASE WHEN Age < 20 THEN 'Under 20'
     WHEN Age between 20 and 29 THEN '20-29'
	 WHEN Age between 30 and 39 THEN '30-39'
	 WHEN Age between 40 and 49 THEN '40-49'
	 Else 'Above 50'
END as 'Age_group',
CASE WHEN Lifespan >= 12 AND Total_Seles > 5000 THEN 'VIP'
     WHEN Lifespan >= 12 AND Total_Seles <= 5000 THEN 'Regular'
	 Else 'New'
END as 'Customer_Segment',
last_order,
DATEDIFF(MONTH, last_order, GETDATE() ) AS Recency,
CASE WHEN Total_Seles = 0 THEN 0
     ELSE (Total_Seles / Total_Order) 
END as Average_order_value,
CASE WHEN Lifespan = 0 THEN 0
     ELSE Total_Seles/ Lifespan
END AS Average_Monthly_spend,
Total_Order,
Total_Products,
Total_Quantity,
Total_Seles
from customer_aggregation;

-- Check the View
select * from gold.report_customer


/*
===================================================================================================================================
Product Report
===================================================================================================================================
Purpose
 - This report consolidates key Product metrics and behaviors 
 
Highlights:

      1. Gathers essential fields such as Product Name, Category, subcategory and cost.
	  
	  2. Segments Product by revenue to identify High-Performance, Mid-Range or Low-Performance.
	  
	  3. Aggregates Customer-level metrics:
	     - Total Sales 
		 - Total Orders
		 - Total Quantity Sold
		 - Total Customers (Unique)
		 - Lifespan (in Months)

      4. Calulates valuable KPI's 
	     - Recency (Month Since last Sale)
		 - Average Order Revenue (AOR)
		 - Average Monthly Revenue

===================================================================================================================================
*/

-- Create an SQL View to Provide Product Insight.

select * 
from gold.fact_sales f 
left join gold.dim_products p 
on f.product_key = p.product_key

CREATE VIEW gold.report_product as
WITH PRODUCT AS (
select 
      f.order_number,
	  f.product_key,
	  f.customer_key,
	  f.order_date,
	  f.shipping_date,
	  f.sales_amount,
	  f.quantity,
	  f.price,
	  p.product_number,
	  p.product_name,
	  p.category,
	  p.subcategory,
	  p.cost
	  from gold.fact_sales f 
           left join gold.dim_products p 
          on f.product_key = p.product_key
where order_date is not null),
Product_aggregation as 
(
SELECT 
         product_number,
		 product_key,
	     product_name,
	     category,
	     subcategory,
		 cost,
	     SUM(sales_amount) AS  Total_Sales, 
		 count(Distinct order_number) AS Total_Orders,
		 		 sum(quantity) AS Total_Quantity_Sold,
		 count(Distinct customer_key) AS Total_Customers,
		 Max(order_date) as Last_order_date,
		 DATEDIFF(Month, Min(order_date), Max(order_date)) AS Lifespan,
		 ROUND(avg(cast(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) as avg_selling_price
		 from PRODUCT
		 group by 
		 product_number, product_name, product_key, category, subcategory, cost)
    	Select 
		 product_number,
		 product_key,
	     product_name,
	     category,
	     subcategory,
		 DATEDIFF(Month, Last_order_date, GETDATE()) as Recency,
		 Case When Total_Sales >  50000 THEN 'High_Performance'
		      When Total_Sales >= 10000 THEN 'Mid_Range'
		      ELSE 'Low_Performance'
	    END Segment_Product,
		 Lifespan,
		 Last_order_date,
		 cost,
		 avg_selling_price,
		 Total_Quantity_Sold,
		 Total_Customers,
		 Total_Orders,
		 Total_Sales,

-- Avg_ORDER_Revenue
		 CASE WHEN Total_Orders = 0 THEN 0
		      ELSE  Total_Sales / Total_Orders
		 END as Avg_Order_Revenue,

-- Avg_Monthly_Revenue
		 CASE WHEN Lifespan = 0 THEN 0
		      ELSE Total_Sales / Lifespan
		 END as Avg_Monthly_Revenue

from Product_aggregation;
		 
select * from [gold].[report_product]	 


select category,
	   	   subcategory,
count(product_name) as Total_product, 
       sum(total_sales) as total_sales,
	   sum(Total_Quantity_Sold) as Total_Quantity
from gold.report_product
group by category, subcategory
order by category;

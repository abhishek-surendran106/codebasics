-- 1. Provide the list of markets in which customer  "Atliq  Exclusive"  operates its in the  APAC  region. 
select distinct market from dim_customer where customer = "Atliq Exclusive" and region = "APAC";

-- 2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, 
-- unique_products_2020 
-- unique_products_2021 
-- percentage_chg
with 2020_year as
(select count(distinct product_code) as 2020_products from fact_manufacturing_cost where cost_year = 2020),
2021_year as
(select count(distinct product_code) as 2021_products from fact_manufacturing_cost where cost_year = 2021)
select 2020_products as unique_products_2020, 2021_products as unique_products_2021, 
round((2021_products - 2020_products)*100 / 2020_products,2) as percentage_chg
from (2020_year, 2021_year);

-- 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains 2 fields, 
-- segment 
-- product_count 
select segment, count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count desc;

-- 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields, 
-- segment 
-- product_count_2020 
-- product_count_2021 
-- difference
with year_2020 as
(select dm.segment, count(distinct dm.product_code) as cnt_2020
from dim_product dm join
fact_manufacturing_cost fmc on dm.product_code = fmc.product_code
where fmc.cost_year = 2020
group by dm.segment),
year_2021 as
(select dm.segment, count(distinct dm.product_code) as cnt_2021
from dim_product dm join
fact_manufacturing_cost fmc on dm.product_code = fmc.product_code
where fmc.cost_year = 2021
group by dm.segment)
select year_2020.segment,
year_2020.cnt_2020 as product_count_2020,
year_2021.cnt_2021 as product_count_2021, 
year_2021.cnt_2021 - year_2020.cnt_2020 as difference
from (year_2020, year_2021);

-- 5.  Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields, 
-- product_code 
-- product 
-- manufacturing_cost
select 
dm.product_code, 
dm.product, 
fmc.manufacturing_cost 
from dim_product dm join 
fact_manufacturing_cost fmc on dm.product_code = fmc.product_code
where fmc.manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost)
union
select 
dm.product_code, 
dm.product, 
fmc.manufacturing_cost 
from dim_product dm join 
fact_manufacturing_cost fmc on dm.product_code = fmc.product_code
where fmc.manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost);

-- 6. Generate a report which contains the top 5 customers who received an average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
-- Indian  market. The final output contains these fields, 
-- customer_code 
-- customer 
-- average_discount_percentage 
select dc.customer_code, dc.customer, avg(fpid.pre_invoice_discount_pct) as average_discount_percentage from 
dim_customer dc join 
fact_pre_invoice_deductions fpid on dc.customer_code = fpid.customer_code
where fpid.fiscal_year = 2021
and dc.market = "India"
group by dc.customer_code, dc.customer
order by average_discount_percentage desc
limit 5;

-- 7. Get the complete report of the Gross sales amount for the customer  “Atliq Exclusive”  for each month.  This analysis helps to get an idea of low and 
-- high-performing months and take strategic decisions. The final report contains these columns: 
-- Month 
-- Year 
-- Gross sales Amount
select monthname(fsm.date) as month,
year(fsm.date) as year,
round(sum(fsm.sold_quantity * fgp.gross_price),2) as Gross_Sales_Amount
from dim_customer dc 
join fact_sales_monthly fsm on dc.customer_code = fsm.customer_code
join fact_gross_price fgp on fsm.product_code = fgp.product_code
where dc.customer = "Atliq Exclusive" 
group by month, year;

-- 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity, 
-- Quarter 
-- total_sold_quantity 
select quarter(date) as quarter, 
count(sold_quantity) as total_sold_quantity 
from fact_sales_monthly fsm
where year(date) = 2020
group by quarter
order by total_sold_quantity desc;

-- 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?  The final output  contains these fields, 
-- channel 
-- gross_sales_mln 
-- percentage
with T1 as
(select dc.channel, 
round(sum(fsm.sold_quantity * fgp.gross_price),2) as gross_sales_mln from 
dim_customer dc join
fact_sales_monthly fsm on dc.customer_code = fsm.customer_code
join fact_gross_price fgp on fsm.product_code = fgp.product_code
where year(date) = 2021
group by dc.channel)
select T1.channel, 
T1. gross_sales_mln, 
round((T1.gross_sales_mln / (select sum(gross_sales_mln) from T1)) * 100, 2)  as percentage from T1;

-- 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields, 
-- division 
-- product_code 
-- product 
-- total_sold_quantity 
-- rank_order
with T1 as
(select dp.division, dp.product_code, dp.product, sum(fsm.sold_quantity) as total_sold_quantity from 
dim_product dp join
fact_sales_monthly fsm on dp.product_code = fsm.product_code
where year(date) = 2021
group by dp.division, dp.product_code, dp. product),
T2 as
(select *, row_number() over (partition by division order by total_sold_quantity desc) as rank_order
from T1)
select * from T2 
where rank_order <=3












 


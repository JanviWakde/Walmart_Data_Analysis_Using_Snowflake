create file format walmart_csv_format
type = 'csv'
field_delimiter = ','
skip_header = 1;

create stage walmart_stage
file_format = walmart_csv_format;

create stage walmart_stage;

desc stage walmart_stage;

create stage walmart_stage
directory = ( enable = true );

use database walmart_db;

create table walmart_sale0 (
 invoice_id string,
 branch string,
 city string,
 customer_type string,
 gender string,
 product_line string,
 unit_price number(10,2),
 quantity int,
 tax_5_per number(10,2),
 total number(10,2),
 sales_date date,
 sales_time time,
 payment string,
 cogs number(10, 2),
 gross_margin_per number (5,2),
 gross_income number(10,2),
 rating number (3,1)
);

copy into walmart_sale0
FROM @walmart_stage
file_format = (format_name = walmart_csv_format);

select * from walmart_sale0;

// Cleaning 
select count(*)
from walmart_sale0
where unit_price is null;

select count(*)
from walmart_sale0
where sales_date is null;

// Modeling
create table dim_branch as
select distinct branch, city
from walmart_sale0;

create table dim_product as
select distinct product_line
from walmart_sale0;

create table fact_sales as
select invoice_id, branch, product_line, quantity, total, sales_date, payment
from walmart_sale0;

// Total sales
select sum(total) as total_sales
from walmart_sale0;

// Sales by branch
select branch, sum(total) as branch_sales
from walmart_sale0
group by branch
order by branch_sales desc;

// Top 5 product by sales
select product_line, sum(total) as product_sales,
  rank() over (order by sum(total) desc) as ranking
from walmart_sale0
group by product_line
limit 5;

// Sales by customer_type
select customer_type, sum(total) as sales
from walmart_sale0
group by customer_type;

// Monthly sales
select month(sales_date) as month, sum(total) as monthly_sales
from walmart_sale0
group by month(sales_date)
order by month;

// Customer segmentation
select gender, sum(total) as sales
from walmart_sale0
group by gender;

// Payment method
select payment, sum(total) as sales
from walmart_sale0
group by payment;

// Avg rating by product
select product_line, avg(rating) as avg_rating
from walmart_sale0
group by product_line;

// Avg order value per branch
select branch, avg(total) as avg_total
from walmart_sale0
group by branch;

// View
create view vw_monthly_sales as
select month(sales_date) as month, sum(total) as sales
from fact_sales
group by month;

select * from vw_monthly_sales;

select * from df_orders
 
 DROP TABLE  df_orders;

CREATE TABLE df_orders (
  [order_id] int PRIMARY KEY,
  [order_date] date,
  [ship_mode] varchar(20),
  [segment] varchar(20),
  [country] varchar(20),
  [city] varchar(20),
  [state] varchar(20),
  [postal_code] varchar(20),
  [region] varchar(20),
  [category] varchar(20),
  [sub_category] varchar(20),
  [product_id] varchar(50),
  [quantity] int,
  [discount] decimal(7,2),
  [sale_price] decimal(7,2),
  [profit] decimal(7,2)
)

Select * from df_orders

-----Find the top 10 highest revenue generating products

select top 10 product_id, sum(sale_price)as revenues from df_orders
group by product_id
order by sum(sale_price)desc


-----Find top 5 highest selling products in each region(quantity wise).

with highestselling as(
select product_id,sum(quantity)as total_quantity,region, row_number() over(partition by region order by sum(quantity)desc) as rn from df_orders
group by region, product_id) 
select product_id, total_quantity,region
from highestselling 
where rn <= 5
order by region, rn


----Find month over month comparision for 2022 and 2023 sales

WITH total AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price * quantity) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,-----will give the sales of 2022 and 2023
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023,
	CASE--------will give the growth percentage
	  WHEN SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) = 0 THEN NULL
	  ELSE
	   (SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) - SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END))*100.0/SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END)
	   END AS Growth_rate
 FROM total
 GROUP BY order_month
 ORDER BY order_month;


---For each category which month had highest sales?
select * from df_orders

with total  as (select category, sum(quantity*sale_price) as total_sales, month(order_date) as month_wise, 
row_number() over(partition by category order by sum(quantity*sale_price)desc)rnk
from df_orders
group by category, month(order_date)
)
select  t.category,t.total_sales from total t
where t.rnk = 1
order by t.total_sales desc

---Which sub category had highest growth by profit in 2023 compare to 2022?

with highest as (select sub_category, sum(profit) as growth, year(order_date) as year_wise,
row_number() over(partition by sub_category order by year(order_date))rnk
from df_orders
group by sub_category, year(order_date)),
growth as(select y2022.sub_category, y2022.growth as profit_2022, y2023.growth as profit_2023,
(y2023.growth- y2022.growth)as highest_growth
from highest y2022 left join highest y2023 -------use of self join with highest cte
on y2022.sub_category=y2023.sub_category
and y2022.year_wise = 2022
and y2023.year_wise = 2023)
select top 1 sub_category, highest_growth,profit_2022, profit_2023 from growth
order by  highest_growth desc 



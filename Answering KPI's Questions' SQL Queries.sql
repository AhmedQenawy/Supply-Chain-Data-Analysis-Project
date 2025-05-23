--1
/*1*/
SELECT 
    AVG(DATEDIFF(DAY, [order date (DateOrders)], [shipping date (DateOrders)])) AS AvgShippingTime
FROM 
    [Suply chain].[dbo].[Orders]
WHERE 
    [shipping date (DateOrders)] IS NOT NULL 
    AND [order date (DateOrders)] IS NOT NULL

/*2*/
 
SELECT 
  [Order ID], 
  [Order Customer ID],
  [order date (DateOrders)] AS OrderDate,
  [shipping date (DateOrders)] AS ShippingDate,
  DATEDIFF(DAY, [order date (DateOrders)], [shipping date (DateOrders)]) AS ShippingTimeInDays
FROM 
  [Suply chain].[dbo].[Orders]

/*3*/
SELECT 
  [Shipping Mode],
  AVG(DATEDIFF(DAY, [order date (DateOrders)], [shipping date (DateOrders)])) AS AvgShippingTime
FROM 
  [Suply chain].[dbo].[Orders]
GROUP BY 
  [Shipping Mode]
ORDER BY 
  AvgShippingTime DESC

/*4*/

SELECT 
  [Category id],
  AVG(DATEDIFF(DAY, [order date (DateOrders)], [shipping date (DateOrders)])) AS AvgShippingTime
FROM 
  [Suply chain].[dbo].[Orders]
GROUP BY 
  [Category id]
ORDER BY 
  AvgShippingTime DESC

-- 2: 

select count(*) as total_orders,
sum(case when days_for_shipping_real = days_for_shipment_scheduled then 1 else 0 end) as on_schedule,
round(100.0 * sum(case when days_for_shipping_real = days_for_shipment_scheduled then 1 else 0 end) / count(*), 2) as schedule_accuracy_percentage
from [s.orders] o

select round(100.0 * sum(case when days_for_shipping_real <= days_for_shipment_scheduled then 1 else 0 end) / count(*), 2) as on_or_before_percentage
from [s.orders] o

select d.department_name, count(*) as underperform_count,
round(100.0 * sum(case when days_for_shipping_real > days_for_shipment_scheduled then 1 else 0 end) / count(*), 2) as underperform_percentage
from [s.orders] o
join [s.departments] d on o.department_id = d.department_id
group by d.department_name
order by underperform_percentage desc

-- 3:

select count(*) as total_orders, 
sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as high_risk_orders,
round(100.0 * sum(case when o.late_delivery_risk = 1 then 1 else 0 end) / count(*), 2) as high_risk_percentage
from [s.orders] o

select c.customer_segment, sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as high_risk_orders
from [s.orders] o
join [s.customers] c on o.order_customer_id = c.customer_id
group by c.customer_segment
order by high_risk_orders desc

select d.department_name, sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as high_risk_orders
from [s.orders] o
join [s.departments] d on o.department_id = d.department_id
group by d.department_name
order by high_risk_orders desc

-- 4: 
select case 
    when o.days_for_shipping_real < o.days_for_shipment_scheduled then 'early'
    when o.days_for_shipping_real = o.days_for_shipment_scheduled then 'on time'
    else 'late'
    end as delivery_status, 
    count(*) as total_orders,
    round(100.0 * count(*) / (select count(*) from [s.orders]), 2) as percentage
from [s.orders] o
group by case 
    when o.days_for_shipping_real < o.days_for_shipment_scheduled then 'early'
    when o.days_for_shipping_real = o.days_for_shipment_scheduled then 'on time'
    else 'late' 
    end

select o.shipping_mode, 
round(100.0 * sum(case when o.days_for_shipping_real <= o.days_for_shipment_scheduled then 1 else 0 end) / count(*), 2) as on_time_percentage
from [s.orders] o
group by o.shipping_mode
order by on_time_percentage desc

select o.order_region, 
round(100.0 * sum(case when o.days_for_shipping_real <= o.days_for_shipment_scheduled then 1 else 0 end) / count(*), 2) as on_time_percentage
from [s.orders] o
group by o.order_region
order by on_time_percentage desc

-- 5:
select d.department_name, o.order_total_profit
from [s.orders] o
join [s.departments] d on o.department_id = d.department_id
group by d.department_name
order by o.order_total_profit desc

select d.department_name, sum(o.order_total_profit) as total_profit
from [s.orders] o
join [s.departments] d on o.department_id = d.department_id
where o.order_total_profit < 0
group by d.department_name

select year(o.order_date_dateorders) as year, month(o.order_date_dateorders) as month, sum(o.order_total_profit) as total_profit
from [s.orders] o
group by year(o.order_date_dateorders), month(o.order_date_dateorders)
order by year, month

--6

/*1*/
SELECT 
  AVG(Sales) AS AvgSalesPerCustomer,
  AVG(Profit) AS AvgBenefitPerCustomer
FROM (
  SELECT 
    [Order Customer id],
    SUM([Order Total Sales]) AS Sales,
    SUM([Order Total Profit]) AS Profit
  FROM 
    [Suply chain].[dbo].[Orders]
  GROUP BY 
   [Order Customer id]
) AS CustomerSummary


/*2*/

SELECT 
  [Order Customer id],
  SUM([Order Total Profit]) AS TotalProfit
FROM 
  [Suply chain].[dbo].[Orders]
GROUP BY 
   [Order Customer id]
ORDER BY 
  TotalProfit DESC

/*3*/

SELECT 
  [Order Customer id],
  SUM([Order Total Profit]) AS TotalProfit
FROM 
  [Suply chain].[dbo].[Orders]
GROUP BY 
  [Order Customer id]
HAVING 
  SUM([Order Total Profit]) < 0


/*4*/

SELECT 
    [Order Customer id],
    COUNT([Order ID]) AS OrderCount,
    SUM([Order Total Profit]) AS TotalProfit,
    AVG([Order Total Profit]) AS AvgProfitPerOrder
FROM 
    [Suply chain].[dbo].[Orders]
GROUP BY 
    [Order Customer id]
ORDER BY 
    OrderCount DESC


--7

/*1*/
SELECT 
    [Order Customer id],
    SUM([Order Total Sales]) AS TotalSales
FROM 
    [Suply chain].[dbo].[Orders]
GROUP BY 
    [Order Customer id]
ORDER BY 
    TotalSales DESC

/*2*/

SELECT 
    [Order Customer id],
    SUM([Order Total Sales]) AS TotalSales
FROM 
    [Suply chain].[dbo].[Orders]
GROUP BY 
    [Order Customer id]
ORDER BY 
    TotalSales DESC

/*3*/

SELECT 
    [Order Customer id],
    SUM([Order Total Sales]) AS TotalSales,
    SUM([Order Total Profit]) AS TotalProfit,
    ROUND(SUM([Order Total Profit]) * 1.0 / NULLIF(SUM([Order Total Sales]), 0), 2) AS ProfitMargin
FROM 
    [Suply chain].[dbo].[Orders]
GROUP BY 
    [Order Customer id]
ORDER BY 
    ProfitMargin ASC;


-- 8: 
select g.category_name, sum(o.order_total_sales) as total_sales
from [s.categories] g, [s.orders] o
group by g.category_name
order by total_sales desc

select g.category_name, sum(o.order_total_sales) as total_sales,
sum(o.order_total_profit) as total_profit,
round(100.0 * sum(o.order_total_profit) / sum(o.order_total_sales), 2) as profit_margin
from [s.categories] g, [s.orders] o
group by g.category_name
order by profit_margin desc

-- 9: department performance index (departmental profit tracker)
select d.department_name, sum(o.order_total_profit) as total_profit 
from [s.departments] d, [s.orders] o
group by d.department_name 
order by total_profit desc 

select d.department_name, count(*) as total_orders, sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as high_risk_orders, round(100.0 * sum(case when o.late_delivery_risk = 1 then 1 else 0 end) / count(*), 2) as risk_percentage
from [s.orders] o, [s.departments] d
group by d.department_name
order by risk_percentage desc

select d.department_name, count(*) as total_orders, sum(case when o.late_delivery_risk = 0 then 1 else 0 end) as ontime_deliveries, round(100.0 * sum(case when o.late_delivery_risk = 0 then 1 else 0 end) / count(*), 2) as ontime_percentage
from [s.orders] o, [s.departments] d
group by d.department_name
order by ontime_percentage desc

-- 10: market sales comparison (market revenue benchmarking)
select o.market, sum(o.order_total_sales) as total_sales
from [s.orders] o
group by o.market
order by total_sales desc

select o.market, sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as late_orders
from [s.orders] o
group by o.market
order by late_orders desc

select o.market, sum(o.order_total_profit) as total_profit, sum(o.order_total_sales) as total_sales
from [s.orders] o
group by o.market
order by total_profit, total_sales desc

-- 11: geographic sales concentration (regional revenue mapping)
select o.market, o.order_city, o.order_country, sum(o.order_total_sales) as total_sales
from [s.orders] o
group by o.market, o.order_city, o.order_country
order by total_sales desc

select o.order_region, count(*) [no. of orders], sum(o.order_total_sales) as total_sales
from [s.orders] o
group by o.order_region
order by total_sales, [no. of orders] desc

select o.order_region, sum(o.order_total_sales) total_sales,
sum(case when o.late_delivery_risk = 0 then 1 else 0 end) on_time
from [s.orders] o
group by o.order_region
order by total_sales desc

-- 12: customer segment sales distribution (segment revenue ratio)
select c.customer_segment, sum(o.order_total_sales) as total_sales
from [s.orders] o
join [s.customers] c on o.order_customer_id = c.customer_id
group by c.customer_segment 
order by total_sales desc

select c.customer_segment, avg(o.order_total_sales) as avg_total_sales
from [s.orders] o
join [s.customers] c on o.order_customer_id = c.customer_id
group by c.customer_segment 
order by avg_total_sales desc

select c.customer_segment, sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as late_order
from [s.orders] o
join [s.customers] c on o.order_customer_id = c.customer_id
group by c.customer_segment 
order by late_order desc

select c.customer_segment, sum(o.order_total_profit) as total_profit
from [s.orders] o
join [s.customers] c on o.order_customer_id = c.customer_id
group by c.customer_segment 
order by total_profit desc

--13

/*1*/
SELECT 
    AVG([Order Item Quantity]) AS AverageOrderItemQuantity
FROM 
    [Suply chain].[dbo].[Order Items]

/*2*/

SELECT 
    o.[Order Customer id],
    o.[Department id],
    AVG(oi.[Order Item Quantity]) AS Average_Quantity,
    MAX(oi.[Order Item Quantity]) AS Max_Quantity,
    COUNT(*) AS Item_Count
FROM 
    [Suply chain].[dbo].[Orders] o
JOIN 
    [Suply chain].[dbo].[Order Items] oi
    ON o.[Order ID] = oi.[Order ID]
GROUP BY 
    o.[Department id], o.[Order Customer id]
ORDER BY 
    Average_Quantity DESC

/*3*/


SELECT 
    CASE 
        WHEN oi.[Order Item Quantity] >= 10 THEN 'High Quantity'
        ELSE 'Low Quantity'
    END AS Order_Size,
    AVG(DATEDIFF(DAY, o.[order date (DateOrders)], o.[shipping date (DateOrders)])) AS Avg_Shipping_Delay
FROM 
    [Suply chain].[dbo].[Orders] o
JOIN 
    [Suply chain].[dbo].[Order Items] oi
    ON o.[Order ID] = oi.[Order ID]
GROUP BY 
    CASE 
        WHEN oi.[Order Item Quantity] >= 10 THEN 'High Quantity'
        ELSE 'Low Quantity'
    END




-- 14: discount effectiveness impact (promotion outcome tracker)
select oi.order_item_discount, avg(oi.order_profit_per_order) as avg_profit, avg(oi.sales) as avg_sales
from [s.order items] oi
group by oi.order_item_discount
order by oi.order_item_discount

select d.department_name, p.product_name, avg(oi.order_item_discount) avg_discount, sum(oi.order_profit_per_order) profit
from [s.departments] d
join [s.order items] oi on d.department_id = oi.department_id
join [s.products] p on oi.order_item_product_id = p.product_id
group by d.department_name, p.product_name
order by avg_discount, profit desc 

select oi.order_item_discount_rate, avg(oi.order_item_quantity) as avg_quantity, avg(oi.order_profit_per_order) as avg_profit, sum(oi.order_profit_per_order) as total_profit
from [s.order items] oi
group by oi.order_item_discount_rate
order by oi.order_item_discount_rate desc

-- 15: payment method usage distribution (transaction type spectrum)
select o.type, count(*) as [no. of order] 
from [s.orders] o
group by o.type
order by [no. of order] desc

select o.type, count(*) as [no. of order], sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as late_order
from [s.orders] o
group by o.type
order by late_order desc 

select o.type, sum(o.order_total_profit) as total_profit, sum(o.order_total_sales) as total_sales
from [s.orders] o
group by o.type
order by total_profit, total_sales desc

select o.type, o.market, count(*) as [no. of order] 
from [s.orders] o
group by o.type, o.market
order by [no. of order] desc





-- 17: order frequency by location (order density map)
select o.order_city, o.order_country, count(*) as [no. of orders]
from [s.orders] o
group by o.order_city, o.order_country
order by [no. of orders] desc 

select o.order_city, count(*) as [no. of orders], round(avg(o.order_total_profit), 2) as avg_profit
from [s.orders] o
group by o.order_city
order by avg_profit, [no. of orders]

select o.order_city, count(*) as total_orders, sum(o.order_total_profit) as total_profit, round(avg(o.order_total_profit), 2) as avg_profit_per_order
from [s.orders] o
group by o.order_city
having count(*) < 50
order by avg_profit_per_order desc

--18 
/*1*/

SELECT 
    c.[Customer City], 
    COUNT(*) AS Total_Orders,
    SUM(o.[Order Total Profit]) AS Total_Profit,
    AVG(o.[Order Total Profit]) AS Avg_Profit_Per_Order
FROM 
    [Suply chain].[dbo].[Orders] o
JOIN 
    [Suply chain].[dbo].[Customers] c 
    ON o.[Order Customer id] = c.[Customer ID]
GROUP BY 
    c.[Customer City]
ORDER BY 
    Total_Profit DESC

/*2*/
SELECT 
    c.[Customer City],
    COUNT(*) AS Total_Orders,
    AVG(DATEDIFF(DAY, o.[order date (DateOrders)], o.[shipping date (DateOrders)])) AS Avg_Shipping_Delay
FROM 
    [Suply chain].[dbo].[Orders] o
JOIN 
    [Suply chain].[dbo].[Customers] c 
    ON o.[Order Customer id] = c.[Customer ID]
GROUP BY 
    c.[Customer City]
ORDER BY 
    Avg_Shipping_Delay DESC

-- 19: impact of delays on profitability (profit leakage triggers)
select case when o.late_delivery_risk = 1 then 'late' else 'ontime' end as delivery_status, count(*) as [no. of orders], avg(o.order_total_profit) as avg_profit, avg(o.order_total_sales) as avg_sales
from [s.orders] o
group by case when o.late_delivery_risk = 1 then 'late' else 'ontime' end

with customer_orderstats as (
select c.customer_id, sum(case when o.late_delivery_risk = 1 then 1 else 0 end) as late_orders, count(*) as total_orders
from [s.orders] o
join [s.customers] c on o.order_customer_id = c.customer_id
group by c.customer_id
),
customer_repeatbehavior as (
select c.customer_id, total_orders, late_orders, round(100.0 * late_orders / total_orders, 2) as late_percentage
from customer_orderstats c
where total_orders >= 2
)
select case when late_percentage >= 50 then 'mostly late' else 'mostly on time' end as customer_type, count(*) as num_customers, round(avg(total_orders), 2) as avg_repeat_orders
from customer_repeatbehavior
group by case when late_percentage >= 50 then 'mostly late' else 'mostly on time' end

-- 20: time-based trend monitoring (performance over time)
select year(o.order_date_dateorders) as order_year, month(o.order_date_dateorders) as order_month,
round(avg(datediff(day, o.order_date_dateorders, o.days_for_shipment_scheduled)), 2) as avg_shipping_days, round(sum(o.order_total_profit), 2) as total_profit
from [s.orders] o
group by year(o.order_date_dateorders), month(o.order_date_dateorders)
order by order_year, order_month

select month(o.order_date_dateorders) as order_month, round(avg(o.order_total_profit), 2) as avg_monthly_profit, round(avg(datediff(day, o.order_date_dateorders, o.days_for_shipment_scheduled)), 2) as avg_shipping_time
from [s.orders] o
group by month(o.order_date_dateorders)
order by order_month

select o.order_region, round(avg(datediff(day, o.order_date_dateorders, o.days_for_shipment_scheduled)), 2) as avg_shipping_duration, round(avg(o.order_total_profit), 2) as avg_profit
from [s.orders] o
group by o.order_region
order by avg_profit desc


-- 21: product interest volume (browsing engagement rate)
-- Q1
select product_id, count(*) as view_count
from s.orders o
group by product_id
order by view_count desc

-- Q2
select product_id, count(*) as total_visits
from s.orders o
group by product_id
having count(*) > 1

-- Q3
select d.department_name, count(*) as view_count
from s.orders o
join order_items op on o.order_id = op.order_id
join s.department d on op.department_id = d.department_id
group by d.department_name
order by view_count desc

-- 22: category popularity index (shopping trend tracker)
-- Q1
select c.category_name, count(*) as view_count
from s.orders o
join s.categories c on o.category_id = c.category_id
group by c.category_name
order by view_count desc

-- Q2
select c.category_name, month(o.order_date_dateorders) as month, count(*) as view_count
from s.orders o
join s.categories c on o.category_id = c.category_id
group by c.category_name, month(o.order_date_dateorders)
order by month desc

-- Q3
select c.category_name, c.customer_country, count(*) as view_count
from s.orders o
join s.categories c on o.category_id = c.category_id
join s.customers c on o.order_customer_id = c.customer_id
group by c.category_name, c.customer_country
order by view_count desc

-- 23: hourly access pattern (customer activity clock)
-- Q1
select hour(o.order_date_dateorders) as hour, count(*) as view_count
from s.orders o
group by hour(o.order_date_dateorders)
order by view_count desc

-- Q2
select hour(o.order_date_dateorders) as hour, count(*) as view_count
from s.orders o
group by hour(o.order_date_dateorders)
order by view_count desc

-- Q3
select d.department_name, c.customer_country, hour(o.order_date_dateorders) as hour, count(*) as view_count
from s.orders o
join order_items op on o.order_id = op.order_id
join s.department d on op.department_id = d.department_id
join s.customers c on o.order_customer_id = c.customer_id
group by d.department_name, c.customer_country, hour(o.order_date_dateorders)
order by view_count desc

-- 24: monthly traffic volume (seasonal shopping insights)
-- Q1
select l.month, count(*) as viewcount
from logs l
group by l.month
order by viewcount desc

-- Q2
select l.month, l.category_id, l.department_id, count(*) as viewcount
from logs l
group by l.month, l.category_id, l.department_id
order by viewcount desc

-- Q3
select l.month, count(*) as viewcount
from logs l
group by l.month
order by viewcount desc

-- 25: department demand share (store area interest ratio)
-- Q1
select l.department_id, count(*) as viewcount
from logs l
group by l.department_id
order by viewcount desc

-- Q2
select l.department_id, c.customer_segment, count(*) as viewcount
from logs l
join s.orders o on l.product_id = o.order_id
join s.customers c on o.order_customer_id = c.customer_id
group by l.department_id, c.customer_segment
order by viewcount desc

-- Q3
select l.department_id, l.hour, s.region, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by l.department_id, l.hour, s.region
order by viewcount desc

-- 26: regional visitor engagement (geographic traffic heatmap)
-- Q1
select s.country, s.region, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by s.country, s.region
order by viewcount desc

-- Q2
select l.category_id, s.country, s.region, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by l.category_id, s.country, s.region
order by viewcount desc

-- Q3
select l.department_id, s.country, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by l.department_id, s.country
order by viewcount desc

-- 27: city-level browsing density (micro-market targeting index)
-- Q1
select s.city, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by s.city
order by viewcount desc

-- Q2
select s.city, l.category_id, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by s.city, l.category_id
order by viewcount desc

-- Q3
select s.city, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by s.city
order by viewcount desc

-- 28: repeat product views (re-engagement score)
-- Q1
select l.product_id, count(distinct l.ip) as uniqueviewers, count(*) as totalviews
from logs l
group by l.product_id
having count(*) > count(distinct l.ip)
order by totalviews desc

-- Q2
select l.product_id, l.hour, s.region, count(*) as viewcount
from logs l
join ips s on l.ip = s.ip
group by l.product_id, l.hour, s.region
order by viewcount desc

-- Q3
select l.category_id, l.product_id, count(*) as totalviews
from logs l
group by l.category_id, l.product_id
having count(*) > 1
order by totalviews desc


















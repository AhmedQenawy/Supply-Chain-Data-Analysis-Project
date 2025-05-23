Create database sca
use sca

---------- Main Data sets cleaning and transformation ------------------------
--- : Note that most of data tables are created by another tool
--    and inserted into sql by wizard tool (import flat file)

--1  handling data logical errors in category and orders data by double-check on category data
-- (data validation process) to maintain consistency between all of data 
/* The goal of this process is providing accurate and real analysis by avoiding data entry errors */

---- removing country data entry errors
update Orders
set Order_Country = case
when country = 'Chili' then 'Chile'
when country = 'Martinique' then 'Martinique'
when country = 'Swiss' then 'Switzerland'
when country = 'Myanmar (Burma)' then 'Myanmar'
else country
end
where country in ('Chili', 'Martinique', 'Swiss', 'Myanmar (Burma)');

---- handling categories logical data errors



update categories
set category_name = 'Accessories', category_id = 41
where category_name = 'trade-in'

update categories 
set category_id = 13 where category_id = 37

update categories
set department_id = 2
where category_id between 9 and 12 or category_id = 48

update categories
set department_id = 4
where category_name like '%Apparel' and category_name not like 'golf%'
or category_name like '%cloth'

update Categories
set Department_ID= 5
where category_name like 'golf%'

update Categories
set Department_ID = 10
where Category_Name like 'co%' or  Category_ID in (13,37,62)

update Categories
set Department_ID = 7
where Category_Id in (16,46,66,74) 

update categories
set department_Id = 3
where category_id in (17,18)

update categories
set departmen_ID = 4
where Category_Name like 'acc%'

update Categories
set Department_ID = 6
where Category_Id in (44,45)

-- valdation that there are not duplicates
with cte as (
select*, ROW_NUMBER() over (partition by category_id order by (select null)) as rn
from Categories
)
delete from cte
where rn > 1



--------------------------------------------




--- 2- creating Order_Items tables with defining primary key on
--     two column (Composite key) 
create table Order_Items (
Order_ID int not null,
Product_ID smallint not null,
Category_ID tinyint ,
Department_ID tinyint not null,
[Order Item Discount] decimal(5,2),
[Order Item Discount Rate ] decimal(3,2),
[Order Item Product Price] decimal(8,3),
[Order Item Profit Ratio] decimal(3,2),
[Order Item Quantity]  tinyint,
[Sales] decimal(8,3),
/*[Order Item Total] decimal(8,3),
[Order Profit Per Order] decimal(9,4),
[COGS] decimal(9,4),*/
Primary Key (Order_ID,Product_ID),
Foreign Key (Order_ID) references Orders(Order_Id),
Foreign key (Product_ID) references Products(Product_ID)
)

bulk insert Order_Items 
from 'C:\Users\ASUS\Desktop\S.Order Items.csv'
with (
fieldterminator = ',',
rowterminator = '0x0a',
firstrow = 2
)

---- 2 removing exact-match duplicates from Order_Items using concat, cte, row_number
----   by validating that both of order and item Ids doesn't make duplication

alter table Order_Items
add [Check] varchar(100)
update Order_Items
set [Check] = CONCAT(Order_ID,Product_ID)

with cte as (
select *, ROW_NUMBER() over (partition by [check] order by (select null)) as rn
from Order_Items
)
delete from cte
where rn > 1
alter table order_items
drop column [Check]


-- To Maintain Consistency with Cateogories data in all of data

update order_items
set category_id = case
when category_id = 40 then 41
when category_id = 37 then 13
else category_id
end
where category_id in (40, 37)

update order_items op
set op.department_id = c.department_id
from order_items op
left join categories c
on c.category_id = op.category_id

update products
set category_id = case
when category_id = 40 then 41
when category_id = 37 then 13
else category_id
end
where category_id in (40, 37)

update p
set p.department_id = c.department_id
from products p
left join categories c
on p.category_id = c.category_id


----- 3 check accuracy of numeric-financial data & transform and removing errors by make it more accurate
--  double-check cleaning process
update Order_Items
set [Order Item Discount] = [Order Item Product Price]*[Order Item Discount Rate ]
update Order_Items
set Sales = [Order Item Product Price]*[Order Item Quantity]


-- 4 Adding important-for-analysis-and-KPI's columns
alter table order_product
add [Order Item Total] decimal (8,3),
[Order Profit Per Order] decimal (9,4),
[COGS] decimal (9,4)

Update Order_Items
set [Order Item Total] = Sales - ([Order Item Discount]*[Order Item Quantity])

Update Order_Items
set [Order Profit Per Order] = [Order Item Profit Ratio]*[Order Item Total]

update Order_Items
set [COGS] = Sales - [Order Profit Per Order]
----------------------------------------------

alter table orders
add [order_total_sales] decimal(8,3),
 [order_total_real_sales_after_discount] decimal (8,3),
 [order_total_profit] decimal (8,3),
 [Order_Total_Cost] decimal (8,3)

 update orders
 set [order_total_sales] = s.total_sales
 from orders o left join (select o.Order_ID, sum(op.Sales) as total_sales
 from Orders o left join Order_Items op
 on o.Order_ID = op.Order_ID
 group by o.Order_ID
 ) s on o.Order_ID = s.Order_ID


update orders 
set [Order_Total_Real_Sales] = r.total_real
from orders o left join (select o.Order_ID, sum(op.[Order Item Total]) as total_real
 from Orders o left join Order_Items op
 on o.Order_ID = op.Order_ID
 group by o.Order_ID
 ) r on o.Order_ID = r.Order_ID

 update orders
 set [Order_Total_Real_Sales] = p.total_profit
from orders o left join (select o.Order_ID, sum(op.[Order Profit Per Order]) as total_profit
 from Orders o left join Order_Items op
 on o.Order_ID = op.Order_ID
 group by o.Order_ID
 ) p on o.Order_ID = p.Order_ID

 update orders
 set [Order_Total_Cost] = c.total_cost
from orders o left join (select o.Order_ID, sum(op.[COGS]) as total_cost
 from Orders o left join Order_Items op
 on o.Order_ID = op.Order_ID
 group by o.Order_ID
 ) c on o.Order_ID = c.Order_ID

--- Now we've made Important Bussiness data Transformation that will help us in analysis process

------------------------------------ <<<<<<<<<< Now, Our Main Data cleaning and transformation are done,       >>>>>>>>>>>>
------------------------------- <<<<<<<<<<<<<<<<  let's continue in another helping data we find and collecting >>>>>>>>>>>>>>>>>>>>>>>>>>

------------------------------------------------------------------------------------------------------------------------------------

------------------ Access Logs to the online Store Data --------------------------
-------------- Clening, Transformation & Optimization Process -------------------
--; note that it's imported by SQL Wizard Tool

--1 cleaning exact-match duplicates and remove data errors by concat, cte, row_number
--(first we need to combine ip with date and time to make it unique, second we'll remove duplication)

alter table logs
add [check] varchar(100)
update logs
set [check] = concat([ip],[Date])

with cte as (
select *, ROW_NUMBER() over (partition by [check] order by (select null)) as rn
from logs
)
delete from cte
where rn > 1

--------------------------------
--2 removing unuseful-for-analysis column to optimize storage and reduce it
alter table logs
drop column url
--------------------
-- 3 Mantain Consistency between logs and all data
-- to find differneces
select distinct l.category
from logs l left join categories c
on l.category = c.category_name
where c.category_name is null

select distinct l.product
from logs l left join products p
on l.product = p.product_name
where p.product_name is null
order by l.product

select product_name from products
order by Product_Name
where product_name not in (select distinct product from logs)


-- 4 replacing errors (date,  product name error); to build strong accurate hierarchy between products, departments and categories

update logs 
set product = case
when product = 'adidas Brazuca 2014 Official Match Ball' then 'adidas Brazuca 2017 Official Match Ball'
when product = 'Top Flite Women''s 2014 XL Hybrid' then 'Top Flite Women''s 2017 XL Hybrid'
when product = 'TaylorMade 2014 Purelite Stand Bag' then 'TaylorMade 2017 Purelite Stand Bag'
else product
where product = 'adidas Brazuca 2014 Official Match Ball'
or product = 'Top Flite Women''s 2014 XL Hybrid'
or product = 'TaylorMade 2014 Purelite Stand Bag'

----------------------------------
-- 5 hanling data logical errors in logs data and make it in relationship with other data

update logs 
set category = case
when category = 'Trade-in' then 'Accessories'
when Category like 'indoor%' then (select category_name from Categories where Category_Name like 'indoor%')
when Category not in (select distinct l.category
from logs l join Categories c
on l.category = c.Category_Name)
then 'Men''S Clothing'
else category
end
where category = 'Trade-in'
or category like 'indoor%'
or category not in (select distinct l.category
from logs l join Categories c
on l.category = c.Category_Name)


---------------------------------------------------------

-- 6 removing other data errors in logs data 
delete
from logs l left join Products p
on l.proudct = p.product_name
where l.product not in (select product_name from Products )

------------------------------------------------------------
-- 7 Apply data optimization on all of logs data 
--(replacing text by IDs to Optimize queries performance, make the retrieval process more rapid, optimize storage of the DB and reduce it)

-- replacing in Product, category, department column in one query (step)
update l
set l.product = p.Product_ID,
l.category = c.Category_Id,
l.department = d.Department_Id
from logs l left join Products p
on l.product = p.product_name
left join categories c 
on c.category_Id = p.category_Id
left join departments d
on c.department_Id = d.department_Id

-- 8 changing columns' data types to reduce storage and improve query performanc 

alter table logs
alter column Product smallint
alter table logs
alter column category tinyint
alter table logs
alter column department tinyint

-- 9  changing names to maintain accuracy and consistency using stored procedures & alter column
exec sp_rename 'logs.category', 'Category_ID', 'Column'
exec sp_rename 'logs.product', 'Product_ID', 'Column'
exec sp_rename 'logs.department', 'Department_ID', 'Column'





----------------------------------------------------- IPs Geo. Data ----------------------------------------------------------------------

------------------------------------( Now we want to make max. benifit from logs data, so
-- we conduct smart web data collection to collect geoghraphical data that assign to each unique ip adress in logs data
-- that include (cities, region, country in iso 2 digit code),
-- so we can make conduct geo analysis and make strong relation between logs data and our main data.           )------------------------------------------------

-- To maintain consistncy between all of these data we need to convert ips' info acording to main data
-- (make it with the same region classification, with the same country format)
-- so, we get ISO data set includes countries and countries' code in order to replace 2 digit code to country name
-- finally we need to make it assigned to same region calssification in main data.     (; note that both of logs and iso data set are imported by sql wizard tool)

-- 1 converting iso code to country name
update s
set s.country = i.Name
from ips s left join iso i
on s.country = i.Code

-- 2 replacing values coverted in order to match with our main data
update ips
set country = case
when country = 'Viet Nam' then 'Vietnam'
when country = 'United States' then 'USA'
when country like 'Syrian%' then 'Syria'
when country like 'Russian%' then 'Russia'
when country = 'RÃ©union' then 'Réunion'
else country
end
where country in ('Viet Nam', 'United States','RÃ©union')
or country like 'Syrian%'
or country like 'Russian%'


--- 3 make region column assign to main orders data
update s
set s.Region = o.Order_Region
from ips s left join Orders o
on s.country = o.Order_Country

--- 4 find values that not matching and didn't converted
select country from ips
where Region is null

-- 5 replacing not converted values
update ips 
set region = case
when country in ('Mauritius','Seychelles','Réunion') then 'East Africa'
when country = 'Gambia' then 'West Africa'
when country in ('French Polynesia','Guam','Fiji') then 'Oceania'
when country = 'Grenada' then 'Caribbean'
when country = 'Palestine' then 'West Asia'
when country in ('Iceland','Åland Islands') then 'Northern Europe'
when country = 'Malta' then 'Southern Europe'
when country = 'Puerto Rico' then 'South of USA'
else region
end
where country in ('Mauritius','Seychelles','Réunion','Gambia',
'French Polynesia','Guam','Fiji','Grenada','Palestine'
,'Iceland','Åland Islands','Malta','Puerto Rico')

-----------------------------------
-- 6 removing ips data from logs and ips data that doesn't include data (nulls)
delete from logs l
left join ips s
on l.ip = s.ip
where s.city is null

delete from ips
where city is null

--7 adding primary key constraint on two columns date,ip (Composite key)
-- & adding relationships foreign key to ips table (geo. data)

alter table logs
add constraint PK_IP_DATE_LOGS primary key ([ip],[date])
add constraint FK_IP_LOGS foreign key ([ip]) references ips([ip])

-- drop used table (iso)
drop table iso


--------------- Now we've made our data sets cleaned, Optimized to max. level, Transformed in a clear and useful way
--------------- so our data now is ready for conducting powerful analysis. let's go   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
--------------------------------------------------------------------------------------------------------------------



















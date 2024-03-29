select * from fact_events;

---------- list of Products with a base greater than 500 that are featured in the promo type of 'BOGOF' 

select * from fact_events
where base_price > 500 and promo_type = 'BOGOF' ;

------------- Overview of the numbers of stores in each city 

select 
      city, count(city) as store_count
from 
      dim_stores
group by 
       city
order by store_count desc ;

------------- Total Revenue generated by each campaign before and after the campaign

SELECT
    promo_type AS campaign_name,
    SUM(base_price * `quantity_sold(before_promo)`) AS `total_revenue(before_promotion)`,
    SUM(base_price * `quantity_sold(after_promo)`) AS `total_revenue(after_promotion)`, 
    row_number() OVER (PARTITION BY promo_type) AS total_revenue_after_promotion
FROM
    fact_events
    group by campaign_name
    order by `total_revenue(after_promotion)` desc ;
    
--------------- Incremental Sold Quantity % for each category 
with a as (select 
       dim_products.category, 
       fact_events.base_price,
       fact_events.campaign_id,
       fact_events.event_id,
       fact_events.product_code,
       fact_events.promo_type, 
       fact_events.`quantity_sold(after_promo)`, 
       fact_events.`quantity_sold(before_promo)`, 
       fact_events.store_id
from  
	   fact_events
inner join 
       dim_products on dim_products.product_code = fact_events.product_code
where campaign_id = 'CAMP_DIW_01')
select 
	category, 
	sum((`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)*100/`quantity_sold(before_promo)`)
	as `%isu`,
	row_number() over(partition by category order by sum((`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)*100/`quantity_sold(before_promo)`))
    as `rank order`
from a 
group by category;


------------------- Top 5 Incremental Revenue Percentage % 
WITH b AS (
    SELECT
        dim_products.product_name,
        dim_products.category,
        fact_events.base_price,
        fact_events.campaign_id,
        fact_events.event_id,
        fact_events.product_code,
        fact_events.promo_type,
        fact_events.`quantity_sold(after_promo)`,
        fact_events.`quantity_sold(before_promo)`,
        fact_events.store_id
    FROM
        fact_events
    INNER JOIN
        dim_products ON dim_products.product_code = fact_events.product_code
)

SELECT
    b.product_name,
    b.category,
    ((b.`quantity_sold(after_promo)` - b.`quantity_sold(before_promo)`) * b.`base_price` * 100) / b.`quantity_sold(before_promo)` AS 'ir%'
FROM
    b
    group by  b.category,b.product_name,((b.`quantity_sold(after_promo)` - b.`quantity_sold(before_promo)`) * b.`base_price` * 100) / b.`quantity_sold(before_promo)`
ORDER BY
    'ir%'  desc
    limit 5 ;






    
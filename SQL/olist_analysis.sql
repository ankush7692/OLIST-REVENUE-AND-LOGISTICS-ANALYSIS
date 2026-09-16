USE olist_db;
SELECT * FROM product_category_name_translation;
-- ALTER TABLE product_category_name_translation 
-- RENAME COLUMN ï»¿product_category_name TO product_category_name;

-- WITH DeliveryData AS (
--   SELECT o.order_id, r.review_score,
--   DATEDIFF(STR_TO_DATE(o.order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'), STR_TO_DATE(o.order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')) as delay_days
--   FROM olist_orders_dataset o
--   JOIN olist_order_reviews_dataset r on o.order_id = r.order_id
--   WHERE o.order_status = 'delivered' and o.order_delivered_customer_date IS NOT NULL
--   AND r.review_score is not null
-- )
-- SELECT CASE 
--   WHEN delay_days <= 0 THEN '1. On Time / Early'
--   WHEN delay_days BETWEEN 1 AND 3 THEN '2. Late by 1-3 Days'
--   WHEN delay_days BETWEEN 4 AND 7 THEN '3. Late by 4-7 Days'
--   ELSE '4. Extremely Late (8+ Days)' 
--   END AS delivery_status_segment,
--   COUNT(order_id) as total_orders, 
--   ROUND(AVG(review_score), 2) as average_customer_rating
-- FROM DeliveryData
-- GROUP BY delivery_status_segment ORDER BY delivery_status_segment;


-- WITH SellerRevenue as (
--   select seller_id, SUM(price) as total_revenue
--   from olist_order_items_dataset 
--   group by seller_id),
--   
-- RankedSellers as (
--   SELECT seller_id, total_revenue,
--   SUM(total_revenue) OVER (ORDER BY total_revenue DESC) as running_total,
--   SUM(total_revenue) OVER () as grand_total
--   FROM SellerRevenue)
-- SELECT seller_id, ROUND(total_revenue, 2) AS total_revenue,
-- ROUND((running_total / grand_total) * 100, 2) as cumulative_revenue_percentage,
-- CASE 
--   WHEN (running_total / grand_total) <= 0.80 THEN 'Critical: Top 80% Revenue Generator'
--   ELSE 'Low Risk: Bottom 20% Generator' 
-- END as business_impact_segment
-- from RankedSellers 
-- order by total_revenue desc LIMIT 50;


WITH CustomerFirstPurchase AS (
  SELECT c.customer_unique_id,
  MIN(DATE_FORMAT(STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m-01')) as first_purchase_month
  FROM olist_customers_dataset c 
  JOIN olist_orders_dataset o on c.customer_id = o.customer_id
  GROUP BY c.customer_unique_id),
  
  
  
  
  
PurchaseActivity as (
  SELECT c.customer_unique_id, 
  DATE_FORMAT(STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m-01') as active_month
  FROM olist_customers_dataset c join olist_orders_dataset o on c.customer_id = o.customer_id)
SELECT f.first_purchase_month as cohort_month,
  TIMESTAMPDIFF(MONTH, STR_TO_DATE(f.first_purchase_month, '%Y-%m-%d'), STR_TO_DATE(a.active_month, '%Y-%m-%d')) as months_since_first_purchase,
  COUNT(DISTINCT a.customer_unique_id) as retained_users
FROM CustomerFirstPurchase f
JOIN PurchaseActivity a on f.customer_unique_id = a.customer_unique_id
GROUP BY cohort_month, months_since_first_purchase 
ORDER BY cohort_month, months_since_first_purchase;


SELECT * FROM olist_clean_analytics;

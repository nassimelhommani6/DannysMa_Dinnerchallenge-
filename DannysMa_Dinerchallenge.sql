SELECT * FROM sales ;
SELECT * FROM menu ;
SELECT * FROM members ;
USE dannys_diner
-- 1) Total amount each customer spent at the restaurant 
SELECT s.customer_id ,SUM( m.price ) AS total_amount
FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id=m.product_id
GROUP BY 1 ; 

-- 2) How many days has each customer visited the restaurant?
SELECT customer_id ,Count(Distinct order_date) AS number_day 
FROM sales 
GROUP BY 1 ;

-- 3) What was the first item from the menu purchased by each customer?
WITH rnk AS (SELECT customer_id, order_date , product_id ,
ROW_NUMBER() OVER ( PARTITION BY customer_id   ORDER BY customer_id ASC ) AS row_nbr
FROM sales )
SELECT r.customer_id, r.order_date , r.product_id ,m.product_name
FROM rnk as r
LEFT JOIN menu as m
ON r.product_id=m.product_id 
WHERE row_nbr = 1 

-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
SUM(CASE WHEN m.product_name='sushi' THEN 1 END ) AS suchi,
SUM(CASE WHEN m.product_name='curry' THEN 1 END ) AS curry,
SUM(CASE WHEN m.product_name='ramen' THEN 1 END ) AS ramen
FROM sales as s
LEFT JOIN menu as m
ON s.product_id=m.product_id 

-- 5) Which item was the most popular for each customer?
SELECT s.customer_id,
SUM(CASE WHEN m.product_name='sushi' THEN 1 END ) AS suchi,
SUM(CASE WHEN m.product_name='curry' THEN 1 END ) AS curry,
SUM(CASE WHEN m.product_name='ramen' THEN 1 END ) AS ramen
FROM sales as s
LEFT JOIN menu as m
ON s.product_id=m.product_id 
GROUP BY 1 ;

-- 6) Which item was purchased first by the customer after they became a member?

WITH item1 AS (SELECT s.customer_id, s.order_date, s.product_id , m.join_date ,me.product_name ,
ROW_NUMBER() OVER ( PARTITION BY customer_id   ORDER BY customer_id ASC ) AS row_nbr
FROM sales as s
LEFT JOIN members as m
ON s.customer_id=m.customer_id 
LEFT JOIN menu AS me
ON s.product_id=me.product_id
WHERE   s.order_date >= m.join_date)
SELECT customer_id, order_date , join_date ,product_name AS first_item 
FROM item1
WHERE row_nbr=1
GROUP BY 1 ;

-- 7) Which item was purchased just before the customer became a member?

WITH item2 AS ( SELECT s.customer_id, s.order_date, s.product_id , m.join_date ,me.product_name ,
ROW_NUMBER() OVER ( PARTITION BY customer_id   ORDER BY customer_id ASC ) AS row_nbr
FROM sales as s
LEFT JOIN members as m
ON s.customer_id=m.customer_id 
LEFT JOIN menu AS me
ON s.product_id=me.product_id
WHERE   s.order_date < m.join_date )
SELECT  customer_id, order_date , join_date ,product_name 
FROM item2
WHERE row_nbr=1
GROUP BY 1

-- 8) What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, m.join_date , 
SUM(price) AS total_amount_spent,
COUNT( product_name) AS total_items
FROM sales as s
LEFT JOIN members as m
ON s.customer_id=m.customer_id 
LEFT JOIN menu AS me
ON s.product_id=me.product_id
WHERE s.order_date< m.join_date
GROUP BY 1 ;

-- 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, m.join_date , 
SUM(price) AS total_amount_spent,
COUNT( product_name) AS total_items,
SUM(CASE WHEN product_name='sushi' THEN price*2 ELSE price END )AS total_points 
FROM sales as s
LEFT JOIN members as m
ON s.customer_id=m.customer_id 
LEFT JOIN menu AS me
ON s.product_id=me.product_id
GROUP BY 1 ;

-- 10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT s.customer_id, m.join_date , 
SUM(price) AS total_amount_spent,
SUM(CASE WHEN order_date <= join_date+7 THEN price*2 ELSE price END ) AS points 
FROM sales as s
LEFT JOIN members as m
ON s.customer_id=m.customer_id 
LEFT JOIN menu AS me
ON s.product_id=me.product_id
GROUP BY 1 ;

-- Bonus Questions 
 -- The following questions are related creating basic data tables ,
 -- that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL
 
WITH item3 AS (SELECT s.customer_id, s.order_date,me.product_name ,me.price, m.join_date ,
CASE WHEN join_date IS NOT NULL AND join_date <= order_date THEN 'Y'
 WHEN join_date IS NOT NULL AND join_date >  order_date THEN 'N'
 WHEN join_date IS NULL then 'N' END AS Membere 
FROM sales as s
LEFT JOIN members as m
ON s.customer_id=m.customer_id 
LEFT JOIN menu AS me
ON s.product_id=me.product_id
ORDER By 1 )
SELECT customer_id, order_date,product_name ,price ,Membere, 
CASE WHEN Membere='Y' THEN DENSE_RANK() OVER (PARTITION BY customer_id, Membere  ORDER BY customer_id , order_date ASC) ELSE NULL END AS ranking 
FROM item3 
ORDER BY 1 ASC , 1 ASC ;  








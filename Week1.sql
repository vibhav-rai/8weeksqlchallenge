-- Week 1
-- https://8weeksqlchallenge.com/case-study-1/

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- 1. What is the total amount each customer spent at the restaurant?
 SELECT s.customer_id, SUM(m.price)
 FROM dannys_diner.sales s
 INNER JOIN dannys_diner.menu m
 ON s.product_id = m.product_id
 GROUP BY 1
 ORDER BY 2 DESC;

-- 2. How many days has each customer visited the restaurant?
 SELECT customer_id, COUNT(DISTINCT order_date)
 FROM dannys_diner.sales s
 GROUP BY 1
 ORDER BY 2 DESC;

-- 3. What was the first item from the menu purchased by each customer?
 WITH first_order AS (
   SELECT * FROM
   (SELECT *, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as rnk
   FROM dannys_diner.sales) sub
   WHERE rnk = 1
   )
   SELECT DISTINCT f.customer_id, m.product_name
   FROM first_order f
   INNER JOIN dannys_diner.menu m
   ON f.product_id = m.product_id
   ORDER BY 1;

 -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH highest_sold AS (
SELECT product_id, COUNT(product_id) as most_purchased
FROM dannys_diner.sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
)
SELECT h.most_purchased, m.product_name
FROM highest_sold h
JOIN dannys_diner.menu m
ON h.product_id = m.product_id;

-- 5. Which item was the most popular for each customer?
SELECT sub.customer_id, sub.product_name, sub.cnt
FROM (
SELECT s.customer_id, m.product_name, COUNT(s.product_id) as cnt,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(s.product_id) DESC) as rnk FROM dannys_diner.sales s JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY 1,2
) sub
WHERE sub.rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH first_orders AS (
SELECT s.*, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as rnk
FROM dannys_diner.sales s JOIN dannys_diner.members m
ON (s.order_date > m.join_date) AND (s.customer_id = m.customer_id)
)
SELECT DISTINCT f.customer_id, m.product_name
FROM first_orders f JOIN dannys_diner.menu m
ON f.product_id = m.product_id
WHERE rnk = 1
ORDER BY 1

-- 7. Which item was purchased just before the customer became a member?
WITH before_mem AS (
SELECT s.*, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) as rnk
FROM dannys_diner.sales s JOIN dannys_diner.members m
ON (s.order_date < m.join_date) AND (s.customer_id = m.customer_id)
)
SELECT DISTINCT f.customer_id, m.product_name
FROM before_mem b JOIN dannys_diner.menu m
ON b.product_id = m.product_id
WHERE rnk = 1
ORDER BY 1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH before_mem AS (
SELECT s.*
FROM dannys_diner.sales s JOIN dannys_diner.members m
ON (s.order_date < m.join_date) AND (s.customer_id = m.customer_id)
)
SELECT b.customer_id, COUNT(b.product_id) as prod_cnt, SUM(m.price) as total_amt
FROM before_mem b JOIN dannys_diner.menu m
ON b.product_id = m.product_id
GROUP BY 1
ORDER BY 1;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH menu_pts AS (
SELECT product_id, CASE WHEN product_id in (2,3) THEN price*10
WHEN product_id = 1 THEN price * 20 END AS points
FROM dannys_diner.menu
)
SELECT s.customer_id, SUM(m.points) as total_pts
FROM dannys_diner.sales s JOIN menu_pts m
ON S.product_id = m.product_id
GROUP BY 1
ORDER BY 1;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have at the end of January?
WITH after_mem AS (
SELECT s.*, m.join_date, m.join_date + 6 as valid_date
FROM dannys_diner.sales s JOIN dannys_diner.members m
ON (s.order_date >= m.join_date) AND (s.customer_id = m.customer_id)
),
total_pts AS (
SELECT a.*,
CASE WHEN a.order_date BETWEEN a.join_date AND a.valid_date THEN m.price * 20
ELSE m.price * 10 END AS points
FROM after_mem a JOIN dannys_diner.menu m
ON a.product_id = m.product_id
WHERE a.order_date < '2021-01-31'
)
SELECT customer_id, SUM(points)
FROM total_pts
GROUP BY 1
ORDER BY 1;

-- Recreate a table that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
--customer_id	order_date	product_name	price	member
--A	            2021-01-01	curry	          15	N
--A	            2021-01-01	sushi	          10	N
--A	            2021-01-07	curry	          15	Y

SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE WHEN s.order_date < mem.join_date THEN 'N'
ELSE 'Y' END AS member
FROM dannys_diner.sales s JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members mem ON
s.customer_id = mem.customer_id;

-- Danny also requires further information about the ranking of customer products,
-- but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when
-- customers are not yet part of the loyalty program.

WITH joined_df AS (
SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE WHEN s.order_date < mem.join_date THEN 'N'
ELSE 'Y' END AS member
FROM dannys_diner.sales s JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members mem ON
s.customer_id = mem.customer_id
)
SELECT *, CASE WHEN member = 'Y' then RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
ELSE null END AS ranking
FROM joined_df;

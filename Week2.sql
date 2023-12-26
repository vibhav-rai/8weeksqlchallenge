-- Week 2
-- https://8weeksqlchallenge.com/case-study-2/

DROP SCHEMA IF EXISTS pizza_runner CASCADE;
CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" TIMESTAMP,
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', NULL, 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', NULL, 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
-- Cleaning customer_orders table
DROP TABLE IF EXISTS pizza_runner.customer_orders_v1;
CREATE TABLE pizza_runner.customer_orders_v1 AS
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN (exclusions LIKE 'null') OR (exclusions = '') THEN NULL
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN (extras LIKE 'null') OR (extras = '') THEN NULL
	  ELSE extras
	  END AS extras,
	order_time
FROM pizza_runner.customer_orders;


DROP TABLE IF EXISTS pizza_runner.runner_orders_v1;
CREATE TABLE pizza_runner.runner_orders_v1 AS
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN distance LIKE 'null' THEN NULL
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
	  END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN NULL
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN (cancellation LIKE 'null') or (cancellation = '') THEN NULL
	  ELSE cancellation
	  END AS cancellation
FROM pizza_runner.runner_orders;

ALTER TABLE pizza_runner.runner_orders_v1
ALTER COLUMN distance TYPE FLOAT
USING distance::FLOAT,
ALTER COLUMN duration TYPE INT
USING duration::integer;

SELECT * FROM pizza_runner.runner_orders_v1;
SELECT * FROM pizza_runner.customer_orders_v1;


-- Tables:
-- pizza_runner.customer_orders_v1
-- pizza_runner.runner_orders_v1
-- pizza_runner.runners
-- pizza_runner.pizza_names
-- pizza_runner.pizza_recipes
-- pizza_runner.pizza_toppings

-- How many pizzas were ordered?
SELECT COUNT(*) as pizza_ordered
FROM pizza_runner.customer_orders_v1;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) as distinct_orders
FROM pizza_runner.customer_orders_v1;

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id)
FROM pizza_runner.runner_orders_v1
WHERE cancellation IS NULL
GROUP BY 1;

-- How many of each type of pizza was delivered?
SELECT pn.pizza_id, pn.pizza_name, COUNT(co.pizza_id) as del_cnt
FROM pizza_runner.pizza_names pn 
JOIN pizza_runner.customer_orders_v1 co
ON pn.pizza_id = co.pizza_id
JOIN pizza_runner.runner_orders_v1 ro
ON co.order_id = ro.order_id
WHERE cancellation is null
GROUP BY 1,2;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id, co.pizza_id, pn.pizza_name, COUNT(co.pizza_id) as pizza_cnts
FROM pizza_runner.customer_orders_v1 co
JOIN pizza_runner.pizza_names pn
ON co.pizza_id = pn.pizza_id
GROUP BY 1,2,3
ORDER BY 1

-- What was the maximum number of pizzas delivered in a single order?
WITH del_cnts AS (
SELECT co.order_id, COUNT(co.pizza_id) as pizza_cnt
FROM pizza_runner.customer_orders_v1 co
JOIN pizza_runner.runner_orders_v1 ro
ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY 1
)
SELECT order_id, MAX(pizza_cnt)
FROM del_cnts
GROUP BY 1
ORDER BY 2 DESC;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- At least 1 change- value present in either exclusions or extras.
-- No change - exclusion & extras both have nulls.
SELECT co.customer_id,
SUM(CASE WHEN (co.exclusions IS NULL) AND (co.extras IS NULL) THEN 1 ELSE 0 END) as no_change,
SUM(CASE WHEN (co.exclusions IS NOT NULL) OR (co.extras IS NOT NULL) THEN 1 ELSE 0 END) as at_least_one_change
FROM pizza_runner.customer_orders_v1 co
JOIN pizza_runner.runner_orders_v1 ro
ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY 1
ORDER BY 1;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT SUM(CASE WHEN (co.exclusions IS NOT NULL) AND (co.extras IS NOT NULL) THEN 1 ELSE 0 END) as excl_and_extr_cnt
FROM pizza_runner.customer_orders_v1 co
JOIN pizza_runner.runner_orders_v1 ro
ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day, COUNT(order_id) AS pizza_count
FROM pizza_runner.customer_orders_v1
GROUP BY 1
ORDER BY 1;

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH diff_time AS (
  SELECT co.order_id, co.order_time, ro.pickup_time, 
  EXTRACT(MINUTE FROM ro.pickup_time - co.order_time) as min_diff
  FROM pizza_runner.customer_orders_v1 co
  JOIN pizza_runner.runner_orders_v1 ro
  ON co.order_id = ro.order_id
  WHERE ro.cancellation IS NULL
  GROUP BY 1,2,3
)
SELECT ROUND(AVG(min_diff),0) as avg_min 
FROM diff_time
WHERE min_diff IS NULL;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prepare_time AS (
  SELECT co.order_id, ro.pickup_time, co.order_time, COUNT(pizza_id) as total_pizzas_ordered, 
  EXTRACT(MINUTE FROM ro.pickup_time - co.order_time) as prep_time
  FROM pizza_runner.customer_orders_v1 co
  JOIN pizza_runner.runner_orders_v1 ro
  ON co.order_id = ro.order_id
  WHERE ro.cancellation IS NULL
  GROUP BY 1,2,3
)
SELECT total_pizzas_ordered, ROUND(AVG(prep_time))
FROM prepare_time
GROUP BY 1
ORDER BY 1;

-- What was the average distance travelled for each customer?
SELECT co.customer_id, ROUND(AVG(ro.distance))
FROM pizza_runner.customer_orders_v1 co
JOIN pizza_runner.runner_orders_v1 ro
ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY 1
ORDER BY 1;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) as del_time_diff
FROM pizza_runner.runner_orders_v1
WHERE duration IS NULL;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, order_id, distance, duration/60 as duration_hr, (distance/duration*60) as avg_speed
FROM pizza_runner.runner_orders_v1
WHERE cancellation IS NULL
GROUP BY 1,2,distance,duration
ORDER BY 2;

-- What is the successful delivery percentage for each runner?
SELECT runner_id,
100* SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)/COUNT(order_id) as success_perc
FROM pizza_runner.runner_orders_v1
GROUP BY 1
ORDER BY 1;

-- What are the standard ingredients for each pizza?
DROP TABLE IF EXISTS pizza_runner.pizza_recipes_v1;
CREATE TABLE pizza_runner.pizza_recipes_v1 AS
SELECT pizza_id, regexp_split_to_table(toppings, E',')::int AS split_toppings
FROM pizza_runner.pizza_recipes;

SELECT pn.pizza_name, pt.topping_name
FROM pizza_runner.pizza_names pn
JOIN pizza_runner.pizza_recipes_v1 pr
ON pn.pizza_id = pr.pizza_id
JOIN pizza_runner.pizza_toppings pt
ON pr.split_toppings = pt.topping_id;

SELECT
CASE WHEN topping_id IN (SELECT split_toppings FROM pizza_runner.pizza_recipes_v1 WHERE pizza_id = 1) THEN topping_name ELSE NULL END AS Meatlovers,
CASE WHEN topping_id IN (SELECT split_toppings FROM pizza_runner.pizza_recipes_v1 WHERE pizza_id = 2) THEN topping_name ELSE NULL END AS Vegetarian
FROM pizza_runner.pizza_toppings;

-- What was the most commonly added extra?
WITH extras AS (
  SELECT regexp_split_to_table(extras, E',')::int AS split_extras
  FROM pizza_runner.customer_orders_v1
)
SELECT e.split_extras as topping_id, pt.topping_name, COUNT(e.split_extras) as cnt
FROM extras e
JOIN pizza_runner.pizza_toppings pt
ON e.split_extras = pt.topping_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- What was the most common exclusion?
WITH exclusions AS (
  SELECT regexp_split_to_table(exclusions, E',')::int AS split_exclusions
  FROM pizza_runner.customer_orders_v1
)
SELECT e.split_exclusions as topping_id, pt.topping_name, COUNT(e.split_exclusions) as cnt
FROM exclusions e
JOIN pizza_runner.pizza_toppings pt
ON e.split_exclusions = pt.topping_id
GROUP BY 1,2
ORDER BY 3 DESC;


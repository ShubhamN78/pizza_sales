-- ==========================
-- Basic :
-- ==========================

-- Q1. Retrieve the total number of orders placed.
-- Tables Used: orders
-- Output: total count of all orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Q2. Calculate the total revenue generated from pizza sales.
-- Tables Used: pizzas, order_details
-- Output: total revenue rounded to 2 decimals
SELECT 
    ROUND(SUM(p.pizza_price * od.order_quantity),
            2) AS total_sales
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- Q3. Identify the highest-priced pizza.
-- Tables Used: pizza_types, pizzas
-- Output: pizza name and its price
SELECT 
    pt.pizza_name AS pizza, p.pizza_price AS price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_types_id = p.pizza_types_id
ORDER BY p.pizza_price DESC
LIMIT 1;

-- Q4. Identify the most common pizza size ordered.
-- Tables Used: pizzas, order_details
-- Output: pizza size with highest total quantity ordered
SELECT 
    p.pizza_size, SUM(od.order_quantity) AS total_quantity
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.pizza_size
ORDER BY total_quantity DESC
LIMIT 1;

-- Q5. List the top 5 most ordered pizza types along with their quantities.
-- Tables Used: pizza_types, pizzas, order_details
-- Output: top 5 pizza names with their total quantities
SELECT 
    pt.pizza_name, SUM(od.order_quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_types_id = p.pizza_types_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_name
ORDER BY total_quantity DESC
LIMIT 5;

-- ========================================
-- Intermediate:
-- ========================================

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
-- Tables Used: pizza_types, pizzas, order_details
-- Output: each category with its total quantity ordered
SELECT 
    pt.pizza_category, SUM(od.order_quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_types_id = p.pizza_types_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_category
ORDER BY SUM(od.order_quantity) DESC;

-- Q7. Determine the distribution of orders by hour of the day.
-- Tables Used: orders
-- Output: each hour with total orders placed in that hour
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id) DESC;

-- Q8. Join relevant tables to find the category-wise distribution of pizzas.
-- Tables Used: pizza_types
-- Output: each category with count of pizzas in it
SELECT 
    pizza_category, COUNT(pizza_name) AS total_pizzas
FROM
    pizza_types
GROUP BY pizza_category;

-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.
-- Tables Used: orders, order_details
-- Approach: subquery calculates daily total then outer query averages it
-- Output: single value average pizzas per day rounded to 0 decimals
SELECT 
    ROUND(AVG(total_pizzas), 0) AS avg_pizzas_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.order_quantity) total_pizzas
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date) AS daily_totals;

-- Q10. Determine the top 3 most ordered pizza types based on revenue.
-- Tables Used: pizza_types, pizzas, order_details
-- Output: top 3 pizza names with their total revenue
SELECT 
    pt.pizza_name,
    SUM(p.pizza_price * od.order_quantity) AS total_sales
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_types_id = p.pizza_types_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_name
ORDER BY total_sales DESC
LIMIT 3;

-- ===========================
-- Advanced:
-- ===========================

-- Q11. Calculate the percentage contribution of each pizza type to total revenue.
-- Tables Used: pizza_types, pizzas, order_details
-- Approach: subquery calculates total revenue, outer query divides category revenue by it
-- Output: each category with total sales and its percentage of total revenue
SELECT 
    pt.pizza_category,
    SUM(p.pizza_price * od.order_quantity) AS total_sales,
    ROUND(((SUM(p.pizza_price * od.order_quantity)) / (SELECT 
                    (SUM(p.pizza_price * od.order_quantity))
                FROM
                    pizzas p
                        JOIN
                    order_details od ON p.pizza_id = od.pizza_id) * 100),
            2) AS revenue_percent
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_types_id = p.pizza_types_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_category
ORDER BY REVENUE_PERCENT DESC;

-- Q12. Analyze the cumulative revenue generated over time.
-- Tables Used: orders, order_details, pizzas
-- Approach: CTE calculates daily revenue, window function SUM() OVER() builds running total
-- Output: each date with daily sales and cumulative revenue up to that date
WITH daily_revenue AS (
	SELECT 
		o.order_date, 
		SUM(p.pizza_price * od.order_quantity) as total_sales 
    FROM orders o 
    JOIN order_details od ON o.order_id = od.order_id 
    JOIN pizzas p ON p.pizza_id = od.pizza_id 
    GROUP BY o.order_date
) 
SELECT  
	order_date,
	total_sales,
	SUM(total_sales) OVER (
		ORDER BY order_date
	) AS cumulative_revenue 
FROM daily_revenue 
ORDER BY order_date;





-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- Tables Used: pizza_types, pizzas, order_details
-- Approach: CTE calculates revenue per pizza, DENSE_RANK() OVER(PARTITION BY category) ranks within each category
-- Output: top 3 revenue generating pizzas per category with their sales and rank
WITH ranked_pizzas AS (
	SELECT  
		pt.pizza_category, 
		pt.pizza_name, 
        SUM(p.pizza_price * od.order_quantity) AS sales, 
        DENSE_RANK() OVER (
			PARTITION BY pt.pizza_category ORDER BY sum(p.pizza_price * od.order_quantity
		) DESC ) AS rnk 
	FROM pizza_types pt 
	JOIN pizzas p 
	ON pt.pizza_types_id = p.pizza_types_id 
	JOIN order_details od 
	ON p.pizza_id = od.pizza_id 
	GROUP BY pt.pizza_category, pt.pizza_name
) 
SELECT 
	pizza_category, 
    pizza_name, 
    sales, 
    rnk 
FROM ranked_pizzas 
WHERE rnk<=3 
ORDER BY pizza_category, rnk;

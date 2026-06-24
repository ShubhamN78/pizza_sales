# Pizza Sales Project — Documentation

---

## 1. Dataset Description

The dataset contains pizza sales records with 4 CSV files:

### orders.csv
| Column | Data Type | Description |
|--------|-----------|-------------|
| order_id | INT | Unique identifier for each order (Primary Key) |
| order_date | DATE | Date the order was placed |
| order_time | TIME | Time the order was placed |

### pizza_types.csv
| Column | Data Type | Description |
|--------|-----------|-------------|
| pizza_types_id | VARCHAR(50) | Unique identifier for pizza type (Primary Key) |
| pizza_name | VARCHAR(100) | Name of the pizza |
| pizza_category | VARCHAR(50) | Category (Classic, Chicken, Veggie, Supreme) |
| pizza_ingredients | TEXT | List of ingredients |

### pizzas.csv
| Column | Data Type | Description |
|--------|-----------|-------------|
| pizza_id | VARCHAR(50) | Unique identifier for each pizza (Primary Key) |
| pizza_types_id | VARCHAR(50) | Reference to pizza type (Foreign Key) |
| pizza_size | VARCHAR(10) | Size of pizza (S, M, L, XL, XXL) |
| pizza_price | DECIMAL(5,2) | Price of the pizza |

### order_details.csv
| Column | Data Type | Description |
|--------|-----------|-------------|
| order_details_id | INT | Unique identifier for each order line (Primary Key) |
| order_id | INT | Reference to order (Foreign Key) |
| pizza_id | VARCHAR(50) | Reference to pizza (Foreign Key) |
| order_quantity | INT | Quantity of pizza ordered |

---

### top_3_per_category.csv
| Column | Data Type | Description |
|--------|-----------|-------------|
| pizza_category | VARCHAR | Category of pizza |
| pizza_name | VARCHAR | Name of pizza |
| sales | DECIMAL | Total revenue generated |
| rnk | INT | Rank within category based on revenue |

> This file is exported from Q13 SQL query result — it is NOT stored in MySQL database. It was imported directly into Power BI and connected to pizza_types table using pizza_name column.

### Table Relationships
```
pizza_types (PK: pizza_types_id)
    |
    | one to many
    |
pizzas (PK: pizza_id, FK: pizza_types_id)
    |
    | one to many
    |
order_details (PK: order_details_id, FK: pizza_id, FK: order_id)
    |
    | many to one
    |
orders (PK: order_id)
```

### Constraints Used
| Constraint | Type | Reason |
|------------|------|--------|
| PRIMARY KEY | All tables | Uniquely identify each row |
| FOREIGN KEY | pizzas, order_details | Maintain referential integrity |
| NOT NULL | PK and FK columns | Ensure critical data is always present |
| ON DELETE RESTRICT | All FK | Prevent accidental deletion of parent rows |
| ON UPDATE CASCADE | All FK | Auto update child rows when parent ID changes |

---

## 3. SQL Scripts

### 1_create_tables.sql
Creates the database and all 4 tables with proper data types, primary keys, foreign keys, and constraints. Import order for CSV data:
```
orders → pizza_types → pizzas → order_details
```
Import order matters because child tables (pizzas, order_details) have foreign keys referencing parent tables (pizza_types, orders).

### 2_analysis_queries.sql
Contains all 13 analysis queries organized into three sections:

---

## 4. Query Documentation

### Basic Queries

#### Q1. Total Number of Orders Placed
- **Tables:** orders
- **Approach:** COUNT() on order_id
- **Output:** Single value — total orders

#### Q2. Total Revenue Generated
- **Tables:** pizzas, order_details
- **Approach:** SUM(price × quantity) with ROUND to 2 decimals
- **Output:** Single value — total revenue

#### Q3. Highest Priced Pizza
- **Tables:** pizza_types, pizzas
- **Approach:** JOIN both tables, ORDER BY price DESC, LIMIT 1
- **Output:** Pizza name and its price

#### Q4. Most Common Pizza Size Ordered
- **Tables:** pizzas, order_details
- **Approach:** SUM(quantity) GROUP BY size, ORDER BY total DESC, LIMIT 1
- **Output:** Pizza size with highest total quantity

#### Q5. Top 5 Most Ordered Pizza Types
- **Tables:** pizza_types, pizzas, order_details
- **Approach:** SUM(quantity) GROUP BY pizza name, ORDER BY total DESC, LIMIT 5
- **Output:** Top 5 pizza names with their total quantities

---

### Intermediate Queries

#### Q6. Total Quantity Per Pizza Category
- **Tables:** pizza_types, pizzas, order_details
- **Approach:** Three table JOIN, SUM(quantity) GROUP BY category
- **Output:** Each category with its total quantity ordered

#### Q7. Order Distribution by Hour
- **Tables:** orders
- **Approach:** HOUR(order_time) to extract hour, COUNT(order_id) GROUP BY hour
- **Output:** Each hour with total orders placed

#### Q8. Category-wise Pizza Distribution
- **Tables:** pizza_types
- **Approach:** COUNT(pizza_name) GROUP BY category
- **Output:** Each category with count of pizzas in it

#### Q9. Average Pizzas Ordered Per Day
- **Tables:** orders, order_details
- **Approach:** Subquery calculates daily total using SUM + GROUP BY date, outer query takes AVG of daily totals
- **Output:** Single value — average pizzas per day

#### Q10. Top 3 Pizza Types by Revenue
- **Tables:** pizza_types, pizzas, order_details
- **Approach:** SUM(price × quantity) GROUP BY pizza name, ORDER BY revenue DESC, LIMIT 3
- **Output:** Top 3 pizza names with their total revenue

---

### Advanced Queries

#### Q11. Percentage Contribution of Each Category to Total Revenue
- **Tables:** pizza_types, pizzas, order_details
- **Approach:** Subquery calculates overall total revenue, outer query divides each category revenue by total and multiplies by 100
- **Output:** Each category with total sales and revenue percentage

#### Q12. Cumulative Revenue Over Time
- **Tables:** orders, order_details, pizzas
- **Approach:** CTE calculates daily revenue using SUM + GROUP BY date, window function SUM() OVER(ORDER BY date) builds running total row by row
- **Output:** Each date with daily sales and cumulative revenue up to that date

#### Q13. Top 3 Revenue Generating Pizzas Per Category
- **Tables:** pizza_types, pizzas, order_details
- **Approach:** CTE calculates revenue per pizza per category, DENSE_RANK() OVER(PARTITION BY category ORDER BY revenue DESC) assigns rank within each category, outer query filters WHERE rank <= 3
- **Output:** Top 3 revenue pizzas per category with sales and rank

---

## 6. Key Insights

### Basic
- **Q1:** A total of **21,350 orders** were placed
- **Q2:** Total revenue generated was **$817,860.05**
- **Q3:** The highest priced pizza is **The Greek Pizza** at **$35.95**
- **Q4:** **Large size** was the most ordered with **18,956** pizzas sold

### Intermediate
- **Q6:** **Classic category** is the most ordered with **14,888** pizzas sold
- **Q7:** Peak ordering hour is **12PM** with **2,520** orders placed
- **Q9:** Average of **138 pizzas** are ordered per day
- **Q10:** **The Classic Deluxe Pizza** is the top pizza by quantity with **2,453** orders

### Advanced
- **Q11:** Classic category leads revenue at **26.91% ($220,053.10)**, Veggie is lowest at **23.68% ($193,690.45)**
- **Q12:** Revenue grows consistently over time averaging **$138** worth of pizzas per day
- **Q13:** Top revenue generating pizza per category:

| Category | Pizza | Revenue |
|----------|-------|---------|
| Chicken | The Thai Chicken Pizza | $43,434.25 |
| Classic | The Classic Deluxe Pizza | $38,180.50 |
| Supreme | The Spicy Italian Pizza | $34,831.25 |
| Veggie | The Four Cheese Pizza | $32,265.70 |

## 8. Power BI Dashboard

### Tool
Microsoft Power BI Desktop Version 2.155.756.0 (June 2026)

### Data Connection
- Connected directly to MySQL pizza_sales database
- Selected and loaded 4 tables: orders, pizza_types, pizzas, order_details
- Imported top_3_per_category.csv separately — this table was exported from Q13 query result in MySQL and is NOT part of the MySQL database
- top_3_per_category table was connected to pizza_types table in Power BI using pizza_name column

### Calendar Table
Created a calendar table in Power BI for date slicer and time intelligence functions

### Calculated Columns
| Column | Table | Formula |
|--------|-------|---------|
| Sales | order_details | pizza_price × order_quantity |
| Order Hour | orders | HOUR(order_time) |

### DAX Measures
| Measure | Description |
|---------|-------------|
| Total Revenue | Sum of all pizza sales |
| Total Orders | Count of all orders |
| Total Pizzas Sold | Sum of all order quantities |
| Average Order Value | Total Revenue / Total Orders |

### Slicers
| Slicer | Style | Field |
|--------|-------|-------|
| Date | Range slider | order_date |
| Pizza Category | Tiles | pizza_category |
| Pizza Size | Checkbox | pizza_size |
| Pizza Name | Dropdown | pizza_name |

### Visuals
| Visual | Chart Type | Fields Used |
|--------|-----------|-------------|
| Sales by Month | Line chart | order_date, total revenue |
| Sales by Pizza Category | Donut chart | pizza_category, total revenue |
| Orders by Hour | Line chart | order_hour, total orders |
| Sales by Pizza Size | Bar chart | pizza_size, total revenue |
| Top 5 Pizzas by Sales | Bar chart | pizza_name, total revenue |
| Top 3 Pizzas Per Category | Matrix | pizza_category, pizza_name, sales |

### KPI Cards
| Card | Value |
|------|-------|
| Total Revenue | $8,17,860.05 |
| Total Orders | 21,350 |
| Total Pizzas Sold | 49,574 |
| Average Order Value | $38.31 |

| Concept | Used In |
|---------|---------|
| JOIN (2 tables) | Q2, Q3, Q4 |
| JOIN (3 tables) | Q5, Q6, Q10, Q11, Q12, Q13 |
| GROUP BY | Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11 |
| Subquery | Q9, Q11 |
| CTE (WITH clause) | Q12, Q13 |
| Window Functions | Q12, Q13 |
| DENSE_RANK() | Q13 |
| PARTITION BY | Q13 |
| SUM() OVER() | Q12 |
| ROUND() | Q2, Q9, Q11 |
| HOUR() | Q7 |

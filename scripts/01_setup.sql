CREATE DATABASE pizza_sales;

USE pizza_sales;

CREATE TABLE orders (
    order_id INT NOT NULL PRIMARY KEY,
    order_date DATE,
    order_time TIME
);

CREATE TABLE pizza_types (
    pizza_types_id VARCHAR(50) NOT NULL PRIMARY KEY,
    pizza_name VARCHAR(100),
    pizza_category VARCHAR(50),
    pizza_ingredients TEXT
);

CREATE TABLE pizzas (
    pizza_id VARCHAR(50) NOT NULL PRIMARY KEY,
    pizza_types_id VARCHAR(50) NOT NULL,
    pizza_size VARCHAR(10),
    pizza_price DECIMAL(5 , 2 ),
    CONSTRAINT fk_pizza_types_id FOREIGN KEY (pizza_types_id)
        REFERENCES pizza_types (pizza_types_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id VARCHAR(50) NOT NULL,
    order_quantity INT,
    CONSTRAINT fk_order_id FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pizza_id FOREIGN KEY (pizza_id)
        REFERENCES pizzas (pizza_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


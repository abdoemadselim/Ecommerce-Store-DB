CREATE TABLE category (
	id INT UNSIGNED AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL CHECK (TRIM(name) <> ''),
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
	PRIMARY KEY(id)
);

CREATE TABLE product (
	id INT UNSIGNED AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL CHECK (TRIM(name) <> ''),
    description TEXT NOT NULL INVISIBLE,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0.00),
    stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
    category_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    author_id INT UNSIGNED,
    
    PRIMARY KEY(id),
    FOREIGN KEY(category_id) REFERENCES category(id),
    FOREIGN KEY(author_id) REFERENCE customer(id)
);

CREATE TABLE customer (
	id INT UNSIGNED AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(255) UNIQUE NOT NULL,
    password CHAR(60) NOT NULL INVISIBLE,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,    

    PRIMARY KEY(id)
);

CREATE TABLE `order` (
	id INT UNSIGNED AUTO_INCREMENT,
    order_date DATE NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    customer_id INT UNSIGNED NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL CHECK (total_amount >= 0.00),
    
    PRIMARY KEY(id),
    INDEX (order_date),
    FOREIGN KEY(customer_id) REFERENCES customer(id)
);

CREATE TABLE order_item (
	order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0.00),
    
    PRIMARY KEY(order_id, product_id),
    FOREIGN KEY(order_id) REFERENCES `order`(id),
    FOREIGN KEY(product_id) REFERENCES `product`(id)
);

-- SUMMARY TABLE FOR THE DAILY REVENUE 
CREATE TABLE daily_report(
	order_date DATE NOT NULL PRIMARY KEY,
	revenue DECIMAL(12, 2) NOT NULL
);

-- SUMMARY TABLE FOR THE MONTLY TOP SELLING 5 PRODUCTS (PER UNITS)
CREATE TABLE monthly_report (
	sale_month DATE, # stored as the first of the month (2021-01-01, 2021-02-01, etc.)
    product_id INT UNSIGNED,
    product_name VARCHAR(50),
    total_quantity INT UNSIGNED,
    
    PRIMARY KEY(sale_month, total_quantity DESC, product_id)
); 

-- DENORMALIZED TABLE FOR CUSTOMER AND ORDER TABLES 
CREATE TABLE customer_orders (
	customer_id INT UNSIGNED NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(255) NOT NULL,
    
	order_id INT UNSIGNED NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    
    INDEX (order_date),
    PRIMARY KEY(customer_id, order_id)
);





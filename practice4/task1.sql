CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(12, 2) CHECK (price > 0),
    rating FLOAT CHECK (rating >= 0 AND rating <= 5)
);

CREATE TYPE order_status_enum AS ENUM ('shipped', 'processing', 'completed', 'cancelled', 'returned');

CREATE TABLE orders (
    order_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(50) NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    order_date TIMESTAMP NOT NULL,
    order_status order_status_enum NOT NULL,
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_2024 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2025-01-01 00:00:00');

CREATE TABLE orders_2025 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01 00:00:00') TO ('2026-01-01 00:00:00');

CREATE TABLE order_items (
    order_item_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    product_id VARCHAR(50) REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER CHECK (quantity > 0),
    item_price DECIMAL(12, 2) CHECK (item_price >= 0),
    FOREIGN KEY (order_id, order_date) REFERENCES orders(order_id, order_date) ON DELETE CASCADE
);
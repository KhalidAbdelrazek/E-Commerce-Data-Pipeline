USE [E-Commerce];
GO

-- 1. DROP TABLES (Reverse order of dependencies)
IF OBJECT_ID('dbo.fact_orders', 'U') IS NOT NULL DROP TABLE dbo.fact_orders;
IF OBJECT_ID('dbo.dim_reviews', 'U') IS NOT NULL DROP TABLE dbo.dim_reviews;
IF OBJECT_ID('dbo.dim_customers', 'U') IS NOT NULL DROP TABLE dbo.dim_customers;
IF OBJECT_ID('dbo.dim_products', 'U') IS NOT NULL DROP TABLE dbo.dim_products;
IF OBJECT_ID('dbo.dim_sellers', 'U') IS NOT NULL DROP TABLE dbo.dim_sellers;
IF OBJECT_ID('dbo.dim_date', 'U') IS NOT NULL DROP TABLE dbo.dim_date;
GO

-- 2. CREATE DIMENSIONS
CREATE TABLE dbo.dim_date(
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayNumberOfWeek INT,
    DayNameOfWeek NVARCHAR(20),
    DayNumberOfMonth INT,
    MonthNumberOfYear INT,
    MonthName NVARCHAR(20),
    Quarter INT,
    Year INT,
    IsWeekend BIT
);

CREATE TABLE dbo.dim_customers(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    customer_id NVARCHAR(50) UNIQUE,
    customer_unique_id NVARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(10)
);

CREATE TABLE dbo.dim_products(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    product_id NVARCHAR(50) UNIQUE,
    product_category_name NVARCHAR(100),
    product_category_name_english NVARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(18,2),
    product_length_cm DECIMAL(18,2),
    product_height_cm DECIMAL(18,2),
    product_width_cm DECIMAL(18,2)
);

CREATE TABLE dbo.dim_sellers(
    SellerKey INT IDENTITY(1,1) PRIMARY KEY,
    seller_id NVARCHAR(50) UNIQUE,
    seller_zip_code_prefix INT,
    seller_city NVARCHAR(100),
    seller_state NVARCHAR(10)
);

CREATE TABLE dbo.dim_reviews(
    ReviewKey INT IDENTITY(1,1) PRIMARY KEY,
    review_id NVARCHAR(50), 
    review_score INT,
    review_comment_title NVARCHAR(255),
    review_comment_message NVARCHAR(MAX),
    review_creation_date_key INT,
    review_answer_timestamp DATETIME,
    CONSTRAINT FK_Review_Date FOREIGN KEY (review_creation_date_key) REFERENCES dbo.dim_date(DateKey)
);

-- 3. CREATE FACT TABLE
CREATE TABLE dbo.fact_orders(
    FactKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id NVARCHAR(50),
    order_item_id INT,
    order_status NVARCHAR(50),
    CustomerKey INT,
    ProductKey INT,
    SellerKey INT,
    ReviewKey INT,
    price DECIMAL(18,2),
    freight_value DECIMAL(18,2),
    payment_sequential INT,
    payment_type NVARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(18,2),
    OrderPurchaseDateKey INT,
    OrderApprovedDateKey INT,
    DeliveredCarrierDateKey INT,
    DeliveredCustomerDateKey INT,
    EstimatedDeliveryDateKey INT,
    ReviewCreationDateKey INT,
    ReviewAnswerDateKey INT,
    ShippingLimitDateKey INT,

    -- Foreign Key Constraints
    CONSTRAINT FK_Fact_Customer FOREIGN KEY (CustomerKey) REFERENCES dbo.dim_customers(CustomerKey),
    CONSTRAINT FK_Fact_Product FOREIGN KEY (ProductKey) REFERENCES dbo.dim_products(ProductKey),
    CONSTRAINT FK_Fact_Seller FOREIGN KEY (SellerKey) REFERENCES dbo.dim_sellers(SellerKey),
    CONSTRAINT FK_Fact_Review FOREIGN KEY (ReviewKey) REFERENCES dbo.dim_reviews(ReviewKey),
    CONSTRAINT FK_Fact_PurchaseDate FOREIGN KEY (OrderPurchaseDateKey) REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_Fact_ApprovedDate FOREIGN KEY (OrderApprovedDateKey) REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_Fact_CarrierDate FOREIGN KEY (DeliveredCarrierDateKey) REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_Fact_DeliveredDate FOREIGN KEY (DeliveredCustomerDateKey) REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_Fact_EstimatedDate FOREIGN KEY (EstimatedDeliveryDateKey) REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_Fact_RevCreateDate FOREIGN KEY (ReviewCreationDateKey) REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_Fact_RevAnsDate FOREIGN KEY (ReviewAnswerDateKey) REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_Fact_ShipLimitDate FOREIGN KEY (ShippingLimitDateKey) REFERENCES dbo.dim_date(DateKey)
);
GO


SELECT 
    -- Order Info (from Fact)
    f.order_id,
    f.order_item_id,
    f.order_status,
    f.price,
    f.freight_value,
    f.payment_value,
    f.payment_type,

    -- Customer Info
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    -- Product Info
    p.product_category_name_english,
    p.product_weight_g,

    -- Seller Info
    s.seller_city,
    s.seller_state,

    -- Review Info
    r.review_score,
    r.review_comment_message,

    -- Dates (Joining to dim_date multiple times)
    d_purch.FullDate AS PurchaseDate,
    d_deliv.FullDate AS DeliveryDate,
    d_est.FullDate AS EstimatedDate

FROM dbo.fact_orders f
-- Joining Dimensions
LEFT JOIN dbo.dim_customers c ON f.CustomerKey = c.CustomerKey
LEFT JOIN dbo.dim_products p  ON f.ProductKey = p.ProductKey
LEFT JOIN dbo.dim_sellers s   ON f.SellerKey = s.SellerKey
LEFT JOIN dbo.dim_reviews r   ON f.ReviewKey = r.ReviewKey

-- Joining Date Dimension (Role-Playing Joins)
LEFT JOIN dbo.dim_date d_purch ON f.OrderPurchaseDateKey = d_purch.DateKey
LEFT JOIN dbo.dim_date d_deliv ON f.DeliveredCustomerDateKey = d_deliv.DateKey
LEFT JOIN dbo.dim_date d_est   ON f.EstimatedDeliveryDateKey = d_est.DateKey;
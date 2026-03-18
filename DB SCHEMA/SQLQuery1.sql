-- ================= DIM CUSTOMERS =================
IF OBJECT_ID('dbo.dim_customers','U') IS NULL
BEGIN
CREATE TABLE dbo.dim_customers(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    customer_id NVARCHAR(36) UNIQUE,
    customer_unique_id NVARCHAR(36),
    customer_zip_code_prefix INT,
    customer_city NVARCHAR(50),
    customer_state NVARCHAR(10)
)
END
GO

-- ================= DIM PRODUCTS =================
IF OBJECT_ID('dbo.dim_products','U') IS NULL
BEGIN
CREATE TABLE dbo.dim_products(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    product_id NVARCHAR(36) UNIQUE,
    product_category_name NVARCHAR(50),
    product_category_name_english NVARCHAR(50),
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
)
END
GO




-- ================= DIM SELLERS =================
IF OBJECT_ID('dbo.dim_sellers','U') IS NULL
BEGIN
CREATE TABLE dbo.dim_sellers(
    SellerKey INT IDENTITY(1,1) PRIMARY KEY,
    seller_id NVARCHAR(36) UNIQUE,
    seller_zip_code_prefix INT,
    seller_city NVARCHAR(50),
    seller_state NVARCHAR(10)
)
END
GO

-- ================= DIM DATE =================
IF OBJECT_ID('dbo.dim_date','U') IS NULL
BEGIN
CREATE TABLE dbo.dim_date(
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayNumberOfWeek INT NOT NULL,
    DayNameOfWeek NVARCHAR(15) NOT NULL,
    DayNumberOfMonth INT NOT NULL,
    MonthNumberOfYear INT NOT NULL,
    MonthName NVARCHAR(15) NOT NULL,
    Quarter INT NOT NULL,
    Year INT NOT NULL,
    IsWeekend BIT NOT NULL
)
END
GO


-- ================= DIM REVIEWS =================
IF OBJECT_ID('dbo.dim_reviews','U') IS NULL
BEGIN
    CREATE TABLE dbo.dim_reviews(
        ReviewKey INT IDENTITY(1,1) PRIMARY KEY,
        review_id NVARCHAR(36) UNIQUE,
        review_score INT,
        review_comment_title NVARCHAR(255),
        review_comment_message NVARCHAR(MAX),
        review_creation_date_key INT, -- FK to dim_date
        review_answer_timestamp DATETIME
)
END
GO

-- ================= FACT ORDERS =================
IF OBJECT_ID('dbo.fact_orders','U') IS NULL
BEGIN
CREATE TABLE dbo.fact_orders(
    FactKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id NVARCHAR(50),
    order_item_id INT,
    CustomerKey INT,
    ProductKey INT,
    SellerKey INT,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    payment_value DECIMAL(10,2),
    ReviewKey INT,
    OrderPurchaseDateKey INT,
    OrderApprovedDateKey INT,
    DeliveredCarrierDateKey INT,
    DeliveredCustomerDateKey INT,
    EstimatedDeliveryDateKey INT,
    ReviewCreationDateKey INT,
    ReviewAnswerDateKey INT,
    ShippingLimitDateKey INT,
    
    CONSTRAINT FK_Customer FOREIGN KEY(CustomerKey)
        REFERENCES dbo.dim_customers(CustomerKey),
    CONSTRAINT FK_Product FOREIGN KEY(ProductKey)
        REFERENCES dbo.dim_products(ProductKey),
    CONSTRAINT FK_Seller FOREIGN KEY(SellerKey)
        REFERENCES dbo.dim_sellers(SellerKey),
    CONSTRAINT FK_Review FOREIGN KEY(ReviewKey)
        REFERENCES dbo.dim_reviews(ReviewKey),
    CONSTRAINT FK_OrderPurchaseDate FOREIGN KEY(OrderPurchaseDateKey)
        REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_OrderApprovedDate FOREIGN KEY(OrderApprovedDateKey)
        REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_DeliveredCarrierDate FOREIGN KEY(DeliveredCarrierDateKey)
        REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_DeliveredCustomerDate FOREIGN KEY(DeliveredCustomerDateKey)
        REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_EstimatedDeliveryDate FOREIGN KEY(EstimatedDeliveryDateKey)
        REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_ReviewCreationDate FOREIGN KEY(ReviewCreationDateKey)
        REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_ReviewAnswerDate FOREIGN KEY(ReviewAnswerDateKey)
        REFERENCES dbo.dim_date(DateKey),
    CONSTRAINT FK_ShippingLimitDate FOREIGN KEY(ShippingLimitDateKey)
        REFERENCES dbo.dim_date(DateKey)
)
END
GO

select * from fact_orders
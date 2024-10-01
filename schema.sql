-- Stores table
CREATE TABLE Stores (
    StoreID       NUMBER PRIMARY KEY,
    StoreName     VARCHAR2(100) NOT NULL,
    CreatedAt     DATE DEFAULT SYSDATE
);

-- Consumers table
CREATE TABLE Consumers (
    CustomerID    NUMBER PRIMARY KEY,
    Username      VARCHAR2(50) UNIQUE NOT NULL,
    PasswordHash  VARCHAR2(255) NOT NULL,  -- Stores the hashed password
    FullName      VARCHAR2(100),
    Email         VARCHAR2(100),
    CreatedAt     DATE DEFAULT SYSDATE
);

-- Platform administrators table
CREATE TABLE PlatformAdmins (
    AdminID       NUMBER PRIMARY KEY,
    Username      VARCHAR2(50) UNIQUE NOT NULL,
    PasswordHash  VARCHAR2(255) NOT NULL,  -- Stores the hashed password
    FullName      VARCHAR2(100),
    Email         VARCHAR2(100),
    CreatedAt     DATE DEFAULT SYSDATE
);

-- Association table between platform administrators and stores
CREATE TABLE PlatformAdminStores (
    AdminID       NUMBER NOT NULL,
    StoreID       NUMBER NOT NULL,
    CONSTRAINT pk_platformadminstores PRIMARY KEY (AdminID, StoreID),
    CONSTRAINT fk_pas_adminid FOREIGN KEY (AdminID)
        REFERENCES PlatformAdmins(AdminID)
        ON DELETE CASCADE,
    CONSTRAINT fk_pas_storeid FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID)
        ON DELETE CASCADE
);

-- Store staff table
CREATE TABLE StoreStaff (
    StaffID       NUMBER PRIMARY KEY,
    Username      VARCHAR2(50) UNIQUE NOT NULL,
    PasswordHash  VARCHAR2(255) NOT NULL,  -- Stores the hashed password
    FullName      VARCHAR2(100),
    Email         VARCHAR2(100),
    StoreID       NUMBER NOT NULL,
    Role          VARCHAR2(20) CHECK (Role IN ('Admin', 'CustomerService')),
    CreatedAt     DATE DEFAULT SYSDATE,
    CONSTRAINT fk_staff_store FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID)
        ON DELETE CASCADE
);

-- Products table
CREATE TABLE Products (
    ProductID     NUMBER PRIMARY KEY,
    StoreID       NUMBER NOT NULL,
    ProductName   VARCHAR2(100) NOT NULL,
    Description   VARCHAR2(4000),
    Price         NUMBER(10, 2) NOT NULL,
    Quantity      NUMBER NOT NULL,
    CreatedAt     DATE DEFAULT SYSDATE,
    CONSTRAINT fk_products_store FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID)
        ON DELETE CASCADE
);

-- Orders table
CREATE TABLE Orders (
    OrderID       NUMBER PRIMARY KEY,
    CustomerID    NUMBER NOT NULL,
    OrderDate     DATE DEFAULT SYSDATE,
    TotalAmount   NUMBER(10, 2) NOT NULL,
    Status        VARCHAR2(20) DEFAULT 'Pending',
    CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID)
        REFERENCES Consumers(CustomerID)
        ON DELETE CASCADE
);

-- Order items table
CREATE TABLE OrderItems (
    OrderItemID   NUMBER PRIMARY KEY,
    OrderID       NUMBER NOT NULL,
    ProductID     NUMBER NOT NULL,
    Quantity      NUMBER NOT NULL,
    UnitPrice     NUMBER(10, 2) NOT NULL,
    CONSTRAINT fk_orderitems_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,
    CONSTRAINT fk_orderitems_product FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

-- Payments table
CREATE TABLE Payments (
    PaymentID     NUMBER PRIMARY KEY,
    OrderID       NUMBER NOT NULL,
    PaymentDate   DATE DEFAULT SYSDATE,
    Amount        NUMBER(10, 2) NOT NULL,
    PaymentMethod VARCHAR2(50),
    Status        VARCHAR2(20) DEFAULT 'Completed',
    CONSTRAINT fk_payments_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);

-- Customer messages table
CREATE TABLE CustomerMessages (
    MessageID     NUMBER PRIMARY KEY,
    StoreID       NUMBER NOT NULL,
    SenderID      NUMBER NOT NULL,
    ReceiverID    NUMBER NOT NULL,
    SenderType    VARCHAR2(20) CHECK (SenderType IN ('Consumer', 'Staff')),
    ReceiverType  VARCHAR2(20) CHECK (ReceiverType IN ('Consumer', 'Staff')),
    MessageText   VARCHAR2(4000),
    SentAt        DATE DEFAULT SYSDATE,
    CONSTRAINT fk_messages_store FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID)
);

-- ******************************************************
-- ** Testing VPD Functionality for Platform Administrator **
-- ******************************************************

-- User: admin1
-- Replace "YourPassword" with the actual password for 'admin1'

-- Connect to the database as platform administrator 'admin1'
CONNECT admin1/"YourPassword";

-- Verify that the platform administrator context is properly set
SELECT
    SYS_CONTEXT('platformadmin_ctx', 'admin_id') AS admin_id
FROM DUAL;
-- Expected Result:
-- Returns the AdminID associated with 'admin1', confirming that the context is set correctly.

-- Attempt to select all records from the PlatformAdmins table
SELECT * FROM PlatformAdmins;
-- Expected Result:
-- Only the record for 'admin1' is returned due to the VPD policy restricting access to own admin record.

-- Try to select other platform administrators' data
SELECT * FROM PlatformAdmins WHERE AdminID <> SYS_CONTEXT('platformadmin_ctx', 'admin_id');
-- Expected Result:
-- No records are returned; VPD policy prevents access to other administrators' data.

-- Access the Stores table to view stores managed by 'admin1'
SELECT * FROM Stores;
-- Expected Result:
-- Only stores associated with 'admin1' are displayed (e.g., stores linked via PlatformAdminStores table).

-- Attempt to access other stores
SELECT * FROM Stores WHERE StoreID NOT IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- No records are returned; cannot access stores not managed by 'admin1'.

-- Access the StoreStaff table to view staff from stores managed by 'admin1'
SELECT ss.*
FROM StoreStaff ss
JOIN Stores s ON ss.StoreID = s.StoreID
WHERE s.StoreID IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- Only staff members from 'admin1's stores are displayed.

-- Attempt to access staff from other stores
SELECT ss.*
FROM StoreStaff ss
WHERE ss.StoreID NOT IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- No records are returned; VPD policy prevents access to staff from other stores.

-- Access the Products table to view products from stores managed by 'admin1'
SELECT * FROM Products;
-- Expected Result:
-- Only products belonging to stores managed by 'admin1' are displayed.

-- Attempt to access products from other stores
SELECT * FROM Products WHERE StoreID NOT IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- No records are returned; cannot access products from stores not managed by 'admin1'.

-- Access the Orders table
SELECT * FROM Orders;
-- Expected Result:
-- Depending on VPD policies, 'admin1' may see all orders or only orders related to their stores.
-- If policies restrict to own stores, only orders containing products from 'admin1's stores are displayed.

-- Access the OrderItems table
SELECT oi.*
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.StoreID IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- Only order items for products from 'admin1's stores are returned.

-- Access the Payments table
SELECT DISTINCT p.*
FROM Payments p
JOIN Orders o ON p.OrderID = o.OrderID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products pr ON oi.ProductID = pr.ProductID
WHERE pr.StoreID IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- Only payments associated with orders containing products from 'admin1's stores are displayed.

-- Access the Consumers table
SELECT * FROM Consumers;
-- Expected Result:
-- All consumer records are accessible if VPD policies allow platform administrators full access.
-- Otherwise, access may be restricted.

-- Attempt to access the CustomerMessages table
SELECT * FROM CustomerMessages;
-- Expected Result:
-- Access may be denied or limited based on VPD policies.
-- If allowed, messages related to 'admin1's stores are displayed.

-- Access the PlatformAdminStores table to view own store associations
SELECT * FROM PlatformAdminStores;
-- Expected Result:
-- Only records where AdminID matches 'admin1' are displayed.

-- Attempt to access associations of other administrators
SELECT * FROM PlatformAdminStores WHERE AdminID <> SYS_CONTEXT('platformadmin_ctx', 'admin_id');
-- Expected Result:
-- No records are returned; cannot access other administrators' store associations.

-- ********************************************
-- ** Testing Data Modification (Update/Delete) **
-- ********************************************

-- Update own admin record
UPDATE PlatformAdmins
SET Email = 'alice.newemail@example.com'
WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id');
-- Expected Result:
-- The update succeeds; 'admin1' can update their own admin record.

-- Attempt to update another administrator's record
UPDATE PlatformAdmins
SET Email = 'hacker@example.com'
WHERE AdminID <> SYS_CONTEXT('platformadmin_ctx', 'admin_id');
-- Expected Result:
-- No rows are updated; VPD policy prevents modifying other administrators' records.

-- Update store information for a store managed by 'admin1'
UPDATE Stores
SET StoreName = 'Tech Gadgets Plus'
WHERE StoreID IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- The update succeeds; 'admin1' can modify stores they manage.

-- Attempt to update a store not managed by 'admin1'
UPDATE Stores
SET StoreName = 'Book Haven Plus'
WHERE StoreID NOT IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- No rows are updated; cannot modify stores not managed by 'admin1'.

-- Insert a new store and associate it with 'admin1'
INSERT INTO Stores (StoreID, StoreName)
VALUES (3, 'Electronics World');

INSERT INTO PlatformAdminStores (AdminID, StoreID)
VALUES (SYS_CONTEXT('platformadmin_ctx', 'admin_id'), 3);
-- Expected Result:
-- The insert succeeds; 'admin1' adds a new store and associates it with themselves.

-- Insert a new product into a store managed by 'admin1'
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity)
VALUES (8, 3, 'Smartwatch', 'Latest model smartwatch.', 299.99, 50);
-- Expected Result:
-- The insert succeeds; 'admin1' can add products to their managed stores.

-- Attempt to insert a product into a store not managed by 'admin1'
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity)
VALUES (9, 2, 'Tablet', 'High-resolution display tablet.', 399.99, 30);
-- Expected Result:
-- The insert fails or no rows are inserted; cannot add products to stores not managed by 'admin1'.

-- Delete a product from a store managed by 'admin1'
DELETE FROM Products
WHERE ProductID = 1; -- Assuming ProductID 1 belongs to a store managed by 'admin1'
-- Expected Result:
-- The delete operation succeeds; 'admin1' can delete products from their managed stores.

-- Attempt to delete a product from a store not managed by 'admin1'
DELETE FROM Products
WHERE ProductID = 3; -- Assuming ProductID 3 belongs to another store
-- Expected Result:
-- No rows are deleted; VPD policy prevents deleting products from stores not managed by 'admin1'.

-- Delete own store association
DELETE FROM PlatformAdminStores
WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id') AND StoreID = 1;
-- Expected Result:
-- The delete succeeds; 'admin1' can remove their own store associations.

-- Attempt to delete another administrator's store association
DELETE FROM PlatformAdminStores
WHERE AdminID <> SYS_CONTEXT('platformadmin_ctx', 'admin_id');
-- Expected Result:
-- No rows are deleted; cannot modify other administrators' store associations.

-- Attempt to access StoreStaff data directly
SELECT * FROM StoreStaff;
-- Expected Result:
-- Only staff from stores managed by 'admin1' are displayed.

-- Attempt to update a staff member from own stores
UPDATE StoreStaff
SET Email = 'staff.newemail@example.com'
WHERE StoreID IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- The update succeeds; 'admin1' can update staff records from their managed stores.

-- Attempt to update a staff member from other stores
UPDATE StoreStaff
SET Email = 'hacker@example.com'
WHERE StoreID NOT IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- No rows are updated; cannot modify staff from stores not managed by 'admin1'.

-- ********************************************
-- ** Additional Tests **
-- ********************************************

-- Access Orders containing products from stores managed by 'admin1'
SELECT DISTINCT o.*
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.StoreID IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- Orders related to 'admin1's stores are displayed.

-- Attempt to access Orders unrelated to 'admin1's stores
SELECT DISTINCT o.*
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.StoreID NOT IN (
    SELECT StoreID FROM PlatformAdminStores WHERE AdminID = SYS_CONTEXT('platformadmin_ctx', 'admin_id')
);
-- Expected Result:
-- No records are returned; cannot access orders not related to 'admin1's stores.

-- Disconnect from the database
DISCONNECT;

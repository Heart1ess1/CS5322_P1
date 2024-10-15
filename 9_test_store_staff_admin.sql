-- *****************************************************
-- ** Testing VPD Functionality for Store Staff - Admin **
-- *****************************************************

-- User: techstaff1
-- Replace "YourPassword" with the actual password for 'techstaff1'

-- Connect to the database as store staff 'techstaff1'
CONNECT techstaff1/"YourPassword";

-- Verify that the store staff context is properly set
SELECT
    SYS_CONTEXT('storestaff_ctx', 'staff_id') AS staff_id,
    SYS_CONTEXT('storestaff_ctx', 'store_id') AS store_id,
    SYS_CONTEXT('storestaff_ctx', 'role') AS role
FROM DUAL;
-- Expected Result:
-- Returns the StaffID, StoreID, and Role associated with 'techstaff1', confirming that the context is set correctly.

-- Attempt to select all records from the StoreStaff table
SELECT * FROM StoreStaff;
-- Expected Result:
-- Only the record for 'techstaff1' is returned due to the VPD policy restricting access to own staff record.

-- Try to select other store staff's data
SELECT * FROM StoreStaff WHERE StaffID <> SYS_CONTEXT('storestaff_ctx', 'staff_id');
-- Expected Result:
-- Only the record for Store 1 staffs.

-- Access the Products table to view products from own store
SELECT * FROM Products;
-- Expected Result:
-- Only products belonging to 'techstaff1's store (StoreID = 1) are displayed.
-- Products from other stores are not visible due to VPD policy.

-- Attempt to access products from another store
SELECT * FROM Products WHERE StoreID <> SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- No records are returned; cannot access products from other stores.

-- Access the Orders table to view orders containing products from own store
SELECT DISTINCT o.*
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- Only orders that include products from 'techstaff1's store are displayed.

-- Access the OrderItems table to view order items for products from own store
SELECT oi.*
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- Only order items for products from 'techstaff1's store are returned.

-- Access the Payments table to view payments related to own store's orders
SELECT DISTINCT p.*
FROM Payments p
JOIN Orders o ON p.OrderID = o.OrderID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products pr ON oi.ProductID = pr.ProductID
WHERE pr.StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- Only payments associated with orders containing products from 'techstaff1's store are displayed.

-- Attempt to access the Consumers table
SELECT * FROM Consumers;
-- Expected Result:
-- No records are returned; VPD policy restricts store staff from accessing Consumers table directly.

-- Access the Stores table to view own store information
SELECT * FROM Stores;
-- Expected Result:
-- Only the store associated with 'techstaff1' (StoreID = 1) is displayed.

-- Attempt to access other stores
SELECT * FROM Stores WHERE StoreID <> SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- No records are returned; cannot access other stores' information.

-- Access the CustomerMessages table to view messages related to own store
SELECT * FROM CustomerMessages;
-- Expected Result:
-- Only messages where StoreID matches 'techstaff1's store are displayed.

-- Attempt to access messages from other stores
SELECT * FROM CustomerMessages WHERE StoreID <> SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- No records are returned; cannot access messages from other stores.

-- Attempt to access the PlatformAdmins table
SELECT * FROM PlatformAdmins;
-- Expected Result:
-- No records are returned or an error occurs; store staff are not authorized to access 'PlatformAdmins' table.

-- Attempt to access the PlatformAdminStores table
SELECT * FROM PlatformAdminStores;
-- Expected Result:
-- No records are returned; store staff cannot access this table.

-- ********************************************
-- ** Testing Data Modification (Update/Delete) **
-- ********************************************

-- Update the price of a product in own store
UPDATE Products
SET Price = Price * 0.9
WHERE ProductID = 1; -- Assuming ProductID 1 belongs to StoreID 1
-- Expected Result:
-- The update succeeds; 'techstaff1' can update products in their own store.

-- Verify the update
SELECT * FROM Products WHERE ProductID = 1;
-- Expected Result:
-- The price of the product is updated.

-- Attempt to update a product from another store
UPDATE Products
SET Price = Price * 0.9
WHERE ProductID = 3; -- Assuming ProductID 3 belongs to another store (StoreID 2)
-- Expected Result:
-- No rows are updated; VPD policy prevents updating products from other stores.

-- Attempt to delete a product from own store
DELETE FROM Products
WHERE ProductID = 2; -- Assuming ProductID 2 belongs to StoreID 1
-- Expected Result:
-- The delete operation succeeds; 'techstaff1' can delete products from their own store.

-- Attempt to delete a product from another store
DELETE FROM Products
WHERE ProductID = 3; -- ProductID 3 belongs to StoreID 2
-- Expected Result:
-- No rows are deleted; VPD policy prevents deleting products from other stores.

-- Attempt to update own store information
UPDATE Stores
SET StoreName = 'Tech Gadgets Superstore'
WHERE StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- The update succeeds; 'techstaff1' can update their own store information.

-- Attempt to update another store's information
UPDATE Stores
SET StoreName = 'Book Haven Plus'
WHERE StoreID <> SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- No rows are updated; cannot modify other stores' information.

-- Attempt to delete own store (not recommended)
DELETE FROM Stores
WHERE StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- The delete may be prevented by policies; even if allowed, deleting the store could have cascading effects.

-- Attempt to access Consumers via a join
SELECT c.*
FROM Consumers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- No consumer data is returned; VPD policies prevent accessing consumer data even via joins.

-- ********************************************
-- ** Additional Tests **
-- ********************************************

-- Insert a new product into own store
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity)
VALUES (5, SYS_CONTEXT('storestaff_ctx', 'store_id'), 'Wireless Headphones', 'Noise-cancelling headphones.', 199.99, 25);
-- Expected Result:
-- The insert succeeds; 'techstaff1' can add new products to their own store.

-- Attempt to insert a product into another store
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity)
VALUES (6, 2, 'E-Reader', 'Portable e-reader device.', 129.99, 50);
-- Expected Result:
-- The insert fails or no rows are inserted; cannot add products to other stores.

-- Update own staff record
UPDATE StoreStaff
SET Email = 'charlie.newemail@example.com'
WHERE StaffID = SYS_CONTEXT('storestaff_ctx', 'staff_id');
-- Expected Result:
-- The update succeeds; 'techstaff1' can update their own staff record.

-- Attempt to update another staff member's record
UPDATE StoreStaff
SET Email = 'hacker@example.com'
WHERE StaffID <> SYS_CONTEXT('storestaff_ctx', 'staff_id');
-- Expected Result:
-- No rows are updated; cannot modify other staff members' records.

-- Attempt to access OrderItems directly
SELECT * FROM OrderItems;
-- Expected Result:
-- Only order items for products from 'techstaff1's store are returned.

-- Attempt to access Orders directly
SELECT * FROM Orders;
-- Expected Result:
-- Only orders containing products from 'techstaff1's store are displayed.

-- Disconnect from the database
DISCONNECT;

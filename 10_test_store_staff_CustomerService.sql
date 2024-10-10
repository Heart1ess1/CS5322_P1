-- **************************************************************
-- ** Testing VPD Functionality for Store Staff - CustomerService **
-- **************************************************************

-- User: bookstaff1
-- Replace "YourPassword" with the actual password for 'bookstaff1'

-- Connect to the database as store staff 'bookstaff1'
CONNECT bookstaff1/"YourPassword";

-- Verify that the store staff context is properly set
SELECT
    SYS_CONTEXT('storestaff_ctx', 'staff_id') AS staff_id,
    SYS_CONTEXT('storestaff_ctx', 'store_id') AS store_id,
    SYS_CONTEXT('storestaff_ctx', 'role') AS role
FROM DUAL;
-- Expected Result:
-- Returns the StaffID, StoreID, and Role associated with 'bookstaff1', confirming that the context is set correctly.

-- Attempt to select all records from the StoreStaff table
SELECT * FROM StoreStaff;
-- Expected Result:
-- Only the record for 'bookstaff1' is returned due to the VPD policy restricting access to own staff record.

-- Try to select other store staff's data
SELECT * FROM StoreStaff WHERE StaffID <> SYS_CONTEXT('storestaff_ctx', 'staff_id');
-- Expected Result:
-- No records are returned; VPD policy prevents access to other staff members' data.

-- Access the Products table to view products from own store
SELECT * FROM Products;
-- Expected Result:
-- Only products belonging to 'bookstaff1's store (StoreID = 2) are displayed.
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
-- Only orders that include products from 'bookstaff1's store are displayed.

-- Access the OrderItems table to view order items for products from own store
SELECT oi.*
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- Only order items for products from 'bookstaff1's store are returned.

-- Access the Payments table to view payments related to own store's orders
SELECT DISTINCT p.*
FROM Payments p
JOIN Orders o ON p.OrderID = o.OrderID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products pr ON oi.ProductID = pr.ProductID
WHERE pr.StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- Only payments associated with orders containing products from 'bookstaff1's store are displayed.

-- Attempt to access the Consumers table
SELECT * FROM Consumers;
-- Expected Result:
-- No records are returned; VPD policy restricts store staff from accessing Consumers table directly.

-- Access the Stores table to view own store information
SELECT * FROM Stores;
-- Expected Result:
-- Only the store associated with 'bookstaff1' (StoreID = 2) is displayed.

-- Attempt to access other stores
SELECT * FROM Stores WHERE StoreID <> SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- No records are returned; cannot access other stores' information.

-- Access the CustomerMessages table to view messages related to own store
SELECT * FROM CustomerMessages;
-- Expected Result:
-- Only messages where StoreID matches 'bookstaff1's store are displayed.

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

-- Attempt to update the price of a product in own store
UPDATE Products
SET Price = Price * 0.95
WHERE ProductID = 3; -- Assuming ProductID 3 belongs to StoreID 2
-- Expected Result:
-- The update may be allowed or denied based on VPD policies.
-- Since 'bookstaff1' has the role 'CustomerService', they might not have update privileges.
-- If VPD policies restrict updates to 'Admin' role, this operation should fail.

-- Verify the update
SELECT * FROM Products WHERE ProductID = 3;
-- Expected Result:
-- If the update was denied, the price remains unchanged.

-- Attempt to update a product from another store
UPDATE Products
SET Price = Price * 0.95
WHERE ProductID = 1; -- ProductID 1 belongs to another store (StoreID 1)
-- Expected Result:
-- No rows are updated; VPD policy prevents updating products from other stores.

-- Attempt to delete a product from own store
DELETE FROM Products
WHERE ProductID = 4; -- Assuming ProductID 4 belongs to StoreID 2
-- Expected Result:
-- The delete operation may be denied due to role restrictions.
-- 'CustomerService' role might not have delete privileges on products.

-- Attempt to update own staff record
UPDATE StoreStaff
SET Email = 'dana.newemail@example.com'
WHERE StaffID = SYS_CONTEXT('storestaff_ctx', 'staff_id');
-- Expected Result:
-- The update succeeds; 'bookstaff1' can update their own staff record.

-- Attempt to update another staff member's record
UPDATE StoreStaff
SET Email = 'hacker@example.com'
WHERE StaffID <> SYS_CONTEXT('storestaff_ctx', 'staff_id');
-- Expected Result:
-- No rows are updated; cannot modify other staff members' records.

-- Attempt to update store information
UPDATE Stores
SET StoreName = 'Book Haven Deluxe'
WHERE StoreID = SYS_CONTEXT('storestaff_ctx', 'store_id');
-- Expected Result:
-- The update may be denied; 'CustomerService' role might not have privileges to update store information.

-- ********************************************
-- ** Additional Tests **
-- ********************************************

-- Attempt to insert a new product into own store
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity)
VALUES (7, SYS_CONTEXT('storestaff_ctx', 'store_id'), 'Pen Set', 'Set of premium pens.', 9.99, 100);
-- Expected Result:
-- The insert may be denied; 'CustomerService' role might not have insert privileges on products.

-- Attempt to access OrderItems directly
SELECT * FROM OrderItems;
-- Expected Result:
-- Only order items for products from 'bookstaff1's store are returned.

-- Attempt to access Orders directly
SELECT * FROM Orders;
-- Expected Result:
-- Only orders containing products from 'bookstaff1's store are displayed.

-- Disconnect from the database
DISCONNECT;

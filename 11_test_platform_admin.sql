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
select * from StoreStaff;
-- Expected Result:
-- Only staff members from 'admin1's stores are displayed.

-- Access the Products table to view products from stores managed by 'admin1'
SELECT * FROM Products;
-- Expected Result:
-- All users can read produces.

-- Access the Orders table
SELECT * FROM Orders;
-- Expected Result:
-- PlatformAdmin can read all orders.

-- Access the OrderItems table
SELECT * FROM OrderItems;
-- Expected Result:
-- PlatformAdmin can read all orderitems.

-- Access the Payments table
SELECT * FROM Payments;
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

-- Attempt to delete another administrator's store association
DELETE FROM PlatformAdminStores
WHERE AdminID <> SYS_CONTEXT('platformadmin_ctx', 'admin_id');
-- Expected Result:
-- No rows are deleted; cannot modify other administrators' store associations.

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

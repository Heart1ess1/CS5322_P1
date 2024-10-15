-- ***********************************************
-- ** Testing VPD Functionality for Customer Role **
-- ***********************************************

-- User: johndoe
-- Replace "YourPassword" with the actual password for 'johndoe'

-- Connect to the database as customer 'johndoe'
CONNECT johndoe/"Password";

-- Verify that the customer context is properly set
SELECT SYS_CONTEXT('customer_ctx', 'customer_id') AS customer_id FROM DUAL;
-- Expected Result:
-- Returns the CustomerID associated with 'johndoe', confirming that the context is set correctly.

-- Attempt to select all records from the Consumers table
SELECT * FROM Consumers;
-- Expected Result:
-- Only the record for 'johndoe' is returned due to the VPD policy restricting access to own data.

-- Try to select other customers' data
SELECT * FROM Consumers WHERE CustomerID <> SYS_CONTEXT('customer_ctx', 'customer_id');
-- Expected Result:
-- No records are returned; VPD policy prevents access to other customers' data.

-- Retrieve all orders placed by the customer
SELECT * FROM Orders;
-- Expected Result:
-- Only orders placed by 'johndoe' are displayed.

-- Retrieve order items associated with the customer's orders
SELECT oi.*
FROM OrderItems oi
JOIN Orders o ON oi.OrderID = o.OrderID;
-- Expected Result:
-- Only order items related to 'johndoe's orders are returned.

-- Retrieve payments made by the customer
SELECT p.*
FROM Payments p
JOIN Orders o ON p.OrderID = o.OrderID;
-- Expected Result:
-- Only payments associated with 'johndoe's orders are displayed.

-- View all available products
SELECT * FROM Products;
-- Expected Result:
-- All products are displayed; customers can view all products.

-- View all stores
SELECT * FROM Stores;
-- Expected Result:
-- All stores are visible to the customer.

-- Attempt to access store staff data
SELECT * FROM StoreStaff;
-- Expected Result:
-- No records are returned; VPD policy restricts customers from accessing 'StoreStaff' table.

-- Retrieve messages where the customer is the sender or receiver
SELECT * FROM CustomerMessages;
-- Expected Result:
-- Only messages where 'johndoe' is either the sender or receiver are displayed.

-- Update the customer's email address
UPDATE Consumers
SET Email = 'john.newemail@example.com'
WHERE CustomerID = SYS_CONTEXT('customer_ctx', 'customer_id');
-- Expected Result:
-- The update succeeds; 'johndoe' can update his own consumer record.

-- Attempt to update another customer's email address
UPDATE Consumers
SET Email = 'hacker@example.com'
WHERE CustomerID <> SYS_CONTEXT('customer_ctx', 'customer_id');
-- Expected Result:
-- No rows are updated; VPD policy prevents updating other customers' records.

-- Delete the customer's own record (use with caution)
DELETE FROM Consumers
WHERE CustomerID = SYS_CONTEXT('customer_ctx', 'customer_id');
-- Expected Result:
-- The delete operation succeeds if allowed by policy; be cautious as this may prevent further access.

-- Attempt to delete another customer's record
DELETE FROM Consumers
WHERE CustomerID <> SYS_CONTEXT('customer_ctx', 'customer_id');
-- Expected Result:
-- No rows are deleted; VPD policy prevents deleting other customers' records.

-- Attempt to select from a restricted table
SELECT * FROM PlatformAdmins;
-- Expected Result:
-- No records are returned or an error occurs; customers are not authorized to access 'PlatformAdmins' table.

-- Disconnect from the database
DISCONNECT;

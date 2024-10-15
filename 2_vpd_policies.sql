-- 1. Create the policy function for the Consumers table
CREATE OR REPLACE FUNCTION consumers_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Determine the predicate based on user identity
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'customer' THEN
        -- Customers can only access their own information
        pred := 'CustomerID = SYS_CONTEXT(''customer_ctx'', ''customer_id'')';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        -- Platform administrators can access all customer information
        pred := NULL; -- No row-level filtering applied
    ELSE
        -- Other users cannot access any data
        pred := '1=0'; -- Always false predicate
    END IF;
    RETURN pred;
END;
/
-- Creating policy functions for DELETE operations
CREATE OR REPLACE FUNCTION consumers_delete_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    RETURN '1=0'; 
END;
/
-- Apply the policy to the Consumers table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema         => 'SYSTEM',
        object_name           => 'Consumers',
        policy_name           => 'consumers_policy',
        function_schema       => 'SYSTEM',
        policy_function       => 'consumers_policy_fn',
        statement_types       => 'SELECT, UPDATE'
    );
END;
/
-- 将策略应用于 Consumers 表的 DELETE 操作
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema         => 'SYSTEM',
        object_name           => 'Consumers',
        policy_name           => 'consumers_delete_policy',
        function_schema       => 'SYSTEM',
        policy_function       => 'consumers_delete_policy_fn',
        statement_types       => 'DELETE'
    );
END;
/

-- 2. Create the policy function for the StoreStaff table
CREATE OR REPLACE FUNCTION storestaff_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Determine the predicate based on user identity
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        -- Platform admins can access staff of stores they manage
        pred := 'StoreID IN (
            SELECT StoreID FROM PlatformAdminStores
            WHERE AdminID = SYS_CONTEXT(''platformadmin_ctx'', ''admin_id'')
        )';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'storestaff' THEN
        -- Store staff can only access their own information
        pred := 'StaffID = SYS_CONTEXT(''storestaff_ctx'', ''staff_id'')';
    ELSE
        -- Other users cannot access any data
        pred := '1=0';
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the StoreStaff table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema         => 'SYSTEM',
        object_name           => 'StoreStaff',
        policy_name           => 'storestaff_policy',
        function_schema       => 'SYSTEM',
        policy_function       => 'storestaff_policy_fn',
        statement_types       => 'SELECT, UPDATE, DELETE',
        sec_relevant_cols     => 'Username, PasswordHash' -- Specify sensitive columns
    );
END;
/

-- 3. Create the policy function for the Products table
CREATE OR REPLACE FUNCTION products_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Only allow store staff to modify product information
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'storestaff' THEN
        -- Store staff can only modify products from their own store
        pred := 'StoreID = SYS_CONTEXT(''storestaff_ctx'', ''store_id'')'; -- Store staff can only modify their own store's products
    ELSE
        -- Other users cannot perform UPDATE and DELETE operations
        pred := '1=0';
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the Products table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'Products',
        policy_name     => 'products_policy',
        function_schema => 'SYSTEM',
        policy_function => 'products_policy_fn',
        statement_types => 'UPDATE, DELETE' -- Only apply to UPDATE and DELETE operations
    );
END;
/

-- 4. Create the policy function for the Orders table
CREATE OR REPLACE FUNCTION orders_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Determine access based on user identity
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'customer' THEN
        -- Customers can only access their own orders
        pred := 'CustomerID = SYS_CONTEXT(''customer_ctx'', ''customer_id'')';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'storestaff' THEN
        -- Store staff can access orders containing products from their store
        pred := 'OrderID IN (
            SELECT OrderID FROM OrderItems oi
            JOIN Products p ON oi.ProductID = p.ProductID
            WHERE p.StoreID = SYS_CONTEXT(''storestaff_ctx'', ''store_id'')
        )';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        -- Platform admins can access all orders
        pred := '1=1'; -- No filtering applied
    ELSE
        -- Other users cannot access any data
        pred := '1=0';
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the Orders table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'Orders',
        policy_name     => 'orders_policy',
        function_schema => 'SYSTEM',
        policy_function => 'orders_policy_fn',
        statement_types => 'SELECT, UPDATE, DELETE'
    );
END;
/

-- 5. Create the policy function for the CustomerMessages table
CREATE OR REPLACE FUNCTION customermessages_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Determine access based on user identity
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'customer' THEN
        -- Customers can access messages where they are the sender or receiver
        pred := '(SenderType = ''Consumer'' AND SenderID = SYS_CONTEXT(''customer_ctx'', ''customer_id''))
                 OR
                 (ReceiverType = ''Consumer'' AND ReceiverID = SYS_CONTEXT(''customer_ctx'', ''customer_id''))';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'storestaff' THEN
        -- Store staff can access messages related to their store
        pred := 'StoreID = SYS_CONTEXT(''storestaff_ctx'', ''store_id'')';
    ELSE
        -- Other users cannot access any data
        pred := '1=0';
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the CustomerMessages table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'CustomerMessages',
        policy_name     => 'customermessages_policy',
        function_schema => 'SYSTEM',
        policy_function => 'customermessages_policy_fn',
        statement_types => 'SELECT, UPDATE, DELETE'
    );
END;
/

-- 6. Policy Functions for the PlatformAdmins Table
-- a.Create the policy function for SELECT statements on the PlatformAdmins table
CREATE OR REPLACE FUNCTION platformadmins_select_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Platform admins can only view their own information
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        pred := 'AdminID = SYS_CONTEXT(''platformadmin_ctx'', ''admin_id'')';
    ELSE
        -- Other users cannot access any data
        pred := '1=0'; -- Always false predicate
    END IF;
    RETURN pred;
END;
/

-- b.Create the policy function for UPDATE statements on the PlatformAdmins table
CREATE OR REPLACE FUNCTION platformadmins_update_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Platform admins can only update their own information
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        pred := 'AdminID = SYS_CONTEXT(''platformadmin_ctx'', ''admin_id'')';
    ELSE
        -- Other users cannot update any data
        pred := '1=0'; -- Always false predicate
    END IF;
    RETURN pred;
END;
/

-- c.Create the policy function for DELETE statements on the PlatformAdmins table
CREATE OR REPLACE FUNCTION platformadmins_delete_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    -- Prevent deletion by always returning false
    RETURN '1=0'; -- Always false predicate
END;
/

-- Apply the SELECT policy to the PlatformAdmins table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema         => 'SYSTEM',
        object_name           => 'PlatformAdmins',
        policy_name           => 'platformadmins_select_policy',
        function_schema       => 'SYSTEM',
        policy_function       => 'platformadmins_select_policy_fn',
        statement_types       => 'SELECT',
        sec_relevant_cols     => 'Username, PasswordHash' -- Specify sensitive columns
    );
END;
/

-- Apply the UPDATE policy to the PlatformAdmins table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema         => 'SYSTEM',
        object_name           => 'PlatformAdmins',
        policy_name           => 'platformadmins_update_policy',
        function_schema       => 'SYSTEM',
        policy_function       => 'platformadmins_update_policy_fn',
        statement_types       => 'UPDATE',
        sec_relevant_cols     => 'AdminID, Username, PasswordHash, CreatedAt'
    );
END;
/

-- Apply the DELETE policy to the PlatformAdmins table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'PlatformAdmins',
        policy_name     => 'platformadmins_delete_policy',
        function_schema => 'SYSTEM',
        policy_function => 'platformadmins_delete_policy_fn',
        statement_types => 'DELETE'
    );
END;
/

-- 7. Create the policy function for the OrderItems table
CREATE OR REPLACE FUNCTION orderitems_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Determine access based on user identity
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'customer' THEN
        -- Customers can access items from their own orders
        pred := 'OrderID IN (
            SELECT OrderID FROM Orders
            WHERE CustomerID = SYS_CONTEXT(''customer_ctx'', ''customer_id'')
        )';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'storestaff' THEN
        -- Store staff can access items for products from their store
        pred := 'ProductID IN (
            SELECT ProductID FROM Products
            WHERE StoreID = SYS_CONTEXT(''storestaff_ctx'', ''store_id'')
        )';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        -- Platform admins can access items for stores they manage
        pred := 'ProductID IN (
            SELECT ProductID FROM Products
            WHERE StoreID IN (
                SELECT StoreID FROM PlatformAdminStores
                WHERE AdminID = SYS_CONTEXT(''platformadmin_ctx'', ''admin_id'')
            )
        )';
    ELSE
        -- Other users cannot access any data
        pred := '1=0';
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the OrderItems table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'OrderItems',
        policy_name     => 'orderitems_policy',
        function_schema => 'SYSTEM',
        policy_function => 'orderitems_policy_fn',
        statement_types => 'SELECT, UPDATE, DELETE'
    );
END;
/

-- 8. Create the policy function for the Stores table
CREATE OR REPLACE FUNCTION stores_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Determine access based on user identity
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'storestaff' THEN
        -- Store staff can access their own store
        pred := 'StoreID = SYS_CONTEXT(''storestaff_ctx'', ''store_id'')';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        -- Platform admins can access stores they manage
        pred := 'StoreID IN (
            SELECT StoreID FROM PlatformAdminStores
            WHERE AdminID = SYS_CONTEXT(''platformadmin_ctx'', ''admin_id'')
        )';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'customer' THEN
        -- If customers can view all store information
        pred := NULL; -- No row-level filtering
        -- If customers should not view store information, uncomment the following line
        -- pred := '1=0'; -- Always false predicate
    ELSE
        -- Other users cannot access any data
        pred := '1=0';
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the Stores table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'Stores',
        policy_name     => 'stores_policy',
        function_schema => 'SYSTEM',
        policy_function => 'stores_policy_fn',
        statement_types => 'SELECT, UPDATE, DELETE'
    );
END;
/

-- 9. Create the policy function for the PlatformAdminStores table
CREATE OR REPLACE FUNCTION platformadminstores_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Platform admins can only access their own associations
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        pred := 'AdminID = SYS_CONTEXT(''platformadmin_ctx'', ''admin_id'')';
    ELSE
        -- Other users cannot access any data
        pred := '1=0'; -- Always false predicate
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the PlatformAdminStores table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'PlatformAdminStores',
        policy_name     => 'platformadminstores_policy',
        function_schema => 'SYSTEM',
        policy_function => 'platformadminstores_policy_fn',
        statement_types => 'SELECT, UPDATE, DELETE'
    );
END;
/

-- 10. Create the policy function for the Payments table
CREATE OR REPLACE FUNCTION payments_policy_fn (
    schema_p IN VARCHAR2,
    table_p IN VARCHAR2
) RETURN VARCHAR2 IS
    pred VARCHAR2(4000);
BEGIN
    -- Determine access based on user identity
    IF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'customer' THEN
        -- Customers can access payments for their own orders
        pred := 'OrderID IN (
            SELECT OrderID FROM Orders
            WHERE CustomerID = SYS_CONTEXT(''customer_ctx'', ''customer_id'')
        )';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'storestaff' THEN
        -- Store staff can access payments for orders containing their store's products
        pred := 'OrderID IN (
            SELECT oi.OrderID
            FROM OrderItems oi
            JOIN Products p ON oi.ProductID = p.ProductID
            WHERE p.StoreID = SYS_CONTEXT(''storestaff_ctx'', ''store_id'')
        )';
    ELSIF SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') = 'platformadmin' THEN
        -- Platform admins can access payments for stores they manage
        pred := 'OrderID IN (
            SELECT oi.OrderID
            FROM OrderItems oi
            JOIN Products p ON oi.ProductID = p.ProductID
            WHERE p.StoreID IN (
                SELECT StoreID FROM PlatformAdminStores
                WHERE AdminID = SYS_CONTEXT(''platformadmin_ctx'', ''admin_id'')
            )
        )';
    ELSE
        -- Other users cannot access any data
        pred := '1=0'; -- Always false predicate
    END IF;
    RETURN pred;
END;
/
-- Apply the policy to the Payments table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema         => 'SYSTEM',
        object_name           => 'Payments',
        policy_name           => 'payments_policy',
        function_schema       => 'SYSTEM',
        policy_function       => 'payments_policy_fn',
        statement_types       => 'SELECT, UPDATE, DELETE',
        sec_relevant_cols     => 'PaymentMethod' -- Specify sensitive columns
    );
END;
/

-- Create a context namespace called CUSTOMER_CTX using the package CUSTOMER_CTX_PKG
CREATE OR REPLACE CONTEXT CUSTOMER_CTX USING CUSTOMER_CTX_PKG;

-- Create a package specification for CUSTOMER_CTX_PKG
CREATE OR REPLACE PACKAGE CUSTOMER_CTX_PKG IS
    -- Declare a procedure to set the customer context
    PROCEDURE SET_CUSTOMER_CONTEXT;
END;
/

-- Create the package body for CUSTOMER_CTX_PKG
CREATE OR REPLACE PACKAGE BODY CUSTOMER_CTX_PKG IS
    -- Define the procedure to set the customer context
    PROCEDURE SET_CUSTOMER_CONTEXT IS
        CUSTOMER_ID NUMBER;
    BEGIN
        -- Retrieve the CustomerID based on the current session user
        SELECT CustomerID INTO CUSTOMER_ID
        FROM Consumers
        WHERE Username = SYS_CONTEXT('USERENV', 'SESSION_USER');

        -- Set the customer_id in the customer_ctx context
        DBMS_SESSION.SET_CONTEXT('customer_ctx', 'customer_id', CUSTOMER_ID);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- If no matching record is found, do nothing
    END SET_CUSTOMER_CONTEXT;
END;
/

-- Create a trigger that fires after a user logs on to the database
CREATE OR REPLACE TRIGGER SET_CUSTOMER_CTX_TRIG
AFTER LOGON ON DATABASE
BEGIN
    -- Call the procedure to set the customer context
    CUSTOMER_CTX_PKG.SET_CUSTOMER_CONTEXT;
END;
/

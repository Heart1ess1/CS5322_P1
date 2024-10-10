-- Create an application context named STORESTAFF_CTX using the package STORESTAFF_CTX_PKG
CREATE OR REPLACE CONTEXT STORESTAFF_CTX USING STORESTAFF_CTX_PKG;

-- Create the package specification for STORESTAFF_CTX_PKG
CREATE OR REPLACE PACKAGE STORESTAFF_CTX_PKG IS
    -- Declare a procedure to set the store staff context
    PROCEDURE SET_STORESTAFF_CONTEXT;
END;
/

-- Create the package body for STORESTAFF_CTX_PKG
CREATE OR REPLACE PACKAGE BODY STORESTAFF_CTX_PKG IS
    -- Define the procedure to set the store staff context
    PROCEDURE SET_STORESTAFF_CONTEXT IS
        STAFF_ID NUMBER;
        STORE_ID NUMBER;
        ROLE VARCHAR2(20);
    BEGIN
        -- Retrieve StaffID, StoreID, and Role based on the current session user
        SELECT StaffID, StoreID, Role INTO STAFF_ID, STORE_ID, ROLE
        FROM StoreStaff
        WHERE Username = SYS_CONTEXT('USERENV', 'SESSION_USER');

        -- Set the retrieved values into the storestaff_ctx context
        DBMS_SESSION.SET_CONTEXT('storestaff_ctx', 'staff_id', STAFF_ID);
        DBMS_SESSION.SET_CONTEXT('storestaff_ctx', 'store_id', STORE_ID);
        DBMS_SESSION.SET_CONTEXT('storestaff_ctx', 'role', ROLE);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- If no matching record is found, do nothing
    END SET_STORESTAFF_CONTEXT;
END;
/

-- Create a trigger that fires after a user logs on to the database
CREATE OR REPLACE TRIGGER SET_STORESTAFF_CTX_TRIG
AFTER LOGON ON DATABASE
BEGIN
    -- Call the procedure to set the store staff context
    STORESTAFF_CTX_PKG.SET_STORESTAFF_CONTEXT;
END;
/

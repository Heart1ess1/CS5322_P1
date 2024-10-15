-- Create a context namespace called PLATFORMADMIN_CTX using the package PLATFORMADMIN_CTX_PKG
CREATE OR REPLACE CONTEXT PLATFORMADMIN_CTX USING PLATFORMADMIN_CTX_PKG;

-- Create the package specification for PLATFORMADMIN_CTX_PKG
CREATE OR REPLACE PACKAGE PLATFORMADMIN_CTX_PKG AUTHID CURRENT_USER IS
    -- Declare a procedure to set the platform administrator context
    PROCEDURE SET_PLATFORMADMIN_CONTEXT;
END;
/

-- Create the package body for PLATFORMADMIN_CTX_PKG
-- Create PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY PLATFORMADMIN_CTX_PKG IS
    -- Define a procedure to set the platform admin context
    PROCEDURE SET_PLATFORMADMIN_CONTEXT IS
        ADMIN_ID NUMBER;
    BEGIN
        -- Retrieve AdminID based on the current session user
        SELECT AdminID INTO ADMIN_ID
        FROM PlatformAdmins
        WHERE UPPER(Username) = UPPER(SYS_CONTEXT('USERENV', 'SESSION_USER'));

        -- Set admin_id in the platformadmin_ctx context
        DBMS_SESSION.SET_CONTEXT('platformadmin_ctx', 'admin_id', ADMIN_ID);
        DBMS_SESSION.SET_IDENTIFIER('platformadmin');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- If no matching record is found, do nothing
    END SET_PLATFORMADMIN_CONTEXT;
END;
/


-- Create a trigger that fires after a user logs on to the database
CREATE OR REPLACE TRIGGER SET_PLATFORMADMIN_CTX_TRIG
AFTER LOGON ON DATABASE
BEGIN
    -- Call the procedure to set the platform administrator context
    PLATFORMADMIN_CTX_PKG.SET_PLATFORMADMIN_CONTEXT;
END;
/

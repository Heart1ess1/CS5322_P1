-- ***************************************
-- ** Create Roles for Different Users  **
-- ***************************************

-- Create a role for Consumers
CREATE ROLE consumer_role;

-- Create a role for Store Staff
CREATE ROLE storestaff_role;

-- Create a role for Platform Administrators
CREATE ROLE platformadmin_role;

-- ***************************************
-- ** Grant Privileges to the Roles     **
-- ***************************************

-- Grant privileges to consumer_role
GRANT CONNECT TO consumer_role;

-- Consumers need to select and update their own data
GRANT SELECT, UPDATE ON Consumers TO consumer_role;
GRANT SELECT ON Products TO consumer_role;
GRANT SELECT ON Stores TO consumer_role;
GRANT SELECT ON Orders TO consumer_role;
GRANT SELECT ON OrderItems TO consumer_role;
GRANT SELECT ON Payments TO consumer_role;
GRANT SELECT ON CustomerMessages TO consumer_role;

-- Grant privileges to storestaff_role
GRANT CONNECT TO storestaff_role;

-- Store Staff need more extensive privileges on their store's data
GRANT SELECT, UPDATE ON StoreStaff TO storestaff_role;
GRANT SELECT, UPDATE ON Stores TO storestaff_role;
GRANT SELECT, UPDATE ON Products TO storestaff_role;
GRANT SELECT, UPDATE ON Orders TO storestaff_role;
GRANT SELECT, UPDATE ON OrderItems TO storestaff_role;
GRANT SELECT, UPDATE ON Payments TO storestaff_role;
GRANT SELECT, UPDATE ON CustomerMessages TO storestaff_role;
GRANT SELECT ON Consumers TO storestaff_role;

-- Grant privileges to platformadmin_role
GRANT CONNECT TO platformadmin_role;

-- Platform Admins need the highest level of access
GRANT SELECT, UPDATE, DELETE ON PlatformAdmins TO platformadmin_role;
GRANT SELECT, UPDATE, DELETE ON Stores TO platformadmin_role;
GRANT SELECT, UPDATE, DELETE ON StoreStaff TO platformadmin_role;
GRANT SELECT, UPDATE, DELETE ON Products TO platformadmin_role;
GRANT SELECT, UPDATE, DELETE ON Orders TO platformadmin_role;
GRANT SELECT, UPDATE, DELETE ON OrderItems TO platformadmin_role;
GRANT SELECT, UPDATE, DELETE ON Payments TO platformadmin_role;
GRANT SELECT, UPDATE, DELETE ON CustomerMessages TO platformadmin_role;
GRANT SELECT ON PlatformAdminStores TO platformadmin_role;
GRANT SELECT ON Consumers TO platformadmin_role;

-- Grant execute privileges on context packages
GRANT EXECUTE ON CUSTOMER_CTX_PKG TO consumer_role;
GRANT EXECUTE ON STORESTAFF_CTX_PKG TO storestaff_role;
GRANT EXECUTE ON PLATFORMADMIN_CTX_PKG TO platformadmin_role;

-- ***************************************
-- ** Create User Accounts             **
-- ***************************************

-- ***************
-- * Consumers *
-- ***************

-- Create user account for John Doe (Consumer)
CREATE USER johndoe IDENTIFIED BY Password;
GRANT consumer_role TO johndoe;

-- Create user account for Jane Smith (Consumer)
CREATE USER janedoe IDENTIFIED BY Password;
GRANT consumer_role TO janedoe;

-- ***************
-- * Store Staff *
-- ***************

-- Create user account for Charlie Brown (Store Staff)
CREATE USER techstaff1 IDENTIFIED BY Password;
GRANT storestaff_role TO techstaff1;

-- Create user account for Dana White (Store Staff)
CREATE USER bookstaff1 IDENTIFIED BY Password;
GRANT storestaff_role TO bookstaff1;

-- ******************************
-- * Platform Administrators *
-- ******************************

-- Create user account for Alice Johnson (Platform Admin)
CREATE USER admin1 IDENTIFIED BY Password;
GRANT platformadmin_role TO admin1;

-- Create user account for Bob Williams (Platform Admin)
CREATE USER admin2 IDENTIFIED BY Password;
GRANT platformadmin_role TO admin2;

-- ***************************************
-- ** Additional Privileges and Grants  **
-- ***************************************

-- Grant execute on triggers if required
-- Ensure users can use the AFTER LOGON trigger
ALTER USER johndoe QUOTA UNLIMITED ON USERS;
ALTER USER janedoe QUOTA UNLIMITED ON USERS;
ALTER USER techstaff1 QUOTA UNLIMITED ON USERS;
ALTER USER bookstaff1 QUOTA UNLIMITED ON USERS;
ALTER USER admin1 QUOTA UNLIMITED ON USERS;
ALTER USER admin2 QUOTA UNLIMITED ON USERS;

-- ***************************************
-- ** Assign Default Tablespaces        **
-- ***************************************

-- Assign default tablespaces (adjust as needed)
ALTER USER johndoe DEFAULT TABLESPACE users;
ALTER USER janedoe DEFAULT TABLESPACE users;
ALTER USER techstaff1 DEFAULT TABLESPACE users;
ALTER USER bookstaff1 DEFAULT TABLESPACE users;
ALTER USER admin1 DEFAULT TABLESPACE users;
ALTER USER admin2 DEFAULT TABLESPACE users;

-- ***************************************
-- ** Unlock User Accounts              **
-- ***************************************

-- Unlock user accounts if necessary
ALTER USER johndoe ACCOUNT UNLOCK;
ALTER USER janedoe ACCOUNT UNLOCK;
ALTER USER techstaff1 ACCOUNT UNLOCK;
ALTER USER bookstaff1 ACCOUNT UNLOCK;
ALTER USER admin1 ACCOUNT UNLOCK;
ALTER USER admin2 ACCOUNT UNLOCK;

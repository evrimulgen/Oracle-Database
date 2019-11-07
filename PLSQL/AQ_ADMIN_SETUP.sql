--create aq_admin administrator account
set verify off
--change to pluggable database
ALTER SESSION SET CONTAINER = ORCLPDB;
ACCEPT password PROMPT 'Enter password for aq_admin:' HIDE
CREATE USER aq_admin IDENTIFIED BY &password
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;
ALTER USER aq_admin QUOTA UNLIMITED ON users;
--grant roles to aq_admin
GRANT AQ_ADMINISTRATOR_ROLE TO aq_admin;
GRANT connect TO aq_admin;
GRANT create type TO aq_admin;

---AQ_USER user creation


--create aq_user user account
--drop user aq_user
set verify off

ACCEPT password PROMPT 'Enter password for aq_user:' HIDE
CREATE USER aq_user IDENTIFIED BY password
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;
--grant roles to aq_user
GRANT aq_user_role TO aq_user;
GRANT connect TO aq_user;
grant create session to aq_user;
GRANT EXECUTE ON aq_admin.orders_message_type TO aq_user;
/
begin
DBMS_AQADM.GRANT_QUEUE_PRIVILEGE(
privilege => 'ALL',
queue_name => 'aq_admin.orders_msg_queue',
grantee => 'aq_user',
grant_option => FALSE);
end;
/
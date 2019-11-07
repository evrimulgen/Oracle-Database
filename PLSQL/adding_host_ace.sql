select  * from dba_users where username like 'APEX%';

DECLARE
  --l_principal VARCHAR2(20) := 'APEX_040200';
  --l_principal VARCHAR2(20) := 'APEX_050000';
  --l_principal VARCHAR2(20) := 'APEX_050100';
  l_principal VARCHAR2(20) := 'APEX_180200';
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => 'reqres.in', 
    lower_port => 443,
    upper_port => 443,
    ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                              principal_name => l_principal,
                              principal_type => xs_acl.ptype_db)); 
END;
/


--check apex_release
select * from apex_release;
select * from dba_registry where comp_id ='XDB';

select * from dba_users where username like 'APEX_%';

SELECT   username
,        account_status
FROM     dba_users
WHERE    username IN ('APEX_PUBLIC_USER','ANONYMOUS');
/

SELECT default_tablespace
,      temporary_tablespace
FROM   dba_users
WHERE  username = 'FLOWS_FILES';

SELECT STATUS FROM DBA_REGISTRY
WHERE COMP_ID = 'APEX';

ALTER USER apex_public_user ACCOUNT UNLOCK;
ALTER USER anonymous identified by password ACCOUNT UNLOCK ;

SELECT host,
       lower_port,
       upper_port,
       ace_order,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date,
       grant_type,
       inverted_principal,
       principal,
       principal_type,
       privilege
FROM   dba_host_aces
ORDER BY host, ace_order;

---remove HOST ace

BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'reqres.in', 
    lower_port       => 443,
    upper_port       => 443,
    ace              => xs$ace_type(privilege_list => xs$name_list('http'),
                                    principal_name => 'APEX_180200',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/

---allow complete network access
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => '*', 
    lower_port => 1,
    upper_port => 9999,
    ace        => xs$ace_type(privilege_list => xs$name_list('connect'),
                              principal_name => 'APEX_180200',
                              principal_type => xs_acl.ptype_db)); 
END;
--if you get pluggable database not open error












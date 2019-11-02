---CAST/MULTISET Demos
CREATE TYPE emp_o AS OBJECT (
    employee_id     NUMBER,
    employee_name   VARCHAR2(50)
);
DROP TYPE emp_o;
CREATE TYPE emp_t IS
    TABLE OF emp_o;
DROP TYPE emp_t;
DECLARE
    l_employees_array emp_t := NULL;
BEGIN
    SELECT
        CAST(MULTISET(
            SELECT
                e.employee_id, e.first_name
                               || ' '
                               || e.last_name
            FROM
                hr.employees e
            WHERE
                d.department_id = e.department_id
        ) AS emp_t)
    INTO l_employees_array
    FROM
        hr.departments d
    WHERE
        d.department_id = 50;

    dbms_output.put_line('Number of Employees:' || l_employees_array.count);
END;
/
--Employee Object 
CREATE TYPE emp_o AS OBJECT (
    employee_id     NUMBER,
    employee_name   VARCHAR2(100),
    salary          NUMBER
);

--Employee table

CREATE TYPE emp_ot IS
    TABLE OF emp_o;
--Department object

CREATE TYPE deps_o AS OBJECT (
    department_id     NUMBER,
    department_name   VARCHAR2(100),
    emp_tab           emp_ot
);
--department table

CREATE TYPE deps_t IS
    TABLE OF deps_o;

----
DECLARE 
  l_message DEPS_T := DEPS_T(); --Initialize 
BEGIN 
  SELECT CAST ( MULTISET (
                SELECT d.department_id, 
                       d.department_name, 
                       (CAST(MULTISET(
                              SELECT e.employee_id, 
                                     e.first_name ||' ' ||e.last_name,
                                     e.salary 
                              FROM   hr.employees e 
                              WHERE  e.department_id = d.department_id ) AS EMP_OT) )
                FROM hr.departments d) AS deps_t)
  INTO   l_message 
  FROM DUAL;
 

END;
/
---------------------- OR ------------------------------

DECLARE 
  l_message DEPS_T;
  l_employee_t emp_ot;
  l_xml_clob CLOB;
BEGIN 
  SELECT deps_o(
           d.department_id,
           d.department_name,
           emp_ot(emp_o(
                        e.employee_id,
                        e.first_name || ' ' || e.last_name,
                        e.salary
                       )
                  )
           )
  BULK COLLECT INTO l_message 
  FROM   departments d , employees e
  where  e.department_id = d.department_id and d.department_id=10 ; 
  --Print the content 
--  for i in 1..l_message.COUNT 
--  loop
--        DBMS_OUTPUT.PUT_LINE(l_message(i).department_id);
--        DBMS_OUTPUT.PUT_LINE(l_message(i).department_name);
--        l_employee_t := l_message(i).emp_tab;
--        for j in 1..l_employee_t.COUNT
--        loop
--            DBMS_OUTPUT.PUT_LINE('Employee Name:'||l_employee_t(j).employee_name);
--        end loop;
--  end loop;
  
  --Generate XML
--  <Departments>
--    <department id = "department_id" name = "department_name" >
--          <employees>
    --          <employee id = "employee_id">
        --          <employee_name> </employee_name>
        --          <salary> </salary>
    --          </employee>
--          </employees>
--    </department>
--  </Departments>
--execute immediate 'create table result_tmp (department_id NUMBER,department_name VARCHAR2(100), employee_id NUMBER,employee_name varchar2(100),salary NUMBER)';
  
--  insert into result_tmp
--
--  select t.department_id,
--         t.department_name,
--         g.employee_id,
--         g.employee_name,
--         g.salary
--    
--  from  TABLE(CAST(l_message as deps_t)) t,
--        TABLE(CAST(t.emp_tab as emp_ot)) g;
        
SELECT XMLELEMENT("Departments", 
       ( 
                SELECT   XMLAGG(XMLELEMENT("department", 
                                          xmlattributes(t.department_id AS "id", t.department_name AS "name"),
                         ( 
                                SELECT XMLELEMENT("employees",
                                                  (SELECT XMLAGG(XMLELEMENT("employee", 
                                                                 xmlattributes(g.employee_id AS "id"), 
                                                                 xmlforest(g.employee_name as "employee_name") ) ) 
                                                    FROM TABLE(cast(t.emp_tab AS emp_ot)) g 
                                                   ) )
                                FROM   DUAL ) ---end of inner select
                         ) ) 
                FROM     TABLE(cast(l_message AS deps_t)) t, 
                GROUP BY t.department_id) ).getclobval() 
INTO   l_xml_clob 
FROM   dual;
        
        
--  group by t.department_id;
--for rec1 in ( 
--select t.department_id||','
--       ||t.department_name||','
--       ||g.employee_id||','
--       ||g.employee_name||','
--       ||g.salary as r
--from  TABLE(CAST(l_message as deps_t)) t
--      ,TABLE(CAST(t.emp_tab as emp_ot)) g ) 
--      loop
----      DBMS_OUTPUT.PUT_LINE(rec1.department_id);
----      DBMS_OUTPUT.PUT_LINE(rec1.department_name);
----      DBMS_OUTPUT.PUT_LINE(rec1.employee_id);
----      DBMS_OUTPUT.PUT_LINE(rec1.employee_name);
----      DBMS_OUTPUT.PUT_LINE(rec1.salary);
--      DBMS_OUTPUT.PUT_LINE(rec1.r);
--      end loop;  
DBMS_OUTPUT.PUT_LINE(l_xml_clob);
  
END;
/

select * from employees where department_id =20;

select  * from employees;


select XMlElement("Departments",XMLAttributes('http://www.w3.org/TR/html4/' as "xmlns:h",'https://www.w3schools.com/furniture' as "xmlns:f"),XMLAgg(XMLElement("department",
        XMLAttributes(e.department_id as "id"),
        XMLElement("employees",
                    XMLAgg(XMlElement("employee",
                             XMlForest(e.first_name as "name",e.salary as "salary")
                     XML))
        
        )
       ))).getClobval()
from employees e
group by e.department_id;

select * from result_tmp;

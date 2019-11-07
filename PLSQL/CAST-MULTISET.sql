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
  where  e.department_id = d.department_id ; 
        
SELECT XMLELEMENT("Departments", 
       ( 
                SELECT   XMLAGG(XMLELEMENT("department", 
                                            xmlattributes(t.department_id AS "id", t.department_name AS "name"),
                                            XMLELEMENT("employees",
                                                        XMLAGG(XMLELEMENT("employee", 
                                                                 xmlattributes(g.employee_id AS "id"), 
                                                                 xmlforest(g.employee_name as "employee_name") ) ) 
                                                    
                                                       )
                                            ))
                FROM     TABLE(cast(l_message AS deps_t)) t, 
                         TABLE(cast(t.emp_tab AS emp_ot)) g 
                GROUP BY t.department_id,t.department_name) ).getclobval() 
INTO   l_xml_clob 
FROM   dual;
        
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

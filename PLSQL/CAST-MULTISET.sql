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
---------------------- OR ------------------------------

DECLARE 
  l_message DEPS_T;
  l_employee_t emp_ot;
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
  where  e.department_id = d.department_id; 
  
  for i in 1..l_message.COUNT 
  loop
        DBMS_OUTPUT.PUT_LINE(l_message(i).department_id);
        DBMS_OUTPUT.PUT_LINE(l_message(i).department_name);
        l_employee_t := l_message(i).emp_tab;
        for j in 1..l_employee_t.COUNT
        loop
            DBMS_OUTPUT.PUT_LINE('Employee Name:'||l_employee_t(j).employee_name);
        end loop;
  end loop;
  
END;
/




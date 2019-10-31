---CAST/MULTISET Demos
CREATE TYPE emp_o AS OBJECT (
    employee_id     NUMBER,
    employee_name   VARCHAR2(50)
);

CREATE TYPE emp_t IS
    TABLE OF emp_o;

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


create type emp_rec as object
( 
 employee_id NUMBER,
 salary NUMBER
 );

create type emp_t is table of emp_rec;

declare
l_emp_tab emp_t;
cursor c_data is
select emp_rec(e.employee_id,
                   e.salary
               )
    from hr.employees e;

begin
    open c_data;
    fetch c_data bulk collect into l_emp_tab;
    close c_data;
    
    for indx in 1..l_emp_tab.count
    loop
        dbms_output.put_line(l_emp_tab(indx).employee_id);
        dbms_output.put_line(l_emp_tab(indx).salary);
    end loop;
    

end;
/
---Enable Oracle ReST data services
select * from dba_objects where object_name like '%ORDS%';
select * from dba_users where username in ('ORDS_PUBLIC_USER','APEX_PUBLIC_USER','APEX_REST_PUBLIC_USER','APEX_LISTENER');
--Download ORDS
--- Rest  Enable a Schema
begin
ORDS.enable_schema
(
p_enabled   => TRUE,
p_schema    => 'HR',
p_url_mapping_type  => 'BASE_PATH',
p_url_mapping_pattern   => 'hr',
p_auto_rest_auth    => FALSE
);
COMMIT;
end;
/
--The DEFINE_SERVICE procedure allows you to create a new module, template and handler in a single step
--If the module already exists, it's replaced by the new definition.
begin
ORDS.define_service(
p_module_name => 'rest-v1',
p_base_path => 'rest-v1/',
p_pattern   => 'employees/:empno',
p_method    => 'GET',
p_source_type   => ORDS.source_type_collection_feed,
p_source    => 'select * from employees where employee_id = :empno',
p_items_per_page    => 0
);
COMMIT;

end;
/
--common views for ords
SELECT id, name, uri_prefix
FROM   user_ords_modules
ORDER BY name;
/

SELECT id, module_id, uri_template
FROM   user_ords_templates
ORDER BY module_id;

SELECT id, template_id, source_type, method, source
FROM   user_ords_handlers
ORDER BY id;

---Manually creating the above process ** This is recommended for Understanding

BEGIN
ORDS.define_module(
p_module_name => 'rest-v2',
p_base_path => 'rest-v2/',
p_items_per_page => 0
);
ORDS.define_template(
p_module_name => 'rest-v2',
p_pattern => 'employees/'
);

ORDS.define_handler(
p_module_name => 'rest-v2',
p_pattern => 'employees/',
p_method => 'GET',
p_source_type => ORDS.source_type_collection_feed,
p_source => 'select * from employees',
p_items_per_page => 0
);

ORDS.define_template(
p_module_name => 'rest-v2',
p_pattern => 'employees/:empno' --Handlers is associated with patterns in template ***
);

ORDS.define_handler(
p_module_name => 'rest-v2',
p_pattern => 'employees/:empno',
p_method => 'GET',
p_source_type => ORDS.source_type_collection_feed,
p_source => 'select * from employees where employee_id = :empno',
p_items_per_page => 0
);
commit ; -- it's absolutely necessary 

END;
/

--Multi value parameters
select instr('1',',') from dual;

create type emp_t is table of varchar2(40);

/
create or replace function in_list(p_in_list varchar2)
return emp_t pipelined
as
l_in_list VARCHAR2(250) := p_in_list||',';
l_id NUMBER := 1;
begin
loop

    l_id := INSTR(l_in_list,',');
    exit when l_id =0;
    dbms_output.put_line(l_id);
    pipe row (TRIM(substr(l_in_list,1,l_id-1)));
    l_in_list:=NVL(SUBSTR(l_in_list,l_id+1),' ');
    dbms_output.put_line(l_in_list);
    
end loop;

end;
/
select * from in_list('1,2,4,65,7');
/

begin
ORDS.define_module(
p_module_name => 'rest-v3',
p_base_path => 'rest-v3/'
);

ORDS.define_template(
p_module_name => 'rest-v3',
p_pattern => 'employees/:empno'
);

ORDS.define_handler(
p_module_name => 'rest-v3',
p_pattern => 'employees/:empno',
p_source_type => ORDS.source_type_collection_feed,
p_source => 'select * from employees where employee_id in (select * from in_list(:empno))'
);
COMMIT;

end;
/
--call PLSQL procedure

CREATE OR REPLACE PROCEDURE get_emp_json(p_empno IN employees.employee_id%type default NULL)
as
l_cursor SYS_REFCURSOR;
BEGIN
open l_cursor for
select  e.employee_id as "empno",
        e.first_name|| ''||e.last_name as "ename",
        e.salary as "sal"
from employees e 
where employee_id = NVL(p_empno,employee_id);
APEX_JSON.open_object;
APEX_JSON.write('employees',l_cursor);
APEX_JSON.close_object;

END;
/

begin
ORDS.define_module(
p_module_name => 'rest-v4',
p_base_path => 'rest-v4/'
);

ORDS.define_template(
p_module_name => 'rest-v4',
p_pattern => 'employees/:empno'
);

ORDS.define_handler(
p_module_name => 'rest-v4',
p_pattern => 'employees/:empno',
p_source_type => ORDS.source_type_plsql,
p_source => 'begin get_emp_json(:empno); end;'
);


ORDS.define_template(
p_module_name => 'rest-v4',
p_pattern => 'employees/'
);

ORDS.define_handler(
p_module_name => 'rest-v4',
p_pattern => 'employees/',
p_source_type => ORDS.source_type_plsql,
p_source => 'begin get_emp_json(); end;'
);


COMMIT;


end;
/

--POST Method

-- http://localhost:9090/ords/hr
-- To start ReST Web services from SQL Developer, Go to Tools - ReST Data Services - Run ( choose the ords.war file from your dir)
--- PLSQL Package as Source

CREATE OR REPLACE procedure get_emp_details(p_empno NUMBER DEFAULT NULL) as
l_output SYS_REFCURSOR;
BEGIN
    OPEN l_output FOR
    SELECT  e.employee_id as "empno",
            e.first_name||' '||e.last_name as "ename",
            e.salary as "salary",
            to_char(e.hire_date,'YYYYMMDD') as "hire_date"
    FROM employees e
    WHERE e.employee_id = NVL(p_empno,e.employee_id);

    APEX_JSON.open_object;
    APEX_JSON.write('employees',l_output);
    APEX_JSON.close_object;

END;



--set up 
BEGIN

 ---Right now all the URI are like this http://localhost:9090/ords/hr
--- if we want to chnage the 'hr' it needs to be done 
--- Current URI : http://localhost:9090/ords/hr
--- To Be URI : http://localhost:9090/ords/webservices


 ORDS.enable_schema
    (
    p_enabled   => TRUE,
    p_schema    => 'HR',
    p_url_mapping_type  => 'BASE_PATH',
    p_url_mapping_pattern   => 'webservices',
    p_auto_rest_auth    => FALSE
    );

  ORDS.define_module(p_module_name => 'rest-v5',
                     p_base_path   => 'saasservices/',
                     p_comments    => 'This module is created to test base_path usability.'
  );
--
  ORDS.define_template(
      p_module_name => 'rest-v5',
      p_pattern     => 'employees/:empno'
  );
--
  ORDS.define_handler(
      p_module_name => 'rest-v5',
      p_pattern     => 'employees/:empno',
      p_method      =>  'GET',
      p_source_type =>  ORDS.source_type_plsql,
      p_source      => 'BEGIN get_emp_details(:empno); END;'
  );
--add another template
  ORDS.define_template(
      p_module_name => 'rest-v5',
      p_pattern     => 'employees/'
  );
ORDS.define_handler(
      p_module_name => 'rest-v5',
      p_pattern     => 'employees/',
      p_method      =>  'GET',
      p_source_type =>  ORDS.source_type_plsql,
      p_source      => 'BEGIN get_emp_details(p_empno=> NULL); END;'
  );    

-- http://localhost:9090/ords/webservices/saasservices

END;
/



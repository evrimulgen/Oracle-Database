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
---**** Create ResT data services that gives output in XML

CREATE OR REPLACE PROCEDURE get_emp_details_xml(p_empno NUMBER DEFAULT NULL)
AS
l_clob CLOB;
BEGIN 
      SELECT XMLSerialize(CONTENT XMLELEMENT("employees",
                               XMLAGG(XMLELEMENT("employee",
                                          XMLATTRIBUTES(e.employee_id as "employee_id"),
                                          XMLFOREST(e.first_name||' '||e.last_name as "name", e.salary as "salary",e.hire_date as "hire_date")
                               )
                           )
                        )
                  )
      INTO l_clob 
      FROM employees e
      WHERE e.employee_id = NVL(p_empno,e.employee_id);

      ---- IMPORTANT
      OWA_UTIL.mime_header('text/xml');
      HTP.print(l_clob);


END;
/


BEGIN
 --First create the template

   ORDS.define_template(
         p_module_name => 'rest-v5',
         p_pattern     => 'employees/xml/:empno'
   );

   ORDS.define_handler(
         p_module_name => 'rest-v5',
         p_pattern     => 'employees/xml/:empno',
         p_method      =>  'GET',
         p_source_type =>  ORDS.source_type_plsql,
         p_source      => 'BEGIN get_emp_details_xml(:empno); END;'
   );
   
   --http://localhost:9090/ords/webservices/saasservices/employees/xml/:empno


END;
/

---- ** POST Requests Handling.
--create a template first

BEGIN
   ORDS.define_module(
      p_module_name   => 'rest-v6',
      p_base_path     => 'hr',
      p_comments      => 'This is module will handle POST requests.'
   );

   ORDS.define_template(
      p_module_name => 'rest-v6',
      p_pattern     => 'createEmployee'
   );

   ORDS.define_handler(
      p_module_name => 'rest-v6',
      p_pattern     => 'createEmployee',
      p_method      => 'POST',
      p_source_type => ORDS.source_type_plsql,
      p_source      => 'BEGIN HandlePostRequests.create_employee(p_body => :body); END;'
   );
---http://localhost:9090/ords/webservices/hr/createEmployee

END;
/
--replace option not applicable for GTT
CREATE GLOBAL TEMPORARY TABLE employee_gtt
(
   employee_id    NUMBER,
   first_name     VARCHAR2(100),
   last_name      VARCHAR2(100),
   email          VARCHAR2(100),
   phone_number   VARCHAR2(100),
   -- hire_date      DATE,
   job_id         VARCHAR2(100)
)
ON COMMIT DELETE ROWS;

--Create the Procedure

CREATE OR REPLACE PACKAGE HandlePostRequests
AS
   -- PROCEDURE load_payload(p_body BLOB)
   PROCEDURE create_employee(p_body BLOB);
   -- FUNCTION convert_blob_to_clob((p_body BLOB);
END HandlePostRequests;
/


CREATE OR REPLACE PACKAGE BODY HandlePostRequests
AS
   FUNCTION convert_blob_to_clob(p_body BLOB) RETURN CLOB ;
   PROCEDURE load_payload(p_body BLOB);
   PROCEDURE create_employee(p_body IN BLOB)
   IS
   l_clob   CLOB;
   TYPE t_out IS TABLE OF NUMBER;
   BEGIN
      load_payload(p_body);
      INSERT INTO employees(employee_id,
                           first_name,
                           last_name,
                           email,
                           phone_number,
                           hire_date,
                           job_id)
      SELECT               employee_id,
                           first_name,
                           last_name,
                           email,
                           phone_number,
                           SYSDATE,
                           job_id
         FROM employee_gtt;
      -- RETURNING employee_id BULK COLLECT INTO t_out;
   COMMIT;
   EXCEPTION
   -- WHEN custom_exception
   -- THEN
   --    RAISE_APPLICATION_ERROR(-20001,'Invalid JSON passed as payload.');   
   WHEN OTHERS 
   THEN
      RAISE_APPLICATION_ERROR(-20001,SQLERRM||':'||'create_employee');
   END create_employee;


FUNCTION convert_blob_to_clob(p_body BLOB)
RETURN CLOB 
IS
   l_clob CLOB;
   l_dest_offset   NUMBER  := 1;
   l_src_offset    NUMBER  := 1;
   l_lang_context  NUMBER  := DBMS_LOB.default_lang_ctx;
   l_warning       NUMBER;
BEGIN
   if p_body is NULL 
   then
      return NULL;
   end if;

   DBMS_LOB.createTemporary(lob_loc  =>  l_clob
                                       ,cache    =>  false);
   DBMS_LOB.converttoclob(dest_lob     => l_clob
                                     ,src_blob     => p_body
                                     ,amount       => DBMS_LOB.lobmaxsize
                                     ,dest_offset  => l_dest_offset
                                     ,src_offset   => l_src_offset
                                     ,blob_csid    => DBMS_LOB.default_csid
                                     ,lang_context => l_lang_context
                                     ,warning      => l_warning);

   return l_clob;

END convert_blob_to_clob;
      
PROCEDURE load_payload(p_body BLOB)
IS
   l_payload CLOB;
   custom_exception exception;
BEGIN
   l_payload := convert_blob_to_clob(p_body);

   if l_payload is not JSON 
   then
      raise custom_exception;
   end if;

   INSERT INTO employee_gtt
   SELECT   t.employee_id,
            t.first_name,
            t.last_name,
            t.email,
            t.phone_number,
            -- t.hire_date,
            t.job_id
      FROM  JSON_TABLE(l_payload,'$.employees[*]'
            COLUMNS
            (
               employee_id VARCHAR2(100) PATH '$.employee_id',
               first_name VARCHAR2(100) PATH '$.first_name',
               last_name VARCHAR2(100) PATH '$.last_name',
               email VARCHAR2(100) PATH '$.email',
               phone_number VARCHAR2(100) PATH '$.phone_number',
               -- hire_date VARCHAR2(100) PATH '$.hire_date',
               job_id VARCHAR2(100) PATH '$.job_id'
            )
      ) t;

EXCEPTION
   WHEN custom_exception
   THEN
      RAISE_APPLICATION_ERROR(-20001,'Invalid JSON passed as payload.');   
   WHEN OTHERS 
   THEN
      RAISE_APPLICATION_ERROR(-20001,SQLERRM||':'||'load_payload');
END load_payload;

END HandlePostRequests;
/

--TEST
DECLARE
--from text to raw then blob
l_blob BLOB:=TO_BLOB(utl_raw.cast_to_raw('{
  "employees": [
    {
      "employee_id": 400,
      "first_name": "Asfakul",
      "last_name": "Laskar",
      "email": "asfkol@gmail.com",
      "phone_number": "7003305607",
      "job_id": "IT_PROG"
    }
  ]
}'));


BEGIN
HandlePostRequests.create_employee(l_blob);


END;
/


select XMLElement("emp",e.first_name||' '||e.last_name).getClobVal()
from employees e;

select XMLForest(e.employee_id as "employeeId",e.first_name as "firstName", e.last_name as "lastName").getClobVal() as "RESULT"
from employees e;
--emp element with attributes
select XMLElement("emp", 
                   XMLAttributes(e.employee_id as "employeeId", e.first_name||'-'||e.last_name as "name")
                  ).getClobVal() as "RESULT"
from employees e;
/
select XMLagg(XMLForest(e.employee_id as "employeeId",e.first_name as "firstName", e.last_name as "lastName")).getClobVal() as "RESULT"
from employees e;
--Generate XML from Object

<Emp name="John Smith">
  <HIRE>24-MAY-00</HIRE>
  <department>Accounting</department>
</Emp>
<Emp name="Mary Martin">
  <HIRE>FEB-01-96</HIRE>
  <department>Shipping</department>
</Emp>
<Emp name="Jennifer Whalen"><HIRE_DATE>2003-09-17</HIRE_DATE><department>Administration</department></Emp>

select XMLElement("Emp", 
                   XMLAttributes(e.first_name||' '||e.last_name as "name"),
                   XMLForest(e.hire_date,d.department_name as "department")).getClobval() as "RESULT"
from employees e, departments d
where e.department_id = d.department_id;
/

DECLARE
l_xml XMLType := XMLType.createXML('<EMPLOYEES>
 <EMP>
    <EMPNO>112</EMPNO> 
    <EMPNAME>Joe</EMPNAME>
    <SALARY>50000</SALARY>
  </EMP>
 <EMP>
    <EMPNO>217</EMPNO>
    <EMPNAME>Jane</EMPNAME> 
    <SALARY>60000</SALARY>
 </EMP>
 <EMP> 
    <EMPNO>412</EMPNO> 
    <EMPNAME>Jack</EMPNAME>
    <SALARY>40000</SALARY>
 </EMP>
</EMPLOYEES>');
l_clob CLOB;
begin
--select XMlQuery('for $doc in $p/EMPLOYEES
--                    for $i in $doc/EMP
--                      where $i/SALARY > 50000
--                      order by $i/SALARY
--                      return <EMPLOYEES> {$i} </EMPLOYEES>'
--                 passing l_xml as "p"
--                 RETURNING CONTENT).getClobval() into l_clob
--    from dual ;
----Modify the XML
----insert one node for each EMP element
--select XMLQuery('copy $tmp := $p modify 
--                 (for $i in $tmp/EMPLOYEES/EMP return insert node <JOB> Clerk </JOB> as last into $i)
--                 return $tmp'
--                 passing l_xml as "p"
--                 returning CONTENT).getClobval() into l_clob
--             from dual ;  
--delete a node where salary > 50000
select XMLQuery('copy $tmp := $p modify 
                 (for $i in $tmp/EMPLOYEES/EMP
                    where $i/SALARY> 50000 return delete node $i/SALARY)
                 return $tmp'
                 passing l_xml as "p"
                 returning CONTENT).getClobval() into l_clob
             from dual ;  

             
             
DBMS_output.put_line(l_clob);
end;
/
--- insert a node into another node XML
-- here we are passing 2 XML docs and combining them
declare
l_src XMLTYPE:=XMLTYPE('<ord>
  <head>
    <ord_code>123</ord_code>
    <ord_date>01-01-2015</ord_date>
  </head>
</ord>');

l_dst XMLTYPE:=XMLTYPE('<pos>
  <pos_code>456</pos_code>
  <pos_desc>description</pos_desc>
</pos>');
l_final CLOB;

begin
    
select XMLQuery('copy $tmp := $p1 modify
                insert node $p2 as last into $tmp
                return $tmp' passing l_src as "p1",l_dst as "p2" returning CONTENT).getClobval() into l_final from dual;
DBMS_OUTPUT.PUT_LINE(l_final);
end;





















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
DECLARE
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

BEGIN
    
SELECT XMLQUERY('copy $tmp := $p1 modify
                insert node $p2 as last into $tmp
                return $tmp' PASSING l_src as "p1",l_dst as "p2" RETURNING CONTENT).getClobval() into l_final from dual;
DBMS_OUTPUT.PUT_LINE(l_final);
END;
/
--warehouse table


select warehouse_id,
       EXTRACTVALUE(warehouse_spec,'/Warehouse/Area'),
       XMLQuery('for $i in /Warehouse 
                   return <Details><Docks>{$i/Docks/text()}</Docks> <Rail> {if ($i/RailAccess ="N") then "false" else "true" }</Rail> </Details>' 
                   passing warehouse_spec returning CONTENT).getClobVal() as "RESULT"
from warehouses;

--synatx XMLSerialize(CONTENT XMLTYPE)
select warehouse_id,
       EXTRACTVALUE(warehouse_spec,'/Warehouse/Area'),
       XMLSerialize(CONTENT XMLQuery('for $i in /Warehouse 
                   return <Details><Docks>{$i/Docks/text()}</Docks> <Rail> {if ($i/RailAccess ="N") then "false" else "true" }</Rail> </Details>' 
                   passing warehouse_spec returning CONTENT)) as "RESULT"
from warehouses;

--XMLtable and XMLQuery together.****
select warehouse_id,
       EXTRACTVALUE(warehouse_spec,'/Warehouse/Area'),
       x.*
       from warehouses,
       XMLTABLE('/Details' 
       passing XMLQuery('for $i in /Warehouse 
                   return <Details><Docks>{$i/Docks/text()}</Docks> <Rail> {if ($i/RailAccess ="N") then "false" else "true" }</Rail> </Details>' 
                   passing warehouse_spec returning CONTENT) 
        columns
        docks NUMBER path 'Docks',
        rail VARCHAR2(10) path 'Rail'
               ) x;

-- XMLType Transform 

DECLARE
l_xml XMLTYPE:=XMLTYPE('<?xml version="1.0" encoding="UTF-8"?> 
<?xml-stylesheet type="text/xsl "href="Rule.xsl" ?> 
 <student> 
  <s> 
   <name> Divyank Singh Sikarwar </name> 
   <branch> CSE</branch> 
   <age>18</age> 
   <city> Agra </city> 
  </s> 
  <s> 
   <name> Aniket Chauhan </name> 
   <branch> CSE</branch> 
   <age> 20</age> 
   <city> Shahjahanpur </city> 
  </s> 
  <s>  
   <name> Simran Agarwal</name> 
   <branch> CSE</branch> 
   <age> 23</age> 
   <city> Buland Shar</city> 
  </s> 
  <s>  
   <name> Abhay Chauhan</name> 
   <branch> CSE</branch> 
   <age> 17</age> 
   <city> Shahjahanpur</city> 
  </s> 
  <s>  
   <name> Himanshu Bhatia</name> 
   <branch> IT</branch> 
   <age> 25</age> 
   <city> Indore</city> 
  </s> 
 </student> ');

l_xml_xs XMLTYPE := XMLTYPE('<?xml version="1.0" encoding="UTF-8"?> 
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
<xsl:template match="/"> 
 <html> 
 <body> 
  <h1 align="center">Students'' Basic Details</h1> 
   <table border="3" align="center" > 
   <tr> 
    <th>Name</th> 
    <th>Branch</th> 
    <th>Age</th> 
    <th>City</th> 
   </tr> 
    <xsl:for-each select="student/s"> 
   <tr> 
    <td><xsl:value-of select="name"/></td> 
    <td><xsl:value-of select="branch"/></td> 
    <td><xsl:value-of select="age"/></td> 
    <td><xsl:value-of select="city"/></td> 
   </tr> 
    </xsl:for-each> 
    </table> 
</body> 
</html> 
</xsl:template> 
</xsl:stylesheet>');





BEGIN
DBMS_OUTPUT.PUT_LINE(XMLTYPE.Transform(l_xml,l_xml_xs).getCLobVal());
--NULL;

END;









create table Users
(
  UserID NUMBER,
  Username VARCHAR2(100)
);


insert all into 
Users 
values
(155, 'jweldz')
into Users 
values
(218, 'pwarner')
 into Users  values
(310, 'jeffrey')
select 1 from dual;


create table Events
(
  Id NUMBER NOT NULL,
  UserId NUMBER NULL,
  Title VARCHAR2(250) NOT NULL,
  EventStart DATE NOT NULL
);


INSERT INTO Events (Id, UserId, Title,  EventStart) 
VALUES (3409, NULL, 'Boxing Match', to_date('2014-10-05','YYYY-MM-DD'))


create table UserEvents
(
  UserID NUMBER,
  EventID NUMBER
);

select to_char(sys_extract_utc(systimestamp), 'yyyy-mm-dd"T"hh24:mi:ss"Z"') dt_as_utc
from dual;

INSERT ALL 
INTO 
 UserEvents (UserID, EventID)  VALUES (155, 3409)
 INTO UserEvents (UserID, EventID)  VALUES (218, 3409)
INTO  UserEvents (UserID, EventID)  VALUES (310, 3409)
select 1 from dual;

--sample XML 

<EventList>
  <Event eventid="3409">
    <Title>Boxing Match</Title>
    <Player>
      <UserID>155</UserID>
      <Username>jweldz</Username>
      <UserID>218</UserID>
      <Username>pwarner</Username>
      <UserID>310</UserID>
      <Username>jeffrey</Username>
    </Player>
    <EventStart>2016-04-16T09:00:00</EventStart>
  </Event>
</EventList>

--Solution

select XMLElement("EventList",XMLAgg(XMLElement("Event",
                   XMLAttributes(e.id as "eventId"),
                   XMLElement("Title",e.title),
                   (select XMLElement("Player", XMLAgg(XMLForest(ue.userid as "UserID", 
                                    u.username as "UserName")))
                    from userEvents ue,
                         users u
                     where ue.userid = u.userid
                       and ue.eventid = e.id ),
                    XMLElement("EventStart",to_char((eventstart),'YYYY-MM-DD"T"HH24:MI:SS'))
                   
                   
                   
                   ))).getClobVal() as "RESULT"
                   
                   
                   
from events e;

--sample XML
<Department DEPTNO="10">
  <DNAME>Administration</DNAME>
    <EMP_LIST>
      <EMP_T EMPNO="200">
        <ENAME>Whalen</ENAME>
      </EMP_T>
    </EMP_LIST>
</Department>
--below XML will create below nested XML
select XMLSerialize(CONTENT XMLElement("Department",
                 XMLAttributes(d.department_id as "DEPTNO",'http://www.w3.org/2001/XMLSchema' as "xmlns:xsi",
                 'http://www.oracle.com/Employee.xsd' as "xsi:nonamespaceSchemaLocation",'http://www.w3.org/2001/XMLSchema' as "xmlns"),
                 XMLElement("DNAME", d.department_name),
                 XMLElement("EMP_LIST",
                             (SELECT XMLAGG(XMLElement("EMP_T",
                                        XMLAttributes(e.employee_id as "EMPNO"),
                                        XMLElement("ENAME",e.first_name)
                                        ))
                                from hr.employees e 
                                where e.department_id = d.department_id)
                 
                 )
                 )) as "XML"
from hr.departments d ;
--------using XMLForest to add more than one child under EMP_T tag.
select XMLSerialize(CONTENT XMLElement("Department",
                 XMLAttributes(d.department_id as "DEPTNO"),
                 XMLElement("DNAME", d.department_name),
                 XMLElement("EMP_LIST",
                             (SELECT XMLAGG(XMLElement("EMP_T",
                                        XMLAttributes(e.employee_id as "EMPNO"),
                                        XMlForest(e.first_name||e.last_name as "ENAME",
                                                  e.email as "EMAIL",
                                                  e.hire_date as "HIRE_DATE",
                                                  e.salary as "SALARY")
                                        ))
                                from hr.employees e 
                                where e.department_id = d.department_id)
                 
                 )
                 )) as "XML"
        from hr.departments d ;


/

/*
<Department deptno="30">
  <Employee>PU_MAN Raphaely</Employee>
  <Employee>PU_CLERK Colmenares</Employee>
  <Employee>PU_CLERK Himuro</Employee>
  <Employee>PU_CLERK Tobias</Employee>
  <Employee>PU_CLERK Baida</Employee>
  <Employee>PU_CLERK Khoo</Employee></Department>

<Department deptno="40">
  <Employee>HR_REP Mavris</Employee>
</Department>

*/




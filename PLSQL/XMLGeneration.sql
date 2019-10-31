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



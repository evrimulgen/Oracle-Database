REM   Script: APEX_JSON examples
REM   APEX_JSON examples

CREATE TABLE DEPT ( 
  DEPTNO NUMBER(2) CONSTRAINT PK_DEPT PRIMARY KEY, 
  DNAME VARCHAR2(14), 
  LOC VARCHAR2(13) 
) ;

CREATE TABLE EMP ( 
  EMPNO NUMBER(4) CONSTRAINT PK_EMP PRIMARY KEY, 
  ENAME VARCHAR2(10), 
  JOB VARCHAR2(9), 
  MGR NUMBER(4), 
  HIREDATE DATE, 
  SAL NUMBER(7,2), 
  COMM NUMBER(7,2), 
  DEPTNO NUMBER(2) CONSTRAINT FK_DEPTNO REFERENCES DEPT 
);

INSERT INTO DEPT VALUES (10,'ACCOUNTING','NEW YORK');

INSERT INTO DEPT VALUES (20,'RESEARCH','DALLAS');

INSERT INTO DEPT VALUES (30,'SALES','CHICAGO');

INSERT INTO DEPT VALUES (40,'OPERATIONS','BOSTON');

INSERT INTO EMP VALUES (7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);

INSERT INTO EMP VALUES (7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);

INSERT INTO EMP VALUES (7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);

INSERT INTO EMP VALUES (7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20);

INSERT INTO EMP VALUES (7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);

INSERT INTO EMP VALUES (7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30);

INSERT INTO EMP VALUES (7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10);

INSERT INTO EMP VALUES (7788,'SCOTT','ANALYST',7566,to_date('13-JUL-87','dd-mm-rr')-85,3000,NULL,20);

INSERT INTO EMP VALUES (7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);

INSERT INTO EMP VALUES (7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);

INSERT INTO EMP VALUES (7876,'ADAMS','CLERK',7788,to_date('13-JUL-87', 'dd-mm-rr')-51,1100,NULL,20);

INSERT INTO EMP VALUES (7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30);

INSERT INTO EMP VALUES (7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20);

INSERT INTO EMP VALUES (7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10);

COMMIT


declare 
l_ref_cursor SYS_REFCURSOR; 
l_dept_row dept.rowtype; 
begin 
    select d.*  
    into l_dept_row 
    where deptno = 10; 
     
    APEX_JSON.initialize_clob_output; --create temporary CLOB object 
    APEX_JSON.open_object; ---{ 
    APEX_JSON.open_object('department'); -- department { 
    APEX_JSON.write('department_number',l_dept_row.deptno); 
    APEX_JSON.write('department_name',l_dept_row.dname); 
    -- 
    APEX_JSON.open_array('employees'); --employees [ 
     
    --Now write the array content 
    for cur_rec in (select e.empno,e.ename from emp e where e.deptno = 10) 
    loop 
        APEX_JSON.open_object; --- { 
        APEX_JSON.write('employee_number',cur_rec.empno); 
        APEX_JSON.write('employee_name',cur_rec.ename); 
        APEX_JSON.close_object; ---} 
    end loop; 
     
    APEX_JSON.close_array; -- ] 
    APEX_JSON.close_object; --} 
    APEX_JSON.open_object('metadata'); --metadata { 
    APEX_JSON.write('published_date',to_char(SYSDATE,'YYYY-MON-DD'); 
    APEX_JSON.write('publisher','oracle-base.com'); 
    APEX_JSON.close_object; --} 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end;
/

declare 
l_ref_cursor SYS_REFCURSOR; 
l_dept_row dept.rowtype; 
begin 
    select d.*  
    into l_dept_row 
    from dept 
    where deptno = 10; 
     
    APEX_JSON.initialize_clob_output; --create temporary CLOB object 
    APEX_JSON.open_object; ---{ 
    APEX_JSON.open_object('department'); -- department { 
    APEX_JSON.write('department_number',l_dept_row.deptno); 
    APEX_JSON.write('department_name',l_dept_row.dname); 
    -- 
    APEX_JSON.open_array('employees'); --employees [ 
     
    --Now write the array content 
    for cur_rec in (select e.empno,e.ename from emp e where e.deptno = 10) 
    loop 
        APEX_JSON.open_object; --- { 
        APEX_JSON.write('employee_number',cur_rec.empno); 
        APEX_JSON.write('employee_name',cur_rec.ename); 
        APEX_JSON.close_object; ---} 
    end loop; 
     
    APEX_JSON.close_array; -- ] 
    APEX_JSON.close_object; --} 
    APEX_JSON.open_object('metadata'); --metadata { 
    APEX_JSON.write('published_date',to_char(SYSDATE,'YYYY-MON-DD'); 
    APEX_JSON.write('publisher','oracle-base.com'); 
    APEX_JSON.close_object; --} 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end; 
 
 
 
 
 

/

declare 
l_ref_cursor SYS_REFCURSOR; 
l_dept_row dept.rowtype; 
begin 
    select d.*  
    into l_dept_row 
    from dept 
    where deptno = 10; 
     
    APEX_JSON.initialize_clob_output; --create temporary CLOB object 
    APEX_JSON.open_object; ---{ 
    APEX_JSON.open_object('department'); -- department { 
    APEX_JSON.write('department_number',l_dept_row.deptno); 
    APEX_JSON.write('department_name',l_dept_row.dname); 
    -- 
    APEX_JSON.open_array('employees'); --employees [ 
     
    --Now write the array content 
    for cur_rec in (select e.empno,e.ename from emp e where e.deptno = 10) 
    loop 
        APEX_JSON.open_object; --- { 
        APEX_JSON.write('employee_number',cur_rec.empno); 
        APEX_JSON.write('employee_name',cur_rec.ename); 
        APEX_JSON.close_object; ---} 
    end loop; 
     
    APEX_JSON.close_array; -- ] 
    APEX_JSON.close_object; --} 
    APEX_JSON.open_object('metadata'); --metadata { 
    APEX_JSON.write('published_date',to_char(SYSDATE,'YYYY-MON-DD')); 
    APEX_JSON.write('publisher','oracle-base.com'); 
    APEX_JSON.close_object; --} 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end;
/

declare 
l_ref_cursor SYS_REFCURSOR; 
l_dept_row dept%rowtype; 
begin 
    select d.*  
    into l_dept_row 
    from dept 
    where deptno = 10; 
     
    APEX_JSON.initialize_clob_output; --create temporary CLOB object 
    APEX_JSON.open_object; ---{ 
    APEX_JSON.open_object('department'); -- department { 
    APEX_JSON.write('department_number',l_dept_row.deptno); 
    APEX_JSON.write('department_name',l_dept_row.dname); 
    -- 
    APEX_JSON.open_array('employees'); --employees [ 
     
    --Now write the array content 
    for cur_rec in (select e.empno,e.ename from emp e where e.deptno = 10) 
    loop 
        APEX_JSON.open_object; --- { 
        APEX_JSON.write('employee_number',cur_rec.empno); 
        APEX_JSON.write('employee_name',cur_rec.ename); 
        APEX_JSON.close_object; ---} 
    end loop; 
     
    APEX_JSON.close_array; -- ] 
    APEX_JSON.close_object; --} 
    APEX_JSON.open_object('metadata'); --metadata { 
    APEX_JSON.write('published_date',to_char(SYSDATE,'YYYY-MON-DD')); 
    APEX_JSON.write('publisher','oracle-base.com'); 
    APEX_JSON.close_object; --} 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end; 

/

declare 
l_ref_cursor SYS_REFCURSOR; 
l_dept_row dept%rowtype; 
begin 
    select d.*  
    into l_dept_row 
    from dept d 
    where deptno = 10; 
     
    APEX_JSON.initialize_clob_output; --create temporary CLOB object 
    APEX_JSON.open_object; ---{ 
    APEX_JSON.open_object('department'); -- department { 
    APEX_JSON.write('department_number',l_dept_row.deptno); 
    APEX_JSON.write('department_name',l_dept_row.dname); 
    -- 
    APEX_JSON.open_array('employees'); --employees [ 
     
    --Now write the array content 
    for cur_rec in (select e.empno,e.ename from emp e where e.deptno = 10) 
    loop 
        APEX_JSON.open_object; --- { 
        APEX_JSON.write('employee_number',cur_rec.empno); 
        APEX_JSON.write('employee_name',cur_rec.ename); 
        APEX_JSON.close_object; ---} 
    end loop; 
     
    APEX_JSON.close_array; -- ] 
    APEX_JSON.close_object; --} 
    APEX_JSON.open_object('metadata'); --metadata { 
    APEX_JSON.write('published_date',to_char(SYSDATE,'YYYY-MON-DD')); 
    APEX_JSON.write('publisher','oracle-base.com'); 
    APEX_JSON.close_object; --} 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end; 

/

declare 
l_ref_cursor SYS_REFCURSOR; 
l_dept_row dept%rowtype; 
begin 
    select d.*  
    into l_dept_row 
    from dept d 
    where deptno = 10; 
     
    APEX_JSON.initialize_clob_output; --create temporary CLOB object 
    APEX_JSON.open_object; ---{ 
    APEX_JSON.open_object('department'); -- department { 
    APEX_JSON.write('department_number',l_dept_row.deptno); 
    APEX_JSON.write('department_name',l_dept_row.dname); 
    -- 
    APEX_JSON.open_array('employees'); --employees [ 
     
    --Now write the array content 
    for cur_rec in (select e.empno,e.ename from emp e where e.deptno = 10) 
    loop 
        APEX_JSON.open_object; --- { 
        APEX_JSON.write('employee_number',cur_rec.empno); 
        APEX_JSON.write('employee_name',cur_rec.ename); 
        APEX_JSON.close_object; ---} 
    end loop; 
     
    APEX_JSON.close_array; -- ] 
    APEX_JSON.close_object; --} 
    APEX_JSON.open_object('metadata'); --metadata { 
    APEX_JSON.write('published_date',to_char(SYSDATE,'DD-MON-YYYY')); 
    APEX_JSON.write('publisher','oracle-base.com'); 
    APEX_JSON.close_object; --} 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end;
/

declare 
l_ref_cursor SYS_REFCURSOR; 
l_dept_row dept%rowtype; 
begin 
    select d.*  
    into l_dept_row 
    from dept d 
    where deptno = 10; 
     
    APEX_JSON.initialize_clob_output; --create temporary CLOB object 
    APEX_JSON.open_object; ---{ 
    APEX_JSON.open_object('department'); -- department { 
    APEX_JSON.write('department_number',l_dept_row.deptno); 
    APEX_JSON.write('department_name',l_dept_row.dname); 
    -- 
    APEX_JSON.open_array('employees'); --employees [ 
     
    --Now write the array content 
    for cur_rec in (select e.empno,e.ename from emp e where e.deptno = 10) 
    loop 
        APEX_JSON.open_object; --- { 
        APEX_JSON.write('employee_number',cur_rec.empno); 
        APEX_JSON.write('employee_name',cur_rec.ename); 
        APEX_JSON.close_object; ---} 
    end loop; 
     
    APEX_JSON.close_array; -- ] 
    APEX_JSON.close_object; --} 
    APEX_JSON.open_object('metadata'); --metadata { 
    APEX_JSON.write('published_date',to_char(SYSDATE,'DD-MON-YYYY')); 
    APEX_JSON.write('publisher','oracle-base.com'); 
    APEX_JSON.close_object; --} 
     APEX_JSON.close_object; --} 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end;
/

declare 
l_xml XMLTYPE := XMLTYPE('<departments> 
                                      <department> 
                                        <department_number>10</department_number> 
                                        <department_name>ACCOUNTING</department_name> 
                                      </department> 
                                      <department> 
                                        <department_number>20</department_number> 
                                        <department_name>RESEARCH</department_name> 
                                      </department> 
                                    </departments>'); 
                                     
                                     
begin 
    APEX_JSON.initialize_clob_output; 
     
    APEX_JSON.write(l_xml); 
     
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end; 
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
 
begin 
 APEX_JSON.parse(l_json); 
  
  
 
 
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
 
begin 
 APEX_JSON.parse(l_json); 
 APEX_JSON.get_number('department.department_number'); 
  
 
 
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
 
begin 
 APEX_JSON.parse(l_json); 
 APEX_JSON.get_number(p_path =>'department.department_number'); 
  
 
 
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
l_deptno NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 
 
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
l_deptno NUMBER; 
l_empno NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 l_empno := APEX_JSON.get_number(p_path => 'department.employees.employee_number'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
l_deptno NUMBER; 
l_empno NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 l_empno := APEX_JSON.get_number(p_path => 'department.employees.employee_number'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 DBMS_OUTPUT.PUT_LINE('Employee Number:'||l_empno); 
 
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
 
l_deptno NUMBER; 
l_emp_count NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 l_emp_count:=APEX_JSON.GET_COUNT(p_path => 'department.employees'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 -- Loop to get the employees 
 for i in 1..l_emp_count  
 loop 
    DBMS_OUTPUT.PUT_LINE(p_path=>'department.employees[%d].employee_name',p0=>i); 
 end loop; 
  
end; 

/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
 
l_deptno NUMBER; 
l_emp_count NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 l_emp_count:=APEX_JSON.GET_COUNT(p_path => 'department.employees'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 -- Loop to get the employees 
 for i in 1..l_emp_count  
 loop 
    DBMS_OUTPUT.PUT_LINE(p_path=>'department.employees[%d].employee_name',p0=>i)); 
 end loop; 
  
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
 
l_deptno NUMBER; 
l_emp_count NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 l_emp_count:=APEX_JSON.GET_COUNT(p_path => 'department.employees'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 -- Loop to get the employees 
 for i in 1..l_emp_count  
 loop 
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path=>'department.employees[%d].employee_name',p0=>i)); 
 end loop; 
  
end;
/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	 
}'; 
 
l_deptno NUMBER; 
l_emp_count NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 l_emp_count:=APEX_JSON.GET_COUNT(p_path => 'department.employees'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 -- Loop to get the employees 
 for i in 1..l_emp_count  
 loop 
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path=>'department.employees[%d].employee_name',p0=>i)); 
 end loop; 
  
end; 

/

declare 
l_json CLOB := '{ 
	"department": { 
		"department_number": 10, 
		"department_name": "ACCOUNTING", 
		"employees": [ 
			{ 
				"employee_number": 7782, 
				"employee_name": "CLARK" 
			}, 
			{ 
				"employee_number": 7839, 
				"employee_name": "KING" 
			}, 
			{ 
				"employee_number": 7934, 
				"employee_name": "MILLER" 
			} 
		] 
	}, 
	"metadata": { 
		"published_date": "04-APR-2016", 
		"publisher": "oracle-base.com" 
	} 
}'; 
 
l_deptno NUMBER; 
l_emp_count NUMBER; 
begin 
 APEX_JSON.parse(l_json); 
  
 l_deptno:=APEX_JSON.get_number(p_path =>'department.department_number'); 
 l_emp_count:=APEX_JSON.GET_COUNT(p_path => 'department.employees'); 
 DBMS_OUTPUT.PUT_LINE('Department Number:'||l_deptno); 
 -- Loop to get the employees 
 for i in 1..l_emp_count  
 loop 
    DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path=>'department.employees[%d].employee_name',p0=>i)); 
 end loop; 
  
end;
/

select 'Nightly' as "CycleName", 
       'Nightly_Flow' as "flowName", 
       'processName' as "MERCH_DUMMY" 
from dual;

declare 
l_ref_cursor SYS_REFCURSOR; 
begin 
open l_ref_cursor for 
select 'Nightly' as "CycleName", 
       'Nightly_Flow' as "flowName", 
       'processName' as "MERCH_DUMMY" 
from dual; 
 
APEX_JSON.initialize_clob_output; 
APEX_JSON.open_object; 
APEX_JSON.write(l_ref_cursor); 
APEX_JSON.close_object; 
 
DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end;
/

declare 
l_ref_cursor SYS_REFCURSOR; 
begin 
open l_ref_cursor for 
select 'Nightly' as "CycleName", 
       'Nightly_Flow' as "flowName", 
       'processName' as "MERCH_DUMMY" 
from dual; 
 
APEX_JSON.initialize_clob_output; 
APEX_JSON.open_object; --{ 
APEX_JSON.write('CycleName','Nightly'); 
APEX_JSON.write('flowName','Nightly_Flow'); 
APEX_JSON.write('processName','MERCH_DUMMY'); 
APEX_JSON.close_object; --} 
 
DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end;
/

declare 
l_ref_cursor SYS_REFCURSOR; 
begin 
open l_ref_cursor for 
select 'Nightly' as "CycleName", 
       'Nightly_Flow' as "flowName", 
       'processName' as "MERCH_DUMMY" 
from dual; 
 
APEX_JSON.initialize_clob_output; 
APEX_JSON.open_object; --{ 
APEX_JSON.write('CycleName','Nightly'); 
APEX_JSON.write('flowName','Nightly_Flow'); 
APEX_JSON.write('processName','MERCH_DUMMY'); 
APEX_JSON.close_object; --} 
 
DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_clob_output); 
 
end;
/
-- Parsing complex JSON docs 
declare
l_doc CLOB:='{ ---open_object
    "page": 2,
    "per_page": 6,
    "total": 12,
    "total_pages": 2,
    "data": [ --open_array
        {
            "id": 7,
            "email": "michael.lawson@reqres.in",
            "first_name": "Michael",
            "last_name": "Lawson",
            "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/follettkyle/128.jpg"
        },
        {
            "id": 8,
            "email": "lindsay.ferguson@reqres.in",
            "first_name": "Lindsay",
            "last_name": "Ferguson",
            "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/araa3185/128.jpg"
        },
        {
            "id": 9,
            "email": "tobias.funke@reqres.in",
            "first_name": "Tobias",
            "last_name": "Funke",
            "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/vivekprvr/128.jpg"
        },
        {
            "id": 10,
            "email": "byron.fields@reqres.in",
            "first_name": "Byron",
            "last_name": "Fields",
            "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/russoedu/128.jpg"
        },
        {
            "id": 11,
            "email": "george.edwards@reqres.in",
            "first_name": "George",
            "last_name": "Edwards",
            "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/mrmoiree/128.jpg"
        },
        {
            "id": 12,
            "email": "rachel.howell@reqres.in",
            "first_name": "Rachel",
            "last_name": "Howell",
            "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/hebertialmeida/128.jpg"
        }
    ]
}';
l_data_count NUMBER;
begin
APEX_JSON.parse(l_doc);
DBMS_OUTPUT.PUT_LINE('Total Number Of Page:'||APEX_JSON.get_number(p_path => 'page'));
DBMS_OUTPUT.PUT_LINE('Per Page Count:'||APEX_JSON.get_number(p_path => 'per_page'));
DBMS_OUTPUT.PUT_LINE('Total Count:'||APEX_JSON.get_number(p_path => 'total'));
l_data_count:=APEX_JSON.get_count(p_path=>'data');
DBMS_OUTPUT.PUT_LINE('Array element Count:'||l_data_count);
DBMS_OUTPUT.PUT_LINE('------------------------------------Printing elements inside Data Array------------------------------------');
for i in 1..l_data_count
    loop
        DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_number(p_path => 'data[%d].id',p0 => i));
        DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path => 'data[%d].email',p0 => i));
        DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path => 'data[%d].first_name',p0 => i));
        DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path => 'data[%d].last_name',p0 => i));
        DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path => 'data[%d].avatar',p0 => i));
    end loop;


end;
/
create table tmp_json (
  id integer
, doc clob check (doc is json)
);

INSERT INTO tmp_json VALUES (
    1,
    '{"id":1,
 "myArray":[
  {"attr1":1, "attr2":"string1", "attr3":[1,2,3]},
  {"attr1":2, "attr2":"string2", "attr3":null},
  {"attr1":3, "attr2":"string3", "attr3":[4,5]}
 ]}'
);

INSERT INTO tmp_json VALUES (
    2,
    '{"id":2,
 "myArray":[
  {"attr1":1, "attr2":"string1", "attr3":[7,8]},
  {"attr1":2, "attr2":"string2", "attr3":null}
 ]}'
);

SELECT t.*
  FROM tmp_json,
  JSON_TABLE(doc,'$'
  COLUMNS
    (
        id NUMBER PATH '$.id',
        NESTED PATH '$.myArray[*]'
            COLUMNS
                (
                    attr1 VARCHAR2(100) PATH '$.attr1',
                    attr2 VARCHAR2(100) PATH '$.attr2',
                    NESTED PATH '$.attr3[*]'
                        COLUMNS (
                                    val1 NUMBER PATH '$'

                        )

                )

    )
  
  ) t;

  ---JSON Making
  
[{"percentage":0.5},[1,2,3],100,"California",null]

SELECT JSON_ARRAY(JSON_OBJECT('percentage' VALUE "0.5"),JSON_ARRAY(1,2,3),100,'California',null
)
FROM dual;

{
	"departments": [{
			"department_id": 10,
			"department_name": "Administration",
			"employees": [
				1,
				2,
				3,
				4
			]
		},
		{
			"department_id": 10,
			"department_name": "Administration",
			"employees": [
				1,
				2,
				3,
				4
			]
		}
	]
}

----SOLUTION
SELECT
    JSON_OBJECT ( 'departments' VALUE JSON_ARRAYAGG(JSON_OBJECT('department_id' VALUE d.department_id, 'department_name' VALUE d.
    department_name, 'employees' VALUE(
        SELECT
            JSON_ARRAYAGG(e.employee_id)
        FROM
            employees e
        WHERE
            e.department_id = d.department_id
    ))) )
FROM
    departments d;

--- Sample output
{"department-number":10,"department-name":"ACCOUNTING","location":"NEW YORK"}

SELECT JSON_OBJECT('department-number' VALUE d.department_id,'department-name' VALUE d.department_name,'location' VALUE l.city)
  FROM departments d,
        locations l
    WHERE d.location_id = l.location_id;

SELECT JSON_OBJECTAGG('employee_id' VALUE e.employee_id,'employee_name' VALUE e.first_name )
 FROM employees e;

 
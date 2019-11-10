CREATE TABLE j_purchaseorder
  (id RAW (16) NOT NULL,
   date_loaded TIMESTAMP(6) WITH TIME ZONE,
   po_document CLOB CONSTRAINT ensure_json CHECK (po_document IS JSON));

INSERT INTO j_purchaseorder
  VALUES (
    SYS_GUID(),
    SYSTIMESTAMP,
    '{"PONumber"              : 1600,
      "Reference"             : "ABULL-20140421",
       "Requestor"            : "Alexis Bull",
       "User"                 : "ABULL",
       "CostCenter"           : "A50",
       "ShippingInstructions" : {"name"   : "Alexis Bull",
                                 "Address": {"street"   : "200 Sporting Green",
                                              "city"    : "South San Francisco",
                                              "state"   : "CA",
                                              "zipCode" : 99236,
                                              "country" : "United States of America"},
                                 "Phone" : [{"type" : "Office", "number" : "909-555-7307"},
                                            {"type" : "Mobile", "number" : "415-555-1234"}]},
       "Special Instructions" : null,
       "AllowPartialShipment" : true,
       "LineItems" : [{"ItemNumber" : 1,
                       "Part" : {"Description" : "One Magic Christmas",
                                 "UnitPrice"   : 19.95,
                                 "UPCCode"     : 13131092899},
                       "Quantity" : 9.0},
                      {"ItemNumber" : 2,
                       "Part" : {"Description" : "Lethal Weapon",
                                 "UnitPrice"   : 19.95,
                                 "UPCCode"     : 85391628927},
                       "Quantity" : 5.0}]}');


select jt.phones
from j_purchaseorder,
JSON_TABLE(po_document, '$.ShippingInstructions'
COLUMNS 
    (phones VARCHAR2(1000) FORMAT JSON PATH '$.Phone' )) AS jt; ---Length should be sufficient to hold the content otherwise it will not show anything.
/    
select jt.*
from j_purchaseorder,
JSON_TABLE(po_document,'$.ShippingInstructions.Phone[*]' 
COLUMNS
    (phone_type VARCHAR2(20) PATH '$.type',
     phone_number VARCHAR2(50) PATH '$.number')
) as jt;
/
--JSON Exists Column

select jt.*
from j_purchaseorder,
JSON_TABLE(po_document,'$' ---entire JSON document 
COLUMNS
    (requestor VARCHAR2(20) PATH '$.Requestor',
     has_zip EXISTS PATH '$.ShippingInstructions.Address.zipCode')
) as jt;
/

---JSON Nested Path 

select t.*
from JSON_TABLE('[1,2,["a","b"]', '$'
COLUMNS 
(
  outer_value_o NUMBER PATH '$[0]',
  outer_value_1 NUMBER PATH '$[1]',
  outer_value_2 VARCHAR2(100) FORMAT JSON PATH '$[2]'
 )
) as t;

select t.*
from JSON_TABLE('[1,2,["a","b"]', '$'
COLUMNS 
(
  outer_value_o NUMBER PATH '$[0]',
  outer_value_1 NUMBER PATH '$[1]',
  NESTED PATH '$[2]' ---Nested path 
  COLUMNS (
  val_1 VARCHAR2(1) PATH '$[0]',
  val_2 VARCHAR2(1) PATH '$[1]'
  )
)) t;
/

select t.*
from JSON_TABLE('{a:100, b:200, c:{d:300, e:400}}','$'
COLUMNS (
    col1 NUMBER PATH '$.a',
    col2 NUMBER PATH '$.b',
    NESTED PATH '$.c'
    COLUMNS (
        col3 NUMBER PATH '$.d',
        col4 NUMBER PATH '$.e'
    )
    
)


) as t;
/

/*
REQUESTOR            PHONE_TYPE           PHONE_NUM
-------------------- -------------------- ---------------
Alexis Bull          Office               909-555-7307
Alexis Bull          Mobile               415-555-1234
                                                        */
select t.*
from j_purchaseorder,
JSON_TABLE(po_document,'$'
COLUMNS(
    REQUESTOR VARCHAR2(100) PATH '$.Requestor',
    NESTED PATH '$.ShippingInstructions.Phone[*]'
    COLUMNS (
        phone_type VARCHAR2(100) PATH '$.type',
        phone_number VARCHAR2(100) PATH '$.number'
    )
    )   
) t;
                                                            
--More examples

DROP TABLE json_documents PURGE;

CREATE TABLE json_documents (
  id    RAW(16) NOT NULL,
  data  CLOB,
  CONSTRAINT json_documents_pk PRIMARY KEY (id),
  CONSTRAINT json_documents_json_chk CHECK (data IS JSON)
);

INSERT INTO json_documents (id, data)
VALUES (SYS_GUID(),
        '{
          "FirstName"      : "John",
          "LastName"       : "Doe",
          "Job"            : "Clerk",
          "Address"        : {
                              "Street"   : "99 My Street",
                              "City"     : "My City",
                              "Country"  : "UK",
                              "Postcode" : "A12 34B"
                             },
          "ContactDetails" : {
                              "Email"    : "john.doe@example.com",
                              "Phone"    : "44 123 123456",
                              "Twitter"  : "@johndoe"
                             },
          "DateOfBirth"    : "01-JAN-1980",
          "Active"         : true
         }');

INSERT INTO json_documents (id, data)
VALUES (SYS_GUID(),
        '{
          "FirstName"      : "Jayne",
          "LastName"       : "Doe",
          "Job"            : "Manager",
          "Address"        : {
                              "Street"   : "100 My Street",
                              "City"     : "My City",
                              "Country"  : "UK",
                              "Postcode" : "A12 34B"
                             },
          "ContactDetails" : {
                              "Email"    : "jayne.doe@example.com",
                              "Phone"    : ""
                             },
          "DateOfBirth"    : "01-JAN-1982",
          "Active"         : false
         }');

COMMIT;


select t.*
from j_purchaseorder,
JSON_TABLE(po_document,'$'
columns (
PONumber NUMBER PATH '$.PONumber',
Reference varchar2(100) path '$.Reference',
Requestor varchar2(100) path '$.Requestor',
Usr varchar2(100) path '$.User',
CostCenter varchar2(100) path '$.CostCenter',
nested path '$.ShippingInstructions' --nested path
columns(
        name varchar2(100) path '$.name',
        nested path '$.Address'
        columns(
             street varchar2(100) path '$.street',
             city varchar2(100) path '$.city',
             state varchar2(100) path '$.state',
             zipCode varchar2(100) path '$.zipCode',
             country varchar2(100) path '$.country'
        ),
        nested path '$.Phone[*]'
        columns(
              phone_type varchar2(100) path '$.type',
              phone_number varchar2(100) path '$.number'
        )
),
--line items
nested path '$.LineItems[*]'
columns(
        ItemNumber varchar2(100) path '$.ItemNumber',
        nested path '$.Part'
        columns(
        Description varchar2(100) path '$.Description'
        )
)

)
) t;
/




DECLARE
myJSON CLOB:='[{"name":"John", "age":31, "city":"New York"},{"name":"Sena", "age":27, "city":"Italy"}]';
l_name VARCHAR2(100);

CURSOR C_parse_json IS
  SELECT t.name
  FROM JSON_TABLE(myJSON,'$[*]'
  COLUMNS
  (
    name VARCHAR2(20) PATH '$.name'

  )
) AS t; 

BEGIN
  OPEN C_parse_json;
  LOOP
    FETCH C_parse_json INTO l_name;
    EXIT WHEN C_parse_json%NOTFOUND;
  END LOOP;
  CLOSE C_parse_json;

  DBMS_OUTPUT.PUT_LINE(l_name);

END;


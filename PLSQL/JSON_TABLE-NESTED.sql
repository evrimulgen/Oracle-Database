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
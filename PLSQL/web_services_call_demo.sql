CREATE OR REPLACE FUNCTION add_numbers (p_int_1  IN  NUMBER,
                                        p_int_2  IN  NUMBER)
  RETURN NUMBER
AS
  l_envelope  CLOB;
  l_xml       XMLTYPE;
  l_result    VARCHAR2(32767);
BEGIN

  -- Build a SOAP document appropriate for the web service.
  l_envelope := '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <ws_add xmlns="http://oracle-base.com/webservices/" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <int1 xsi:type="xsd:integer">' || p_int_1 || '</int1>
      <int2 xsi:type="xsd:integer">' || p_int_2 || '</int2>
    </ws_add>
  </soap:Body>
</soap:Envelope>';

  -- Get the XML response from the web service.
  l_xml := APEX_WEB_SERVICE.make_request(
    p_url      => 'http://oracle-base.com/webservices/server.php',
    p_action   => 'http://oracle-base.com/webservices/server.php/ws_add',
    p_envelope => l_envelope
  );

  -- Display the whole SOAP document returned.
  DBMS_OUTPUT.put_line('l_xml=' || l_xml.getClobVal());

  -- Pull out the specific value of interest.
  l_result := APEX_WEB_SERVICE.parse_xml(
    p_xml   => l_xml,
    p_xpath => '//return/text()',
    p_ns    => 'xmlns:ns1="http://oracle-base.com/webservices/"'
  );

  DBMS_OUTPUT.put_line('l_result=' || l_result);

  RETURN TO_NUMBER(l_result);
END;
/

select ADD_NUMBERS(10,6) from dual;

declare
l_response CLOB;
l_url varchar2(4000) := 'http://oracle-base.com/webservices/add-numbers.php'; --web service URL
l_result NUMBER;
begin
---get XML from 
l_response := apex_web_service.make_rest_request(p_url => l_url,
                                                 p_http_method => 'GET',
                                                 p_parm_name  => apex_util.string_to_table('p_int_1:p_int_2'),
                                                 p_parm_value => apex_util.string_to_table('12:12')
                                                );
                                                
                                             
dbms_output.put_line(l_response);
--parse the response
l_result :=apex_web_service.parse_xml(p_xml => XMLTYPE(l_response), --convert CLOB to XML
                           p_xpath => '//number/text()'
                        );
dbms_output.put_line(l_result);
end;
/
--enable access to web services at https://reqres.in/

DECLARE
  l_principal VARCHAR2(20) := 'APEX_040200';
  --l_principal VARCHAR2(20) := 'APEX_050000';
  --l_principal VARCHAR2(20) := 'APEX_050100';
  --l_principal VARCHAR2(20) := 'APEX_180200';
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => 'reqres.in', 
    lower_port => 80,
    upper_port => 80,
    ace        => xs$ace_type(privilege_list => xs$name_list('https'),
                              principal_name => l_principal,
                              principal_type => xs_acl.ptype_db)); 
END;
/


declare
l_response CLOB;
l_url varchar2(4000) := 'https://reqres.in/api/users/2'; --web service URL
l_result varchar2(50);
begin
---get XML from 
l_response := apex_web_service.make_rest_request(p_url => l_url,
                                                 p_http_method => 'GET',
                                                 p_wallet_path => 'file:C:\app\db_home\bin\ow\wallets', --neded for https acccess
                                                 p_wallet_pwd => '88Asfkol$'
                                                );
                                                

                                             
DBMS_OUTPUT.PUT_LINE(l_response);
----parse the response
APEX_JSON.parse(l_result); 
l_result:=APEX_JSON.get_number(p_path => 'data.email');
DBMS_OUTPUT.PUT_LINE(l_result);
DBMS_OUTPUT.PUT_LINE('Result is -'||l_result);

end;
/

---Pasrse JSON using APEX_JSON

declare
l_response CLOB:='{
    "data": {
        "id": 2,
        "email": "janet.weaver@reqres.in",
        "first_name": "Janet",
        "last_name": "Weaver",
        "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/josephstein/128.jpg"
    }
}';

begin
APEX_JSON.parse(l_response);
DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_number(p_path => 'data.id'));
DBMS_OUTPUT.PUT_LINE(APEX_JSON.get_varchar2(p_path => 'data.email'));
end;
/
---POST Request

DECLARE
l_response CLOB;
l_url VARCHAR2(250) := 'https://reqres.in/api/users';
usrid NUMBER;
l_request CLOB;
--cursor c_get_request is
--select 'morpheus' as "name",
--       'leader' as "job"
--from dual;

BEGIN
apex_web_service.g_request_headers(1).name := 'Content-Type';
apex_web_service.g_request_headers(1).value := 'application/json';
--open l_ref_cursor for
--select 'morpheus' as "name",
--       'leader' as "job"
--from dual;
APEX_JSON.initialize_clob_output;
APEX_JSON.open_object; ---{
APEX_JSON.write('name','morpheus');
APEX_JSON.write('job','leader');
APEX_JSON.close_object; --}
l_request := APEX_JSON.get_clob_output;
DBMS_OUTPUT.PUT_LINE(l_request);
l_response :=apex_web_service.make_rest_request(p_url => l_url,
                                               p_http_method => 'POST',
                                               p_wallet_path => 'file:C:\app\db_home\bin\ow\wallets', --neded for https acccess
                                               p_wallet_pwd => '88Asfkol$',
                                               p_body => l_request --this is needed for passign a json body in the request 
--                                               p_parm_name => apex_util.string_to_table('name:job'),   ----------- this is needed adding parameter in URL
--                                               p_parm_value => apex_util.string_to_table('morpheus:leader')  ----------- this is needed adding parameter in URL
                                               );

DBMS_OUTPUT.PUT_LINE(l_response);
--parse the response
--APEX_JSON.parse(l_response);
--usrid := APEX_JSON.get_number(p_path => 'id');

DBMS_OUTPUT.PUT_LINE('Created ID is :'||usrid);

END;
---POST : Registration Successful

DECLARE
l_response CLOB;
l_url VARCHAR2(250) := 'https://reqres.in/api/register'; --update url
usrid NUMBER;
l_request CLOB;
BEGIN
apex_web_service.g_request_headers(1).name := 'Content-Type';
apex_web_service.g_request_headers(1).value := 'application/json';
l_request:=
l_response :=apex_web_service.make_rest_request(p_url => l_url,
                                               p_http_method => 'POST',
                                               p_wallet_path => 'file:C:\app\db_home\bin\ow\wallets', --neded for https acccess
                                               p_wallet_pwd => '88Asfkol$',
                                               p_parm_name => apex_util.string_to_table('"email":"password"'),
                                               p_parm_value => apex_util.string_to_table('"eve.holt@reqres.in":"pistol"')
                                               );

DBMS_OUTPUT.PUT_LINE(l_response);
--parse the response
--APEX_JSON.parse(l_response);
--usrid := APEX_JSON.get_number(p_path => 'id');

--DBMS_OUTPUT.PUT_LINE('Created ID is :'||usrid);

END;
/

















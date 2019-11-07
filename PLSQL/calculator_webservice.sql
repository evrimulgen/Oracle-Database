DECLARE
    l_url        VARCHAR2(250) := 'http://www.dneonline.com/calculator.asmx';
    l_action     VARCHAR2(250) := 'http://tempuri.org/Multiply';
    l_num_1      NUMBER := 134;
    l_num_2      NUMBER := 167;
-- You can get the envelope structure from SOAP Ui
    l_envelope   CLOB := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
   <soapenv:Header/>
   <soapenv:Body>
      <tem:Multiply>
         <tem:intA>'
                       || l_num_1
                       || '</tem:intA>
         <tem:intB>'
                       || l_num_2
                       || '</tem:intB>
      </tem:Multiply>
   </soapenv:Body>
</soapenv:Envelope>';
    l_response   XMLTYPE;
    l_result     NUMBER;
BEGIN
    l_response := apex_web_service.make_request(p_url => l_url, --The URL endpoint of the Web service.
     p_action => l_action, ---The SOAP Action corresponding to the operation to be invoked. There is no action in ReST
--    p_version           IN VARCHAR2 default '1.1',
--    p_collection_name   IN VARCHAR2 default null,
     p_envelope => l_envelope, ---The SOAP envelope to post to the service.
--    p_username          IN VARCHAR2 default null,
--    p_password          IN VARCHAR2 default null,
--    p_proxy_override    IN VARCHAR2 default null,
     p_transfer_timeout => 180, p_wallet_path => NULL, --The file system path to a wallet if the URL endpoint is https
                              p_wallet_pwd => NULL);

--DBMS_OUTPUT.PUT_LINE(l_response.GetClobval());

    l_result := apex_web_service.parse_xml(p_xml => l_response, p_xpath => '//MultiplyResult/text()', p_ns => 'xmlns="http://tempuri.org/"'
    );

    dbms_output.put_line('Result :' || l_result);
END;
--
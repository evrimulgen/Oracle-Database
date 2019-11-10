DECLARE



BEGIN
    ---Create role
  ORDS.create_role(
    p_role_name => 'emp_role'
  );
  --create privilage
  ̥ORDS.create_privilege(
      p_name        => 'emp_priv',
      p_role_name   => 'emp_role',
      p_label       => 'EMP Data',
      p_description => 'Allow access to the EMP data.');
    --- create privilege mapping.
  ORDS.create_privilege_mapping(
      p_privilege_name => 'emp_priv',
      p_pattern        => '/employees/*');  --mapping with the patterns    

  COMMIT;
---Until this Point , it's defined that authenticatino is needed for web service but not the how we should authencate
  --OAuth : Client Credentials  
/*

The client credentials flow is a two-legged process that seems the most natural to me 
as I mostly deal with server-server communication, which should have no human interaction.
For this flow we use the client credentials to return an access token, which is used to authorize calls to protected resources. The example steps through the individual calls, but in reality it would be automated by the application
*/
--Create Client
OAUTH.create_client(
    p_name            => 'emp_client',
    p_grant_type      => 'client_credentials',
    p_owner           => 'My Company Limited',
    p_description     => 'A client for Emp management',
    p_support_email   => 'tim@example.com',
    p_privilege_names => 'emp_priv'
  );
--Grant client the role we creted earlier.
OAUTH.grant_client_role(
    p_client_name => 'emp_client',
    p_role_name   => 'emp_role'
  );



END;
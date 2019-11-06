---Enable Oracle ReST data services
select * from dba_objects where object_name like '%ORDS%';
select * from dba_users where username in ('ORDS_PUBLIC_USER','APEX_PUBLIC_USER','APEX_REST_PUBLIC_USER','APEX_LISTENER');
--Download ORDS
--- Rest  Enable a Schema
begin
ORDS.enable_schema
(
p_enabled   => TRUE,
p_schema    => 'HR',
p_url_mapping_type  => 'BASE_PATH',
p_url_mapping_pattern   => 'hr',
p_auto_rest_auth    => FALSE
);
COMMIT;
end;
/
--The DEFINE_SERVICE procedure allows you to create a new module, template and handler in a single step
--If the module already exists, it's replaced by the new definition.
begin
ORDS.define_service(
p_module_name => 'rest-v1',
p_base_path => 'rest-v1/',
p_pattern   => 'employees/',
p_method    => 'GET',
p_source_type   => ORDS.source_type_collection_feed,
p_source    => 'select * from employees',
p_items_per_page    => 0
);
COMMIT;

end;
/

SELECT id, name, uri_prefix
FROM   user_ords_modules
ORDER BY name;
/

SELECT id, module_id, uri_template
FROM   user_ords_templates
ORDER BY module_id;

SELECT id, template_id, source_type, method, source
FROM   user_ords_handlers
ORDER BY id;
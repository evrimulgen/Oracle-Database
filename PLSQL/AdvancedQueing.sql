/*
The orders queue has two subscriptions, one for orders made from within the US, and another for orders
made from Europe. The region_code in the orders_message_type distinguishes the two types of orders.
*/
create type orders_message_type as OBJECT
(
order_id NUMBER,
product_code varchar2(10),
customer_id varchar2(10),
order_details varchar2(4000),
price  NUMBER(4,2),
region_code varchar2(100)
);
--Create a Queue table
--drop 
--begin
--dbms_aqadm.drop_queue_table ( 
--   queue_table        => 'aq_admin.orders_qt'); 
--end;

begin
dbms_aqadm.create_queue_table
(
queue_table             => 'aq_admin.orders_qt',
queue_payload_type      => 'aq_admin.orders_message_type',
multiple_consumers       => TRUE);---multi consumer queue
end;
/
--drop a queue
/* Stop the queue preparatory to dropping it (a queue may be dropped only after
   it has been succesfully stopped for enqueing and dequeing): */ 
--begin
-- dbms_aqadm.stop_queue (  
--   Queue_name        => 'orders_msg_queue');   
--end;
/
/* Drop queue: */  
--begin
--dbms_aqadm.drop_queue (  
--   Queue_name         => 'orders_msg_queue'); 
--end;
--/

begin
dbms_aqadm.create_queue(
queue_name          => 'orders_msg_queue',
queue_table         => 'aq_admin.orders_qt',
queue_type          => dbms_aqadm.normal_queue,
max_retries         => 0,
retry_delay         => 0,
retention_time      => 1209600,
dependency_tracking => false,
comment             => 'Test object queue type',
auto_commit         => false
);

end;
/
--start the queue

exec dbms_aqadm.start_queue('orders_msg_queue');

select * from orders_qt;

-- add subsriber
begin
--dbms_aqadm.add_subscriber(
--queue_name      => 'ORDERS_MSG_QUEUE',
--subscriber      => sys.aq$_agent('US_ORDERS', null,null),
--Rule            => 'tab.user_data.region_code = ''USA'''
--);
--
dbms_aqadm.add_subscriber(
queue_name      => 'aq_admin.orders_msg_queue',
subscriber      => sys.aq$_agent('EU_ORDERS',null,null),
Rule            =>  'tab.user_data.region_code = ''EUROPE''',
transformation  => 'aq_admin.dollar_to_euro'
);
end;
/

select * from user_queue_tables;
select * from user_queues;
--create function dollar_to_euro
create or replace function aq_admin.dollar_to_euro(src aq_admin.orders_message_type)
return aq_admin.orders_message_type
as
begin
return aq_admin.orders_message_type(src.order_id,src.product_code,src.customer_id,src.order_details,src.price*.5,src.region_code);
end;
/
--create the trnasformation
begin
DBMS_TRANSFORM.CREATE_TRANSFORMATION(
schema => 'AQ_ADMIN',
name => 'DOLLAR_TO_EURO',
from_schema => 'AQ_ADMIN',
from_type => 'orders_message_type',
to_schema => 'AQ_ADMIN',
to_type => 'orders_message_type',
transformation =>'AQ_ADMIN.dollar_to_euro(source.user_data)');
end;
/

DECLARE
enqueue_options dbms_aq.enqueue_options_t;
message_properties
dbms_aq.message_properties_t;
message_handle RAW(16);
message aq_admin.orders_message_type;
message_id NUMBER;
BEGIN
message := AQ_ADMIN.orders_message_type (1, 325, 49,
'Details: Digital Camera. Brand: ABC. Model: XYX' , 23.2, 'EUROPE' );
-- default for enqueue options VISIBILITY is ON_COMMIT.
-- message has no delay and no expiration
message_properties.CORRELATION := message.order_id;
DBMS_AQ.ENQUEUE (
queue_name => 'aq_admin.orders_msg_queue',
enqueue_options => enqueue_options,
message_properties => message_properties,
payload => message,
msgid => message_handle);
COMMIT;
END;
/
--enqueue_options dbms_aq.enqueue_options_t;
--message_properties dbms_aq.message_properties_t;
--message_handle RAW(16);
------DBMS_AQ.ENQUEUE(
--    queue_name => '',
--    enqueue_options => '',
--    message_properties => message_properties,
--    payload => message,
--    msgid => message_handle
--  )

--dequeue messages for consumption
declare
dequeue_options   dbms_aq.dequeue_options_t;
message_properties dbms_aq.message_properties_t;
message_handle RAW(16);
message aq_admin.orders_message_type;
begin
 --dequeue options
    dequeue_options.consumer_name := 'EU_ORDERS';
    --visibility options
    dequeue_options.visibility := dbms_aq.immediate;
    
    
  DBMS_AQ.DEQUEUE(
  queue_name    => 'aq_admin.orders_msg_queue',
  dequeue_options => dequeue_options,
  message_properties => message_properties,
  payload => message,
  msgid => message_handle
  );
  
  dbms_output.put_line('Order ID:'||message.order_id);

end;
/


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

-----------------------------------------------DBMS_AQ-----------------------------------------------
DBMS_AQ.ENQUEUE
(
queue_name => --name of the queue to which message should be enqueued.
enqueue_options => --enqueue_options_t
message_options =>--message_options_t
payload =>
msgid =>
);
--visibility:  specifies the transactional behaviour of the enqueue request.
--ON_COMMIT : the enqueue is part of current transaction. 
--IMMEDIATE : 

TYPE SYS.ENQUEUE_OPTIONS_T IS RECORD (
   visibility            BINARY_INTEGER  DEFAULT ON_COMMIT,
   relative_msgid        RAW(16)         DEFAULT NULL,
   sequence_deviation    BINARY_INTEGER  DEFAULT NULL,
   transformation        VARCHAR2(61)    DEFAULT NULL,
   delivery_mode         PLS_INTEGER     NOT NULL DEFAULT PERSISTENT);



DBMS_AQ.DEQUEUE (
   queue_name          IN      VARCHAR2,
   dequeue_options     IN      dequeue_options_t,
   message_properties  OUT     message_properties_t,
   payload             OUT     "<ADT_1>"
   msgid               OUT     RAW);

TYPE DEQUEUE_OPTIONS_T IS RECORD (
   consumer_name     VARCHAR2(30)    DEFAULT NULL, --Name of the consumer. Only those messages matching the consumer name are accessed. If a queue is not set up for multiple consumers, then this field should be set to NULL.
   dequeue_mode      BINARY_INTEGER  DEFAULT REMOVE, --REMOVE: Read the message and delete it. This setting is the default. The message can be retained in the queue table based on the retention properties.
   navigation        BINARY_INTEGER  DEFAULT NEXT_MESSAGE, --Retrieve the next message that is available and matches the search criteria. If the previous message belongs to a message group, then AQ retrieves the next available message that matches the search criteria and belongs to the message group. This setting is the default.
   visibility        BINARY_INTEGER  DEFAULT ON_COMMIT,--on_commit and immediate:--COMMIT:The dequeue will be part of the current transaction. This setting is the default.
   --IMMEDIATE: The dequeue operation is not part of the current transaction, but an autonomous transaction which commits at the end of the operation
   wait              BINARY_INTEGER  DEFAULT FOREVER, --Specifies the wait time if there is currently no message available which matches the search criteria
   msgid             RAW(16)         DEFAULT NULL,
   correlation       VARCHAR2(128)   DEFAULT NULL,
   deq_condition     VARCHAR2(4000)  DEFAULT NULL,
   signature         aq$_sig_prop    DEFAULT NULL,
   transformation    VARCHAR2(61)    DEFAULT NULL,
   delivery_mode     PLS_INTEGER     DEFAULT PERSISTENT);



TYPE message_properties_t IS RECORD (
   priority               BINARY_INTEGER  NOT NULL DEFAULT 1,
   delay                  BINARY_INTEGER  NOT NULL DEFAULT NO_DELAY,
   expiration             BINARY_INTEGER  NOT NULL DEFAULT NEVER,
   correlation            VARCHAR2(128)   DEFAULT NULL, --Returns the identifier supplied by the producer of the message at enqueue time.
   attempts               BINARY_INTEGER,
   recipient_list         AQ$_RECIPIENT_LIST_T, --This parameter is only valid for queues that allow multiple consumers. The default recipients are the queue subscribers. This parameter is not returned to a consumer at dequeue time
   exception_queue        VARCHAR2(61)    DEFAULT NULL,
   enqueue_time           DATE,
   state                  BINARY_INTEGER,
   sender_id              SYS.AQ$_AGENT   DEFAULT NULL, 
   original_msgid         RAW(16)         DEFAULT NULL,
   signature              aq$_sig_prop    DEFAULT NULL,
   transaction_group      VARCHAR2(30)    DEFAULT NULL,
   user_property          SYS.ANYDATA     DEFAULT NULL
   delivery_mode          PLS_INTEGER     NOT NULL DEFAULT DBMS_AQ.PERSISTENT); 

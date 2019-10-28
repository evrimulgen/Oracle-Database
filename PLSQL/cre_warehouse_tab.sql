
CREATE TABLE warehouses
    ( warehouse_id       NUMBER(3) 
    , warehouse_spec     SYS.XMLTYPE
    , warehouse_name     VARCHAR2(35)
    , location_id        NUMBER(4)
    ) ;



INSERT INTO warehouses VALUES (1,xmltype.createxml( 
'<?xml version="1.0"?> 
<Warehouse> 
<Building>Owned</Building> 
<Area>25000</Area> 
<Docks>2</Docks> 
<DockType>Rear load</DockType> 
<WaterAccess>Y</WaterAccess> 
<RailAccess>N</RailAccess> 
<Parking>Street</Parking> 
<VClearance>10 ft</VClearance> 
</Warehouse>' 
),'Southlake, Texas',1400); 

INSERT INTO warehouses VALUES (2,xmltype.createxml( 
'<?xml version="1.0"?> 
<Warehouse> 
<Building>Rented</Building> 
<Area>50000</Area> 
<Docks>1</Docks> 
<DockType>Side load</DockType> 
<WaterAccess>Y</WaterAccess> 
<RailAccess>N</RailAccess> 
<Parking>Lot</Parking> 
<VClearance>12 ft</VClearance> 
</Warehouse>' 
),'San Francisco',1500); 
INSERT INTO warehouses VALUES (3,xmltype.createxml( 
'<?xml version="1.0"?> 
<Warehouse> 
<Building>Rented</Building> 
<Area>85700</Area> 
<DockType></DockType> 
<WaterAccess>N</WaterAccess> 
<RailAccess>N</RailAccess> 
<Parking>Street</Parking> 
<VClearance>11.5 ft</VClearance> 
</Warehouse>' 
),'New Jersey',1600); 
INSERT INTO warehouses VALUES (4,xmltype.createxml( 
'<?xml version="1.0"?> 
<Warehouse> 
<Building>Owned</Building> 
<Area>103000</Area> 
<Docks>3</Docks> 
<DockType>Side load</DockType> 
<WaterAccess>N</WaterAccess> 
<RailAccess>Y</RailAccess> 
<Parking>Lot</Parking> 
<VClearance>15 ft</VClearance> 
</Warehouse>' 
),'Seattle, Washington',1700); 

commit;






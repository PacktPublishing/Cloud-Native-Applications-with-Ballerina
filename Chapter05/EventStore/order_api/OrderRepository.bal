import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/io;
import ballerina/uuid;

string dbUser = "root";
string dbPassword = "root";

string jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";
public class OrderRepository {
    jdbc:Client jdbcClient;
    public function init() returns error? {
        io:println("Initializing Order Repository");
        jdbc:Client|sql:Error tempClient = new (jdbcUrl, dbUser, dbPassword);
        if tempClient is jdbc:Client {
            self.jdbcClient = tempClient;
        } else {
            return error("Error while initializing client", tempClient);
        }
    }
    public function createEntity(string entityId, string entityType, Event event) returns error? {
        transaction {
            sql:ParameterizedQuery createEntity = `INSERT INTO Entities( 
            EntityId, EntityType, EntityVersion) VALUES( ${entityId}, ${entityType}, 1)`; 
            _ = check self.jdbcClient->execute(createEntity);
            sql:ParameterizedQuery createEvent = `INSERT INTO Events( 
            EventId, EventType, EntityType, EntityId, EventData, Timestamp)  
            VALUES(${event.eventId}, ${event.eventType}, ${event.entityType}, ${event.entityId}, ${event.eventData.toString()}, NOW())`; 
            _ = check self.jdbcClient->execute(createEvent);
            check commit;
        }
        return;
    }
    public function readEvents(string entityId) returns Event[]|error {
        stream<Event, sql:Error?> entityItemStream = self.jdbcClient->query(`SELECT * FROM Events WHERE 
        EntityId=${entityId}`);
        Event[] eventList = [];
        _ = check entityItemStream.forEach(function(Event event) {
            eventList.push(event);
        });
        return eventList;       
    }
    public function readEventsTo(string entityId, string timeTo) returns Event[]|error {
        stream<Event, sql:Error?> resultStream = self.jdbcClient->query(`SELECT * FROM Events WHERE 
        EntityId=${entityId} AND Timestamp < ${timeTo}`);
        Event[] eventList = [];
        _ = check resultStream.forEach(function(Event event) {
            eventList.push(event);
        });
        return eventList;       
    }
    public function removeEvent(string entityId) returns error? {
        sql:ParameterizedQuery createOrder = `DELETE FROM Events WHERE EntityId = ${entityId}`; 
        _ = check self.jdbcClient->execute(createOrder);
        return; 
    }
    public function removeEventTo(string entityId, string timeTo) returns error? {
        sql:ParameterizedQuery createOrder = `DELETE FROM Events WHERE EntityId = ${entityId} AND Timestamp < ${timeTo}`; 
        _ = check self.jdbcClient->execute(createOrder);
        return; 
    }
    public function updateEntityVersion(string entityId) returns error? {
        sql:ParameterizedQuery createOrder = `UPDATE Entities SET EntityVersion = EntityVersion + 1 WHERE EntityId = ${entityId}`; 
        _ = check self.jdbcClient->execute(createOrder);       
    }
    public function getEntityVerison(string entityId) returns int|error {
        stream<record{}, sql:Error?> resultStream = self.jdbcClient->query(`SELECT EntityVersion FROM Entities WHERE EntityId = ${entityId}`);
        record {|record {} value;|}? result = check resultStream.next();
        if (result is record {|record {} value;|}) {
            return <int>result.value["EntityVersion"];
        }
        return error("Entities table is empty");
    }
    public function updateOrder(Order 'order) returns error?{
        sql:ParameterizedQuery createOrder = `REPLACE INTO Orders( 
        OrderId, ShippingAddress, CustomerId, Status)  
        VALUES(${'order.orderId}, ${'order.shippingAddress}, ${'order.customerId}, ${'order.status})`; 
        _ = check self.jdbcClient->execute(createOrder);
        return; 
    }
    public function updateOrderItems(OrderItem[] orderItemTable) returns error?{
        sql:ParameterizedQuery[] insertQueries =
        from var item in orderItemTable
            select  `REPLACE INTO OrderItems( 
        OrderItemId, OrderId, Quantity, InventoryItemId)  
        VALUES(${item.orderItemId}, ${item.orderId}, ${item.quantity}, ${item.inventoryItemId})`;
        _ = check self.jdbcClient->batchExecute(insertQueries);
    }
    public function getAllEntities() returns @untainted Entity[]|error {
        stream<Entity, sql:Error?> orderItemStream = self.jdbcClient->query(`SELECT * FROM Entities`, Entity);
        Entity[] entities = [];
        _ = check orderItemStream.forEach(function(Entity entity) {
            entities.push(entity);
        });
        return entities;
    }
    public function createOrder(Order 'order) returns error|string{
        string orderId = uuid:createType1AsString();
        sql:ParameterizedQuery createOrder = `REPLACE INTO Orders( 
        OrderId, ShippingAddress, CustomerId, Status)  
        VALUES(${orderId}, ${'order.shippingAddress}, ${'order.customerId}, ${'order.status})`; 
        _ = check self.jdbcClient->execute(createOrder);
        return orderId;
    }

    public function addOrderItem(string orderId, int quantity, string inventoryItemId) returns error|string {
        string orderItemId = uuid:createType1AsString();
        sql:ParameterizedQuery createOrder = `REPLACE INTO OrderItems( 
        OrderItemId, OrderId, Quantity, InventoryItemId)  
        VALUES(${orderItemId}, ${orderId}, ${quantity}, ${inventoryItemId})`; 
        _ = check self.jdbcClient->execute(createOrder);
        return orderItemId;
    }

    public function addSnapshot(Snapshot snapshot) returns error? {
        sql:ParameterizedQuery createOrder = `INSERT INTO Snapshots( 
        SnapshotsId, EntityType, EntityId, EntityVersion, Message, Timestamp)  
        VALUES(${snapshot.snapshotId}, ${snapshot.entityType}, ${snapshot.entityId}, ${snapshot.entityVersion}, 
        ${snapshot.message}, NOW())`; 
        _ = check self.jdbcClient->execute(createOrder);
        return;  
    }
    public function addEvent(Event event, int initialVersion) returns error?{
        io:println("version " + initialVersion.toString());
        sql:ParameterizedCallQuery sqlQuery = 
                `CALL AddEventR(${event.entityId}, ${initialVersion}, ${event.eventId}, ${event.eventType}, ${event.entityType}, ${event.eventData})`;
        io:println(sqlQuery);
        _ = check self.jdbcClient->call(sqlQuery);
    }
}
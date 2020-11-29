import ballerina/io;
import ballerina/sql;
import ballerina/system;
import ballerina/java.jdbc;

string dbUser = "root";
string dbPassword = "root";
string jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";
public function main() returns error? {
    //string orderId = check createOrder("New York", "334234234");
    //check addProductToOrder(orderId, "3454435324", 20);
    string orderId = "ae24fde0-78b6-4855-811a-177586384519";
    string productId = "d929f59a-35a4-4153-bbeb-0f555efa32c1";
    string inventoryId = "d929f59a-35a4-4153-cceb-0f445efa44c1";
    string inventoryItemId = "d929f59a-35a4-4153-cceb-0f432efa44c1";
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);

    OrderItemTable orderItems = check getOrderItemTableByOrderId(jdbcClient, orderId);
    boolean validOrder = true;
    foreach OrderItem item in orderItems {
        int orderQuantity = item.quantity;
        int inventoryQuantity = check getAvailableProductQuantity(jdbcClient, item.inventoryItemId);
        if orderQuantity > inventoryQuantity {
            validOrder = false;
            break;
        }
    }
    if validOrder {
        check reserveOrderItems(jdbcClient, orderItems);
        check setOrderStatus(jdbcClient, orderId, "Verified");
    } else {
        check setOrderStatus(jdbcClient, orderId, "VerificationFailed");
    }


}

function createOrder(jdbc:Client jdbcClient, string shippingAddress, string customerId) returns error|string{
    string orderId = system:uuid();
    sql:ParameterizedQuery createOrder = `INSERT INTO OMS_BALLERINA.Orders( 
        OrderId, ShippingAddress, CustomerId, Status)  
        VALUES(${orderId}, ${shippingAddress}, ${customerId}, 'Created')`; 
    sql:ExecutionResult result = check jdbcClient->execute(createOrder); 
    return orderId;
}

function addProductToOrder(jdbc:Client jdbcClient, int orderId, int productId, int quantity) returns error?{
        sql:ParameterizedQuery addProduct = `INSERT INTO OMS_BALLERINA.OrderItems( 
        OrderId, ProductId, Quantity)  
        VALUES(${orderId}, ${productId}, ${quantity})`; 
    sql:ExecutionResult|sql:Error result = 
                jdbcClient->execute(addProduct); 
    if (result is sql:ExecutionResult) { 
        io:println("Inserted Row count: ", result.affectedRowCount); 
    } else { 
        io:println("Error occurred: ", result);
    } 
}
function getAvailableProductQuantity(jdbc:Client jdbcClient, string inventoryItemId) returns @untainted int|error {
    stream<record{}, error> resultStream = jdbcClient->query(`SELECT Quantity FROM InventoryItems WHERE 
    InventoryItemId = ${inventoryItemId}`);
    record {|record {} value;|}? result = check resultStream.next();
    if (result is record {|record {} value;|}) {
        return <int>result.value["Quantity"];
    }
    return error("Inventory table is empty");
}

public function reserveOrderItems(jdbc:Client jdbcClient, OrderItemTable orderItems) returns error?{
    foreach OrderItem item in orderItems {
        string inventoryItemId = item.inventoryItemId;
        int quantity = item.quantity;
        sql:ExecutionResult result = check jdbcClient->execute(`UPDATE InventoryItems SET Quantity = Quantity - ${quantity} WHERE 
        InventoryItemId = ${inventoryItemId}`);
        string pendingOrderId = system:uuid();
        result = check jdbcClient->execute(`INSERT INTO PendingOrderItems(PendingOrderItemId, OrderId, InventoryItemId, Quantity) VALUES 
        (${pendingOrderId}, ${item.orderId}, ${inventoryItemId}, ${quantity})`);
    }
    return;
}

function setOrderStatus(jdbc:Client jdbcClient, string orderId, string status) returns error? {
        sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = '${status}' WHERE 
        OrderId = ${orderId}`; 
        sql:ExecutionResult result = check self.jdbcClient->execute(updateOrder);
}
public function getOrderById(string orderId) returns @untainted Order|error {
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    stream<record{}, error> orderStream = jdbcClient->query(`SELECT * FROM Orders WHERE OrderId=${orderId}`, Order);
    stream<Order, sql:Error> resultStream = <stream<Order, sql:Error>>orderStream;
    record {|record {} value;|}? result = check resultStream.next();
    if (result is record {|record {} value;|}) {
        return <Order>result.value;
    } else {
        return error("No records found");
    }
}
public function getOrderItemTableByOrderId(jdbc:Client jdbcClient, string orderId) returns @untainted OrderItemTable|error {
    stream<record{}, error> resultStream = jdbcClient->query(`SELECT * FROM OrderItems WHERE OrderId=${orderId}`, OrderItem);
    stream<OrderItem, sql:Error> orderItemStream = <stream<OrderItem, sql:Error>>resultStream;
    OrderItemTable orderItemTable = table [];
    check orderItemStream.forEach(function(OrderItem orderItem) {
        orderItemTable.put(orderItem);
    });
    return orderItemTable;
}
import ballerina/sql;
import ballerina/java.jdbc;
import ballerina/io;
import ballerina/java;

string dbUser = "root";
string dbPassword = "root";

public function createRandomUUID() returns handle = @java:Method {
    name: "randomUUID",
    'class: "java.util.UUID"
} external;

string jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";
public class OrderRepository {
    jdbc:Client jdbcClient;
    public function init() returns error?{
        io:println("Initializing Order Repository");
        jdbc:Client|sql:Error tempClient = new (jdbcUrl, dbUser, dbPassword);
        if tempClient is jdbc:Client {
            self.jdbcClient = tempClient;
        } else {
            return error("Error while initializing client", tempClient);
        }
    }
    public function getOrderById(string orderId) returns @untainted Order|error {
        stream<record{}, error> orderStream = self.jdbcClient->query(`SELECT * FROM Orders WHERE OrderId=${orderId}`, Order);
        stream<Order, sql:Error> resultStream = <stream<Order, sql:Error>>orderStream;
        record {|record {} value;|}|error? result = resultStream.next();
        if (result is record {|record {} value;|}) {
            return <Order>result.value;
        } else if result is () {
            return error("Error while reading Order table");
        } else {
            return error("", result);
        }
    }
    public function getOrderItemTableByOrderId(string orderId) returns @untainted OrderItemTable|error {
        stream<record{}, error> resultStream = self.jdbcClient->query(`SELECT * FROM OrderItems WHERE OrderId=${orderId}`, OrderItem);
        stream<OrderItem, sql:Error> orderItemStream = <stream<OrderItem, sql:Error>>resultStream;
        OrderItemTable orderItemTable = table [];
        error? e = orderItemStream.forEach(function(OrderItem orderItem) {
            orderItemTable.put(orderItem);
        });
        if (e is error) {
            return error("Error while reading data", e);
        }
        return orderItemTable;
    }
    public function createOrder(Order 'order) returns error?{
        sql:ParameterizedQuery createOrder = `INSERT INTO Orders( 
        OrderId, ShippingAddress, CustomerId, Status)  
        VALUES(${'order.orderId}, ${'order.shippingAddress}, ${'order.customerId}, ${'order.status})`; 
        sql:ExecutionResult result = check self.jdbcClient->execute(createOrder);
    }

    public function addOrderItem(string orderId, int quantity, string inventoryItemId) returns error|string {
        string orderItemId = createRandomUUID().toString();
        sql:ParameterizedQuery createOrder = `INSERT INTO OrderItems( 
        OrderItemId, OrderId, Quantity, InventoryItemId)  
        VALUES(${orderItemId}, ${orderId}, ${quantity}, ${inventoryItemId})`; 
        sql:ExecutionResult result = check self.jdbcClient->execute(createOrder);
        return orderItemId;
    }
    public function updateOrderStatusVerified(string orderId) returns error? {
        sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = 'Verified' WHERE 
        OrderId = ${orderId}`; 
        sql:ExecutionResult result = check self.jdbcClient->execute(updateOrder);
    }
    public function updateOrderStatusFailed(string orderId) returns error? {
        sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = 'VerificationFailed' WHERE 
        OrderId = ${orderId}`; 
        sql:ExecutionResult result = check self.jdbcClient->execute(updateOrder);
    }

    public function setOrderStatus(string orderId, string status) returns error? {
        sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = '${status}' WHERE 
        OrderId = ${orderId}`; 
        sql:ExecutionResult result = check self.jdbcClient->execute(updateOrder);
    }
}
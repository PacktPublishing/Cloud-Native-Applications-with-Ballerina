import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/io;
import ballerina/uuid;

string dbUser = "root";
string dbPassword = "root";

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
        stream<Order, sql:Error?> orderStream = self.jdbcClient->query(`SELECT * FROM Orders WHERE OrderId=${orderId}`, Order);
        record {|record {} value;|}|error? result = orderStream.next();
        if (result is record {|record {} value;|}) {
            return <Order>result.value;
        } else if result is () {
            return error("Error while reading Order table");
        } else {
            return error("", result);
        }
    }
    public function getOrderItemTableByOrderId(string orderId) returns @untainted OrderItemTable|error {
        stream<OrderItem, sql:Error?> orderItemStream = self.jdbcClient->query(`SELECT * FROM OrderItems WHERE OrderId=${orderId}`, OrderItem);
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
        _ = check self.jdbcClient->execute(createOrder);
    }

    public function addOrderItem(string orderId, int quantity, string inventoryItemId) returns error|string {
        string orderItemId = uuid:createType1AsString();
        sql:ParameterizedQuery createOrder = `INSERT INTO OrderItems( 
        OrderItemId, OrderId, Quantity, InventoryItemId)  
        VALUES(${orderItemId}, ${orderId}, ${quantity}, ${inventoryItemId})`; 
        _ = check self.jdbcClient->execute(createOrder);
        return orderItemId;
    }
    public function updateOrderStatusVerified(string orderId) returns error? {
        sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = 'Verified' WHERE 
        OrderId = ${orderId}`; 
        _ = check self.jdbcClient->execute(updateOrder);
    }
    public function updateOrderStatusFailed(string orderId) returns error? {
        sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = 'VerificationFailed' WHERE 
        OrderId = ${orderId}`; 
        _ = check self.jdbcClient->execute(updateOrder);
    }

    public function setOrderStatus(string orderId, string status) returns error? {
        sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = '${status}' WHERE 
        OrderId = ${orderId}`; 
        _ = check self.jdbcClient->execute(updateOrder);
    }
}
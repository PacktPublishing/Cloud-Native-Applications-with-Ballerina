import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/sql;
import ballerina/java.jdbc;

string dbUser = "root";
string dbPassword = "root";
string jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";

http:Client inventoryEndpoint = new ("http://localhost:9091");
http:Client paymentEndpoint = new ("http://localhost:9092");
http:Client deliveryEndpoint = new ("http://localhost:9094");
service OrderService on new http:Listener(9090) {
    @http:ResourceConfig {
        methods: ["POST"],
        body: "orderDetails"
    }
    resource function addOrderItem (http:Caller caller, http:Request req, json orderDetails) returns error? {
        string inventoryItemId = <string> <@untainted> check orderDetails.inventoryItemId;
        int quantity = <int> <@untainted> check orderDetails.quantity;
        log:printInfo("Add order item " + inventoryItemId);
        var response = inventoryEndpoint->get(string `/InventoryService/orderItem/${inventoryItemId}`);
        http:Response clientResponse = new;
        if response is http:Response {
            var payload = response.getJsonPayload();
            if (payload is json) {
                log:printInfo("Json data: " + payload.toJsonString());
                int reponseQuantity = <int> payload.quantity;
                if reponseQuantity > quantity {
                    clientResponse.setPayload("Verification success");
                } else {
                    clientResponse.setPayload("Verification failed");
                }
            } else {
                log:printError("Error in parsing json data", payload);
                clientResponse.statusCode = 400;
                clientResponse.setPayload("Failed");
            }
        } else {
            clientResponse.statusCode = 400;
            clientResponse.setPayload("Failed");
        }
        io:println(response);
        check caller->respond(clientResponse);
    }
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/payOrder/{orderId}"
    }
    resource function payOrder(http:Caller caller, http:Request req, string orderId) returns @tainted error? {
        log:printInfo("Starting pay order");
        jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
        OrderItemTable orderItems = check getOrderItemTableByOrderId(jdbcClient, <@untainted>orderId);
        if orderItems.length() == 0 {
            check sendError(caller, "No order items found");
        } else {
            check getAmount(caller, orderItems, <@untainted>orderId);
        }
        check jdbcClient.close();
    }
    
}
function getAmount (http:Caller caller, OrderItemTable orderItems, string orderId) returns @tainted error?{
    log:printInfo("Get amount ");
    var amountResponse = inventoryEndpoint->post(string `/InventoryService/getAmount`, check orderItems.toArray().cloneWithType(json));
    if amountResponse is http:Response && amountResponse.statusCode == 200{
        json payload = check amountResponse.getJsonPayload();
        check payOrder(caller, orderItems, orderId, <@untainted><float>payload.totalPrice);
    } else {
        check sendError(caller, "Error get amount");
    }
}
function payOrder (http:Caller caller, OrderItemTable orderItems, string orderId, float amount) returns error?{
    log:printInfo("Pay order");
    var paymentResponse = paymentEndpoint->get(string `/PaymentService/payOrder/${<@untainted>orderId}/${amount}`);
    if paymentResponse is http:Response && paymentResponse.statusCode == 200 {
        check purchaseItemes(caller, orderItems, orderId);
    } else {
        check sendError(caller, "Error payment");
    }
}
function purchaseItemes(http:Caller caller, OrderItemTable orderItems, string orderId) returns error?{
    log:printInfo("Purchase Item");
    var purchaseResponse = inventoryEndpoint->post(string `/InventoryService/purchaseItems`, check orderItems.toArray().cloneWithType(json));
    if purchaseResponse is http:Response && purchaseResponse.statusCode == 200 {
        check deliverItems(caller, orderItems, orderId);
    } else {
        check sendError(caller, "Error purchase");
    }
}
function deliverItems(http:Caller caller, OrderItemTable orderItems, string orderId) returns error?{
    log:printInfo("Deliver Item");
    var delevaryResponse = deliveryEndpoint->get(string `/DelivaryService/deliverOrder/${orderId}`);
    if delevaryResponse is http:Response && delevaryResponse.statusCode == 200 {
        check caller->respond(delevaryResponse);
    } else {
        check sendError(caller, "Error delivery");
    }
}
function sendError(http:Caller caller, string reason) returns error?{
    http:Response res = new;
    res.statusCode = 500;
    res.setPayload("Failure " + reason);
    check caller->respond(res);
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
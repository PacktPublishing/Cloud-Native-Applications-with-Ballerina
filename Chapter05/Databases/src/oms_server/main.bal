import ballerina/http;
import ballerina/io;
import ballerina/java.jdbc;
import ballerina/system;
import ballerina/sql;

string dbUser = "root";
string dbPassword = "root";
string jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";

@http:ServiceConfig {}
service OrderAPI on new http:Listener(9090) {
    @http:ResourceConfig {
        methods: ["POST"],
        body: "orderDetails"
    }
    resource function addNewOrder(http:Caller caller, http:Request req, json orderDetails) {
        io:println(orderDetails);
        json|error shippingAddress = orderDetails.shippingAddress;
        json|error customerId = orderDetails.customerId;
        if customerId is json && shippingAddress is json {
            error|string orderId = createOrder(<@untainted> shippingAddress.toString(), <@untainted> customerId.toString());
            if orderId is string {
                http:Response res = new;
                res.statusCode = 200;
                json response = {
                    code: 200,
                    orderId: orderId
                };
                res.setPayload(response);
                var result = caller->respond(res);
                if (result is error) {
                    io:println(result.message(), result);
                }
            } else {
                io:println("Error creating database link", orderId);
                responseError500(caller);
            }
        } else {
            io:println("Error reading input values ");
            responseError500(caller);
        }
    }
}
function responseError500(http:Caller caller) {
    http:Response res = new;
    res.statusCode = 500;
    var result = caller->respond(res);
    if (result is error) {
        io:println(result.message(), result);
    }
}
function createOrder(string shippingAddress, string customerId) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string orderId = system:uuid();
    sql:ParameterizedQuery createOrder = `INSERT INTO OMS_BALLERINA.Orders( 
        OrderId, ShippingAddress, CustomerId, Status)  
        VALUES(${orderId}, ${shippingAddress}, ${customerId}, 'Created')`; 
    sql:ExecutionResult result = check jdbcClient->execute(createOrder); 
    check jdbcClient.close();
    return orderId;
}
function addProductToOrder(string orderId, string productId, string quantity) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string orderItemId = system:uuid();
    sql:ParameterizedQuery createOrder = `INSERT INTO OMS_BALLERINA.OrderItems( 
        OrderItemId, OrderId, ProductId, Quantity)  
        VALUES(${orderItemId}, ${orderId}, ${productId}, ${quantity})`;
    sql:ExecutionResult result = check jdbcClient->execute(createOrder); 
    check jdbcClient.close();
    return orderItemId;
}

function getAvailableProductQuantity(int inventoryId, int productId) returns @untainted int|error {
    sql:ParameterizedQuery getProductQuantity = `SELECT Quantity FROM OMS_BALLERINA.InventoryItems WHERE 
    InventoryId = ${inventoryId} AND ProductId = ${productId}`;
    stream<record{}, error> resultStream =
        mysqlClient->query(getProductQuantity);
    record {|record {} value;|}|error? result = resultStream.next();
    if (result is record {|record {} value;|}) {
        io:println("Remaining auantity : ", result.value["Quantity"]);
        return <int>result.value["Quantity"];
    } else if (result is error) {
        return error("Next operation on the stream failed", result);
    } else {
        return error("Inventory table is empty");
    }
}
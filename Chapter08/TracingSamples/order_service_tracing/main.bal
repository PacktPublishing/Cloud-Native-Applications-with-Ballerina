// Pull Jaeger docker image with `docker pull jaegertracing/opentelemetry-all-in-one`
// Run Jaeger with `docker run -d -p 13133:13133 -p 16686:16686 -p 55680:55680 jaegertracing/opentelemetry-all-in-one`
// Go to `http://localhost:16686/`
// Run with `bal run --observability-included order_service_tracing/` command
// Start delivery, inventory, notification, payment services
// Send the following curl
// curl -X POST http://localhost:9090/OrderService/addOrderItem -d '{"inventoryItemId": "555555555", "quantity" : 2}'
// curl -X GET http://localhost:9090/OrderService/payOrder/44444444
// Click OderService and Find Traces on Jaeger console
// Click on a trace to further analyze
// Check Trace Graph view
// Check the System Architecture view
// Check the custom spans defined in inventory service
import ballerina/http;
import ballerina/log;
import ballerinax/jaeger as _;

http:Client inventoryEndpoint = check new ("http://localhost:9091");
http:Client paymentEndpoint = check new ("http://localhost:9092");
http:Client deliveryEndpoint = check new ("http://localhost:9094");

service /OrderService on new http:Listener(9090) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello, World!"); 
    }
    resource function post addOrderItem(http:Caller caller, http:Request req,@http:Payload {} json orderDetails) returns error? {
        log:printInfo("Start add order item");
        string inventoryItemId = <string> check orderDetails.inventoryItemId;
        int quantity = <int> check orderDetails.quantity;
        json payload = check inventoryEndpoint->get(string `/InventoryService/orderItem/${inventoryItemId}`);
        http:Response clientResponse = new;
        int reponseQuantity = <int> check payload.quantity;
            if reponseQuantity > quantity {
                clientResponse.setPayload("Verification success");
            } else {
                clientResponse.setPayload("Verification failed");
            }
        check caller->respond(clientResponse);
    }
    resource function get payOrder/[string orderId](http:Caller caller, http:Request req) returns @tainted error? {
        log:printInfo("Start pay order " + orderId);
        OrderItemTable orderItems = check getOrderItemTableByOrderId(orderId);
        if orderItems.length() == 0 {
            check sendError(caller, "No order items found");
        } else {
            check getAmount(caller, orderItems, orderId);
        }
    }
}
public function getOrderItemTableByOrderId(string orderId) returns OrderItemTable|error {
     OrderItemTable orderItem = table [ 
        {orderItemId: "1", orderId: "44444444", quantity: 2, inventoryItemId: "555555555"}, 
        {orderItemId: "2", orderId: "44444444", quantity: 1, inventoryItemId: "555555555"}
    ];
    return orderItem;
}
function sendError(http:Caller caller, string reason) returns error?{
    http:Response res = new;
    res.statusCode = 500;
    res.setPayload("Failure " + reason);
    check caller->respond(res);
}
function getAmount (http:Caller caller, OrderItemTable orderItems, string orderId) returns @tainted error?{
    log:printInfo("Get amount");
    json payload = check inventoryEndpoint->post(string `/InventoryService/getAmount`, check orderItems.toArray().cloneWithType(json));
    check payOrder(caller, orderItems, orderId, <float> check payload.totalPrice);
}
function payOrder (http:Caller caller, OrderItemTable orderItems, string orderId, float amount) returns error?{
    log:printInfo("Pay order");
    http:Response paymentResponse = check paymentEndpoint->get(string `/PaymentService/payOrder/${orderId}/${amount}`);
    if paymentResponse.statusCode == 200 {
        check purchaseItems(caller, orderItems, orderId);
    } else {
        check sendError(caller, "Error payment");
    }
}
function purchaseItems(http:Caller caller, OrderItemTable orderItems, string orderId) returns error?{
    log:printInfo("Purchase items");
    http:Response purchaseResponse = check inventoryEndpoint->post(string `/InventoryService/purchaseItems`, check orderItems.toArray().cloneWithType(json));
    if purchaseResponse.statusCode == 200 {
        check deliverItems(caller, orderItems, orderId);
    } else {
        check sendError(caller, "Error purchase");
    }
}
function deliverItems(http:Caller caller, OrderItemTable orderItems, string orderId) returns error?{
    log:printInfo("Deliver items");
    http:Response delevaryResponse = check deliveryEndpoint->get(string `/DelivaryService/deliverOrder/${orderId}`);
    if delevaryResponse.statusCode == 200 {
        check caller->respond(delevaryResponse);
    } else {
        check sendError(caller, "Error delivery");
    }
}
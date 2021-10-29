import ballerinax/rabbitmq;
import ballerina/http;

service /OrderAPI  on new http:Listener(9090) { 
    resource function post addNewOrder(http:Caller caller, http:Request req, @http:Payload json orderDetails) returns error? { 
        OrderRepository orderRepository = check new();
        json shippingAddress = check orderDetails.shippingAddress;
        json customerId = check orderDetails.customerId;
        OrderAggregate createdOrder = check createOrder(orderRepository, customerId.toString(), shippingAddress.toString());
        check caller->respond({
            code:200,
            orderId: createdOrder.getOrderId()
        });
    }
    resource function post addProductToOrder(http:Caller caller, http:Request req, @http:Payload json productDetails) returns error? { 
        OrderRepository orderRepository = check new();
        json orderId = check productDetails.orderId;
        json inventoryItemId = check productDetails.inventoryItemId;
        json quantity = check productDetails.quantity;
        OrderAggregate readOrder = check getOrderAggregateById(orderRepository, orderId.toString());
        string orderItemId = check readOrder.addProductToOrder(inventoryItemId.toString(), <int>quantity);
        check caller->respond({
            code:200,
            orderItemId: orderItemId
        });
    }
    resource function get validateOrder/[string orderId](http:Caller caller, http:Request req) returns error? { 
        OrderRepository orderRepository = check new();
        check verifyOrder(orderRepository, orderId);
        check caller->respond({
            code:200
        });
    }
}

function createOrder(OrderRepository orderRepository, string customerId, string shippingAddress) returns OrderAggregate|error{
    return check createOrderAggregate(orderRepository, customerId, "Matara");
}

function verifyOrder(OrderRepository orderRepository, string orderId) returns error?{
    OrderItemTable orderItemTable = check orderRepository.getOrderItemTableByOrderId(orderId);
    OrderItem[] orderItems = orderItemTable.toArray();
    json data = orderItems.toJson();
    ChannelMessage channelMessage = {
        serviceType: "Orchestrator",
        action: "OrderCreated",
        message: data
    };
    check sendMessage("ReplyQueue", channelMessage);
}
function sendMessage(string queueName, ChannelMessage channelMessage) returns error?{
    rabbitmq:Client newClient = check new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    check newClient->queueDeclare(queueName);
    check newClient->publishMessage({ content: channelMessage.toString().toBytes(), routingKey: queueName });
}
import ballerina/io;
import ballerinax/rabbitmq;
import orchestrator_handler;
const string rabbitMQHostName = "localhost";
const int rabbitMQPort= 5672;

public function main() returns error?{
    io:println("Hello World!");
    OrderRepository orderRepository = check new();
    
    //OrderAggregate createdOrder = check createOrder(orderRepository, "d929f59a-35a4-4153-bbeb-0f445efa32c1", "Mathara3");
    //check createdOrder.addProductToOrder("d929f59a-35a4-4153-cceb-0f432efa44c1", 10);

    OrderAggregate readOrder = check getOrderAggregateById(orderRepository, "ae24fde0-78b6-4855-811a-177586384519");
    io:println(readOrder.getOrderShippingAddress());
    check verifyOrder(orderRepository, "ae24fde0-78b6-4855-811a-177586384519");
    return;
}

function createOrder(OrderRepository orderRepository, string customerId, string shippingAddress) returns OrderAggregate|error{
    return check createOrderAggregate(orderRepository, customerId, "Matara");
}

function verifyOrder(OrderRepository orderRepository, string orderId) returns error?{
    OrderItemTable orderItemTable = check orderRepository.getOrderItemTableByOrderId(orderId);
    OrderItem[] orderItems = orderItemTable.toArray();
    json data = orderItems.toJson();
    orchestrator_handler:ChannelMessage channelMessage = {
        serviceType: "Orchestrator",
        action: "OrderCreated",
        message: data
    };
    check sendMessage("ReplyQueue", channelMessage);
}

function sendMessage(string queueName, orchestrator_handler:ChannelMessage channelMessage) returns error?{
    rabbitmq:Connection connection = new ({host: rabbitMQHostName, port: rabbitMQPort});
    rabbitmq:Channel channel = new (connection);
    var queueResult = check channel->queueDeclare({queueName: queueName});
    var sendResult = check channel->basicPublish(channelMessage, queueName);
}
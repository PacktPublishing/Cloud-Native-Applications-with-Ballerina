import ballerina/io;
import ballerinax/rabbitmq;


public function main() returns error?{
    io:println("Hello World!");

    OrderRepository orderRepository = check new();
    //OrderAggregate readOrder1 = check createNewOrder(orderRepository, "d929f59a-35a4-4153-bbeb-0f445efa32c1", "New York", eventHandler);
    OrderAggregate readOrder2 = check getOrderAggregateByEntityId(orderRepository, "c394b679-9dc7-4378-8460-74fedd5f8902");
    check readOrder2.addProductToOrder("d929f59a-35a4-4153-cceb-0f432efa44c1", 10, eventHandler);
    io:println("shipping addre " + readOrder2.getOrderId());
    //io:println(readOrder.getOrderItems());

}

function eventHandler(Event event) returns error?{
    OrderRepository orderRepository = check new();
    json|error eventData = event.eventData.fromJsonString();
    if eventData is json {
        ChannelCommandMessage channelCommandMessage = {
            serviceType: "OrderCommand",
            entityId: event.entityId,
            message: eventData
        };
        check sendMessage("OrderCommandQueue", channelCommandMessage); 
    }
}

function sendMessage(string queueName, ChannelCommandMessage channelCommandMessage) returns error?{
    rabbitmq:Connection connection = new ({host: "localhost", port: 5672});
    rabbitmq:Channel channel = new (connection);
    var queueResult = channel->queueDeclare({queueName: queueName});
    if (queueResult is error) {
        io:println("An error occurred while creating the queue.");
    }
    var sendResult = check channel->basicPublish(channelCommandMessage, queueName);
}
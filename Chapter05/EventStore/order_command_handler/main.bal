import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/lang.value;

listener rabbitmq:Listener channelListenerInventoryHandler = new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
@rabbitmq:ServiceConfig {
    queueName: "OrderCommandQueue"
}

service rabbitmq:Service on channelListenerInventoryHandler {
    remote function onMessage(rabbitmq:Message message, rabbitmq:Caller caller) returns error? {
        string messageContent = check string:fromBytes(message.content);
        json j2 = check value:fromJsonString(messageContent);
        ChannelCommandMessage channelMessage = check j2.cloneWithType(ChannelCommandMessage);  
        io:println("Order Command Handler: Message recieved" + channelMessage.toString());

        OrderRepository orderRepository = check new OrderRepository();
        match channelMessage.serviceType {
            "OrderCommand" => {
                OrderAggregate orderAggregate = check getOrderAggregateByEntityId(orderRepository, channelMessage.entityId);
                check orderRepository.updateOrder(orderAggregate.getOrder());
                OrderItem[] orderItems = orderAggregate.getOrderItems();
                if orderItems.length() > 0 {
                    check orderRepository.updateOrderItems(orderAggregate.getOrderItems());
                }
            }
        }
    }
}

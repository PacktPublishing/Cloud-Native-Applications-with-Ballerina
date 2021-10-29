import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/lang.value;

listener rabbitmq:Listener channelListenerInventoryHandler = new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
@rabbitmq:ServiceConfig {
    queueName: "OrderQueue"
}

service rabbitmq:Service on channelListenerInventoryHandler {
    remote function onMessage(rabbitmq:Message message, rabbitmq:Caller caller) returns error? {
        string messageContent = check string:fromBytes(message.content);
        json j2 = check value:fromJsonString(messageContent);
        ChannelMessage channelMessage = check j2.cloneWithType(ChannelMessage);  
        io:println("Order Handler: Message recieved" + channelMessage.toString());
        OrderRepository orderRepository = check new();
        if channelMessage.serviceType == "OrderService" {
            string orderId = channelMessage.message.toString();
            match channelMessage.action {
                "UpdateOrderVerified" => {
                    io:println("Order verified");
                    check orderRepository.setOrderStatus(orderId, "Verified");
                    
                }
                "UpdateOrderVerificationFailed" => {
                    io:println("Order verification failed");
                    check orderRepository.setOrderStatus(orderId, "VerificationFailed");
                }
            }
        }
    }
}
import ballerina/io;
import ballerinax/rabbitmq;
import order_api;

rabbitmq:Connection connectionOrder = new ({host: "localhost", port: 5672});

listener rabbitmq:Listener channelListenerOrder = new (connectionOrder);
@rabbitmq:ServiceConfig {
    queueConfig: {
        queueName: "OrderQueue"
    }
}

service rabbitmqOrderConsumer on channelListenerOrder {
    resource function onMessage(rabbitmq:Message message, ChannelMessage response) returns error?{
        io:println("Order Handler: Message recieved" + response.toString());
        order_api:OrderRepository orderRepository = check new();
        if response.serviceType == "OrderService" {
            string orderId = <string>response.message;
            match response.action {
                "UpdateOrderVerified" => {
                    check orderRepository.setOrderStatus(<@untainted> orderId, "Verified");
                }
                "UpdateOrderVerificationFailed" => {
                    check orderRepository.setOrderStatus(<@untainted> orderId, "VerificationFailed");
                }
            }
        }
    }
}
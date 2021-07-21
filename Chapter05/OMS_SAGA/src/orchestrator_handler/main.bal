import ballerina/io;
import ballerinax/rabbitmq;
rabbitmq:Connection connectionOrchestrator = new ({host: "localhost", port: 5672});

listener rabbitmq:Listener channelListenerOrchestrator = new (connectionOrchestrator);
@rabbitmq:ServiceConfig {
    queueConfig: {
        queueName: "ReplyQueue"
    }
}

service rabbitmqConsumerOrchestrator on channelListenerOrchestrator {
    resource function onMessage(rabbitmq:Message message, ChannelMessage channelMessage) returns error?{
        io:println("Orchestrator Handler: Message recieved" + channelMessage.toString());
        if channelMessage.serviceType == "Orchestrator" {
            match channelMessage.action {
                "OrderCreated" => {
                    channelMessage.serviceType = "InventoryService";
                    channelMessage.action = "VerifyOrder";
                    check sendMessage("InventoryQueue", <@untainted> channelMessage);
                }
                "OrderVerified" => {
                    string orderId = <string>channelMessage.message;
                    channelMessage.serviceType = "OrderService";
                    channelMessage.action = "UpdateOrderVerified";
                    channelMessage.message = orderId;
                    check sendMessage("OrderQueue", <@untainted> channelMessage);
                }
                "OrderVerificationFailed" => {
                    string orderId = <string>channelMessage.message;
                    channelMessage.serviceType = "OrderService";
                    channelMessage.action = "UpdateOrderVerificationFailed";
                    channelMessage.message = orderId;
                    check sendMessage("OrderQueue", <@untainted> channelMessage);
                }
            }
        }
    }
}
public function sendMessage(string queueName, ChannelMessage channelMessage) returns error?{
    rabbitmq:Connection connection = new ({host: "localhost", port: 5672});
    rabbitmq:Channel channel = new (connection);
    var queueResult = channel->queueDeclare({queueName: queueName});
    if (queueResult is error) {
        io:println("An error occurred while creating the queue.");
    }
    var sendResult = check channel->basicPublish(channelMessage, queueName);
}
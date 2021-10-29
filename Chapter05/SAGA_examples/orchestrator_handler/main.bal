import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/lang.value;

listener rabbitmq:Listener channelListenerOrchestrator = new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
@rabbitmq:ServiceConfig {
    queueName: "ReplyQueue"
}
service rabbitmq:Service on channelListenerOrchestrator {
    remote function onMessage(rabbitmq:Message message, rabbitmq:Caller caller) returns error? {
        string messageContent = check string:fromBytes(message.content);
        json j2 = check value:fromJsonString(messageContent);
        ChannelMessage channelMessage = check j2.cloneWithType(ChannelMessage);
       
        io:println("Orchestrator Handler: Message recieved" + channelMessage.toString());
        if channelMessage.serviceType == "Orchestrator" {
            match channelMessage.action {
                "OrderCreated" => {
                    channelMessage.serviceType = "InventoryService";
                    channelMessage.action = "VerifyOrder";
                    check sendMessage("InventoryQueue", channelMessage);
                }
                "OrderVerified" => {
                    string orderId = <string>channelMessage.message;
                    channelMessage.serviceType = "OrderService";
                    channelMessage.action = "UpdateOrderVerified";
                    channelMessage.message = orderId;
                    check sendMessage("OrderQueue", channelMessage);
                }
                "OrderVerificationFailed" => {
                    string orderId = <string>channelMessage.message;
                    channelMessage.serviceType = "OrderService";
                    channelMessage.action = "UpdateOrderVerificationFailed";
                    channelMessage.message = orderId;
                    check sendMessage("OrderQueue", channelMessage);
                }
            }
        }
    }
}
function sendMessage(string queueName, ChannelMessage channelMessage) returns error?{
    rabbitmq:Client newClient = check new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    check newClient->queueDeclare(queueName);
    check newClient->publishMessage({ content: channelMessage.toString().toBytes(), routingKey: queueName });
}
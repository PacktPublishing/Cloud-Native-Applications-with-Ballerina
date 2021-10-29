import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/lang.value;

listener rabbitmq:Listener channelListenerInventoryHandler = new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
@rabbitmq:ServiceConfig {
    queueName: "InventoryQueue"
}

service rabbitmq:Service on channelListenerInventoryHandler {
    remote function onMessage(rabbitmq:Message message, rabbitmq:Caller caller) returns error? {
        string messageContent = check string:fromBytes(message.content);
        json j2 = check value:fromJsonString(messageContent);
        ChannelMessage channelMessage = check j2.cloneWithType(ChannelMessage);  
        io:println("Inventory Handler: Message recieved" + channelMessage.toString());
        InventoryRepository inventoryRepository = check new();
            if (channelMessage.serviceType == "InventoryService") {
                match channelMessage.action {
                    "VerifyOrder" => {
                        check verifyOrder(inventoryRepository, channelMessage.message);
                    }
                }
            }
    }
}

public function verifyOrder(InventoryRepository inventoryRepository, json orderItems) returns error?{
    json[] orderItemList = <json[]>orderItems;
    boolean isInventoryAvailable = true;
    string orderId;
    foreach json item in orderItemList {
        int quantity = <int> check item.quantity;
        string inventoryItemId = <string> check item.inventoryItemId;
        orderId = <string> check item.orderId;
        int totalItem = check inventoryRepository.getAvailableProductQuantity(inventoryItemId);
        if totalItem < quantity {
            isInventoryAvailable = false;
            break;
        }
    }
    if isInventoryAvailable {
        check inventoryRepository.reserveOrderItems(orderItems);
        ChannelMessage channelMessage = {
            serviceType: "Orchestrator",
            action: "OrderVerified",
            message: orderId
        };
        check sendMessage("ReplyQueue", channelMessage);
        io:println("order verified");
    } else {
        ChannelMessage channelMessage = {
            serviceType: "Orchestrator",
            action: "OrderVerificationFailed",
            message: orderId
        };
        check sendMessage("ReplyQueue", channelMessage);
        io:println("order verification failed");
    }
    // transaction
}

function sendMessage(string queueName, ChannelMessage channelMessage) returns error?{
    rabbitmq:Client newClient = check new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    check newClient->queueDeclare(queueName);
    check newClient->publishMessage({ content: channelMessage.toString().toBytes(), routingKey: queueName });
}
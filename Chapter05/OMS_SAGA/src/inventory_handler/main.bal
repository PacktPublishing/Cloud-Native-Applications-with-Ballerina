import ballerina/io;
import ballerinax/rabbitmq;
import dhanushka/inventory_api;

rabbitmq:Connection connectionInventory = new ({host: "localhost", port: 5672});
const string INVENTORY_SERVICE = "InventoryService";
listener rabbitmq:Listener channelListenerInventory = new (connectionInventory);
@rabbitmq:ServiceConfig {
    queueConfig: {
        queueName: "InventoryQueue"
    }
}

service rabbitmqInventoryConsumer on channelListenerInventory {
    resource function onMessage(rabbitmq:Message message, ChannelMessage response) returns error?{
        inventory_api:InventoryRepository inventoryRepository = check new();
            io:println("Inventory Handler: Message recieved" + response.toString());
            if (response.serviceType == "InventoryService") {
                match response.action {
                    "VerifyOrder" => {
                        check verifyOrder(inventoryRepository, <@untainted> response.message);
                    }
                }
            }
    }
}

public function verifyOrder(inventory_api:InventoryRepository inventoryRepository, json orderItems) returns error?{
    json[] orderItemList = <json[]>orderItems;
    boolean isInventoryAvailable = true;
    string orderId;
    //transaction 
    foreach json item in orderItemList {
        int quantity = <int>item.quantity;
        string inventoryItemId = <string>item.inventoryItemId;
        orderId = <string>item.orderId;
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
    } else {
        ChannelMessage channelMessage = {
            serviceType: "Orchestrator",
            action: "OrderVerificationFailed",
            message: orderId
        };
        check sendMessage("ReplyQueue", channelMessage);
    }
    // transaction
}
public function sendMessage(string queueName, ChannelMessage channelMessage) returns error?{
    rabbitmq:Connection connection = new ({host: "localhost", port: 5672});
    rabbitmq:Channel inventoryChannel = new (connection);
    var queueResult = inventoryChannel->queueDeclare({queueName: queueName});
    if (queueResult is error) {
        io:println("An error occurred while creating the queue.");
    }
    var sendResult = check inventoryChannel->basicPublish(channelMessage, queueName);
}
import ballerina/http;
import ballerinax/rabbitmq;
import ballerina/uuid;
import ballerina/time;

service /OrderAPI  on new http:Listener(9090) { 
    resource function post addNewOrder(http:Caller caller, http:Request req, @http:Payload json orderDetails) returns error? { 
        OrderRepository orderRepository = check new();
        json shippingAddress = check orderDetails.shippingAddress;
        json customerId = check orderDetails.customerId;
        OrderAggregate createdOrder = check createNewOrder(orderRepository, customerId.toString(), shippingAddress.toString(), eventHandler);
        check caller->respond({
            code:200,
            entityId: createdOrder.getEntityId()
        });
    }
    resource function post addProductToOrder(http:Caller caller, http:Request req, @http:Payload json productDetails) returns error? { 
        OrderRepository orderRepository = check new();
        json entityId = check productDetails.entityId;
        json inventoryItemId = check productDetails.inventoryItemId;
        json quantity = check productDetails.quantity;
        OrderAggregate readOrder = check getOrderAggregateByEntityId(orderRepository, entityId.toString());
        string orderItemId = check readOrder.addProductToOrder(inventoryItemId.toString(), <int>quantity, eventHandler);
        check caller->respond({
            code:200,
            orderItemId: orderItemId
        });
    }
    resource function get generateSnapshot/[string toDate](http:Caller caller, http:Request req) returns error? { 
        OrderRepository orderRepository = check new();
        Entity[] entities= check orderRepository.getAllEntities();
        foreach Entity entity in entities {
            Event[] events = check orderRepository.readEventsTo(entity.entityId, toDate);
            OrderAggregate orderAggregate = createEmptyOrderAggregate(orderRepository, entity.entityId);
            if events.length() > 0 {
                foreach Event event in events {
                    check orderAggregate.apply(event);
                }
            }
            OrderDetail orderDetail = {
                orderId: orderAggregate.getOrder().orderId,
                customerId: orderAggregate.getOrder().customerId,
                status: orderAggregate.getOrder().status,
                shippingAddress: orderAggregate.getOrder().shippingAddress,
                orderItems: orderAggregate.getOrderItems()
            };
            string message = orderDetail.toString();
            string snapshotId = uuid:createType1AsString();
            Snapshot snapshot = {
                snapshotId: snapshotId,
                entityType: entity.entityType,
                entityId: entity.entityId,
                entityVersion: entity.entityVersion,
                message: message,
                timestamp: time:utcNow()
            };
            check orderRepository.addSnapshot(snapshot);
            check orderRepository.removeEventTo(entity.entityId, toDate);
        }
        check caller->respond({
            code:200
        });
    }
}

function eventHandler(Event event) returns error?{
    OrderRepository orderRepository = check new();
    json eventData = check event.eventData.fromJsonString();
    ChannelCommandMessage channelCommandMessage = {
        serviceType: "OrderCommand",
        entityId: event.entityId,
        message: eventData
    };
    check sendMessage("OrderCommandQueue", channelCommandMessage); 
}

function sendMessage(string queueName, ChannelCommandMessage channelMessage) returns error?{
    rabbitmq:Client newClient = check new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    check newClient->queueDeclare(queueName);
    check newClient->publishMessage({ content: channelMessage.toString().toBytes(), routingKey: queueName });
}
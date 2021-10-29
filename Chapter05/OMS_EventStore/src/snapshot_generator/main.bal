import ballerina/io;
import ballerina/time;
import ballerina/uuid;
import order_api;

public function main() returns error?{
    io:println("Running snapshot task");
    order_api:OrderRepository orderRepository = check new();
    order_api:Entity[] entities= check orderRepository.getAllEntities();
    foreach order_api:Entity entity in entities {
        time:Utc entityTo = check time:utcFromString("2029-03-28T10:23:42.120Z")
        Event[] events = check orderRepository.readEventsTo(entity.entityId, entityTo);
        OrderAggregate orderAggregate = check createEmptyOrderAggregate(orderRepository, entity.entityId);
        if events.length() > 0 {
            foreach Event event in events {
                check orderAggregate.apply(event);
            }
        }
        order_api:OrderDetail orderDetail = {
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
                timestamp: time:currentTime()
        };
        check orderRepository.addSnapshot(snapshot);
        check orderRepository.removeEventTo(entity.entityId, entityTo);
    }
}

import ballerina/io;
import ballerina/time;
import ballerina/system;
import order_api;

public function main() returns error?{
    io:println("Running snapshot task");
    order_api:OrderRepository orderRepository = check new();
    order_api:Entity[] entities= check orderRepository.getAllEntities();
    foreach order_api:Entity entity in entities {
        time:Time entityTo = check time:createTime(2019, 3, 28, 23, 42, 45, 200, "America/Panama");
        order_api:Event[] events = check orderRepository.readEventsTo(entity.entityId, entityTo);
        order_api:OrderAggregate orderAggregate = check order_api:createEmptyOrderAggregate(orderRepository, entity.entityId);
        if events.length() > 0 {
            foreach order_api:Event event in events {
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
        string snapshotId = system:uuid();
        order_api:Snapshot snapshot = {
                snapshotId: snapshotId,
                entityType: entity.entityType,
                entityId: entity.entityId,
                entityVersion: entity.entityVersion,
                message: message,
                timestamp: time:currentTime()
        };
        check orderRepository.addSnapshot(snapshot);
        check orderRepository.removeEventTo(entity.entityId, entityTo);
        // need transaction handling
    }
}

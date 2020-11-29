import ballerina/io;
import ballerinax/rabbitmq;
import order_api;

rabbitmq:Connection connectionOrder = new ({host: "localhost", port: 5672});

listener rabbitmq:Listener channelListenerOrder = new (connectionOrder);
@rabbitmq:ServiceConfig {
    queueConfig: {
        queueName: "OrderCommandQueue"
    }
}

service rabbitmqOrderConsumer on channelListenerOrder {
    resource function onMessage(rabbitmq:Message message, ChannelCommandMessage command) returns error?{
        io:println("Order Command Handler: Message recieved" + command.toString());
        order_api:OrderRepository orderRepository = check new order_api:OrderRepository();
        match command.serviceType {
            "OrderCommand" => {
                order_api:OrderAggregate orderAggregate = check order_api:getOrderAggregateByEntityId(orderRepository, <@untainted> command.entityId);
                check orderRepository.updateOrder(orderAggregate.getOrder());
                order_api:OrderItem[] orderItems = orderAggregate.getOrderItems();
                if orderItems.length() > 0 {
                    check orderRepository.updateOrderItems(orderAggregate.getOrderItems());
                }
            }
        }
    }
}
import ballerina/io;
import ballerina/uuid;

public class OrderAggregate {
    private Order 'order;
    private OrderItemTable orderItems;
    private OrderRepository orderRepository;

    function init(OrderRepository orderRepository, Order 'order, OrderItemTable orderItems) {
        self.orderRepository = orderRepository;
        self.'order = 'order;
        self.orderItems = orderItems;
    }
    function getOrderShippingAddress() returns string? {
        return self.'order?.shippingAddress;
    }
    function getOrderItems() returns OrderItemTable {
        return self.orderItems;
    }
    function getOrderId() returns string {
        return self.'order.orderId;
    }
    function addProductToOrder(string inventoryItemId, int quantity) returns error|string{
        string? orderId = self.'order?.orderId;
        io:println("data" + inventoryItemId);
        if orderId is string {
            string orderItemId = check self.orderRepository.addOrderItem(orderId, quantity, inventoryItemId);
            OrderItem orderItem = {
                orderItemId: orderItemId,
                orderId: orderId,
                quantity: quantity,
                inventoryItemId: inventoryItemId
            };
            self.orderItems.put(orderItem);
            return orderItemId;
        } else {
            return error("Error while finding the order id");
        }
    }
}

function getOrderAggregateById(OrderRepository orderRepository, string orderId) returns OrderAggregate|error{
    Order 'order =  check orderRepository.getOrderById(orderId);
    OrderItemTable orderItems = check orderRepository.getOrderItemTableByOrderId(orderId);
    return new OrderAggregate(orderRepository, 'order, orderItems);
}

function createOrderAggregate(OrderRepository orderRepository, string customerId, string shippingAddress) returns OrderAggregate|error{
    OrderItemTable orderItems = table[];
    string orderId = uuid:createType1AsString();
    Order 'order = {
        orderId: orderId,
        customerId: customerId,
        status: "Created",
        shippingAddress: shippingAddress
    };
    check orderRepository.createOrder('order);
    return new OrderAggregate(orderRepository, 'order, orderItems);
}

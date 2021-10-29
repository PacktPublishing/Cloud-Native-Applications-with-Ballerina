import ballerina/io;
import ballerina/time;
import ballerina/uuid;

public class OrderAggregate {
    private string entityId;
    private Order 'order;
    private OrderItemTable orderItems;
    private OrderRepository orderRepository;
    private int entityVersion;

    public function init(OrderRepository orderRepository, string entityId, Order 'order, OrderItemTable orderItems) {
        self.orderRepository = orderRepository;
        self.entityId = entityId;
        self.'order = 'order;
        self.orderItems = orderItems;
        self.entityVersion = 1;
    }
    public function getOrderShippingAddress() returns string {
        return self.'order?.shippingAddress;
    }
    public function getOrder() returns Order {
        return self.'order;
    }
    public function getOrderItems() returns OrderItem[] {
        return self.orderItems.toArray();
    }
    public function getOrderId() returns string {
        return self.'order.orderId;
    }
    public function addProductToOrder(string inventoryItemId, int quantity, function (Event) returns error? eventHandler) returns error|string{
        io:println("Add new product to order");
        string orderItemId = uuid:createType1AsString();
        string? orderId = self.'order?.orderId;
        if orderId is string {
            OrderItem orderItem = {
                orderItemId: orderItemId,
                orderId: orderId,
                quantity: quantity,
                inventoryItemId: inventoryItemId
            };
            string eventId = uuid:createType1AsString();
            Event productAddEvent = {
                eventId: eventId,
                eventType: "ProductAdded",
                entityType: "Order",
                entityId: self.entityId,
                eventData: orderItem.toString(),
                timestamp: time:utcNow()
            };
            check self.orderRepository.addEvent(productAddEvent, self.entityVersion);
            self.entityVersion += 1;
            self.orderItems.add(orderItem);
            check eventHandler(productAddEvent);
        } else {
            return error("Error while reading order id");
        }
        return orderItemId;
    }
    public function apply(Event event) returns error?{
        if event.entityType != "Order" {
            return;
        }
        match event.eventType {
            "OrderCreated" => {
                json orderData = check event.eventData.fromJsonString();
                self.'order.orderId = <string> check orderData.orderId;
                self.'order.customerId = <string> check orderData.customerId;
                self.'order.status = <string> check orderData.status;
                self.'order.shippingAddress = <string> check orderData.shippingAddress;
            }
            "ProductAdded" => {
                json orderItemJson = check event.eventData.fromJsonString();
                OrderItem orderItem = check orderItemJson.cloneWithType(OrderItem);
                if self.orderItems.hasKey(orderItem.orderItemId) {
                    OrderItem item = self.orderItems.remove(orderItem.orderItemId);
                }
                self.orderItems.add(orderItem);
            }
            "ProductRemoved" => {
                json orderItemJson = check event.eventData.fromJsonString();
                string orderItemId = <string> check orderItemJson.orderId;
                _ = self.orderItems.remove(orderItemId);                
            }
            "OrderVerified" => {
                self.'order.status = "Verified";
            }
        }
    }
    public function setEntityId(string entityId) {
        self.entityId = entityId;
    }
    public function setEntityVersion(int entityVersion) {
        self.entityVersion = entityVersion;
    }
}

// need to change this with snapshot generator
public function getOrderAggregateByEntityId(OrderRepository orderRepository, string entityId) returns OrderAggregate|error{
    OrderAggregate orderAggregate = createEmptyOrderAggregate(orderRepository, entityId);
    orderAggregate.setEntityVersion(check orderRepository.getEntityVerison(entityId));
    Event[] events = check orderRepository.readEvents(entityId);
    foreach Event event in events {
        check orderAggregate.apply(event);
    }
    return orderAggregate;
}

public function createEmptyOrderAggregate(OrderRepository orderRepository, string entityId) returns OrderAggregate {
    OrderItemTable orderItems = table [];
    Order 'order = {
        orderId: "",
        customerId: "",
        status: "Created",
        shippingAddress: ""
    };
    return new OrderAggregate(orderRepository, entityId, 'order, orderItems);
}

public function createNewOrder(OrderRepository orderRepository, string customerId, string shippingAddress, function (Event) returns error? eventHandler) returns OrderAggregate|error{
    string orderId = uuid:createType1AsString();
    OrderItemTable orderItems = table [];
    Order 'order = {
        orderId: orderId,
        customerId: customerId,
        status: "Created",
        shippingAddress: shippingAddress
    };
    string entityId = uuid:createType1AsString();
    string eventId = uuid:createType1AsString(); 
    OrderAggregate orderAggregate = new OrderAggregate(orderRepository, entityId, 'order, orderItems);
    Event orderCreateEvent = {
        eventId: eventId,
        eventType: "OrderCreated",
        entityType: "Order",
        entityId: entityId,
        eventData: 'order.toString(),
        timestamp: time:utcNow()
    };
    check orderRepository.createEntity(entityId, "Order", orderCreateEvent);
    check eventHandler(orderCreateEvent);
    return orderAggregate;
}
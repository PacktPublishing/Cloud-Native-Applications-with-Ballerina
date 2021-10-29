public type OrderItem record {
    readonly string orderItemId;
    string orderId;
    int quantity;
    string inventoryItemId;
};

public type OrderItemTable table<OrderItem> key(orderItemId);
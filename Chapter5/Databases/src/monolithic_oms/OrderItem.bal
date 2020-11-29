public type OrderItem record {
    readonly string orderItemId;
    string orderId;
    int quantity;
    string inventoryItemId;
};
type OrderItemTable table<OrderItem> key(orderItemId);
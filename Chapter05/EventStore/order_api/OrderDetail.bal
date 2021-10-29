public type OrderDetail record {
    *Order;
    OrderItem[] orderItems;
};
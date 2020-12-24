import ballerina/jdbc;
import ballerina/http;

listener http:Listener orderEP = new(9090);
service OrderService on orderEP {
    resource function checkOrder(http:Caller caller,
        http:Request req, OrderItemTable orderItems) returns error? {
            OrderRepository orderRepository = check new();
            boolean status = check checkValidOrder(orderRepository.getJDBCClient(), <@untainted>orderItems);
            if status {
                check caller->respond("Order verified");
            } else {
                check caller->respond("Order verify failed");
            }

    }
}
public class OrderAggregate {
    private Order 'order;
    private OrderItemTable orderItems;
    private OrderRepository orderRepository;

    function init(OrderRepository orderRepository, Order 'order, OrderItemTable orderItems) {
        self.orderRepository = orderRepository;
        self.'order = 'order;
        self.orderItems = orderItems;
    }
}
function getOrderAggregateById(OrderRepository orderRepository, string orderId) returns OrderAggregate|error{
    Order 'order =  check orderRepository.getOrderById(orderId);
    OrderItemTable orderItems = check orderRepository.getOrderItemTableByOrderId(orderId);
    return new OrderAggregate(orderRepository, 'order, orderItems);
}

function checkValidOrder(jdbc:Client jdbcClient, OrderItemTable orderItems) returns boolean|error{
    foreach OrderItem item in orderItems {
        int orderQuantity = item.quantity;
        int inventoryQuantity = check getAvailableProductQuantity(jdbcClient, item.inventoryItemId);
        if orderQuantity > inventoryQuantity {
            return false;
        }
    }
    return true;
}

function getAvailableProductQuantity(jdbc:Client jdbcClient, string inventoryItemId) returns @untainted int|error {
    stream<record{}, error> resultStream = jdbcClient->query(`SELECT Quantity FROM InventoryItems WHERE 
    InventoryItemId = ${inventoryItemId}`);
    record {|record {} value;|}? result = check resultStream.next();
    if (result is record {|record {} value;|}) {
        return <int>result.value["Quantity"];
    }
    return error("Inventory table is empty");
}
public function intAdd(int a, int b) returns int {
    return (a + b);
}
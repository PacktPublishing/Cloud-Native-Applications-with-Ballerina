// Generate calculator_pb.bal with `bal grpc --input calculator.proto  --output .` command
// Copy calculator_pb.bal file into both grpc_client and grpc_server directories
// Start the server with `bal run grpc_server/` command
// Start the client with `bal run grpc_client/` command
import ballerina/grpc;
import ballerina/io;

listener grpc:Listener grpcListener = new (9090);
@grpc:ServiceDescriptor {
    descriptor: ROOT_DESCRIPTOR,
    descMap: getDescriptorMap()
}
service "OrderCalculate" on grpcListener {
    remote function calculateAsStream(stream<OrderItem, error> itemStream) returns stream<float> {
        io:print("Invoke the chat RPC");
        float[] responses = [];
        float total = 0;
        int i = 0;
        error? e = itemStream.forEach(function(OrderItem value) {
            OrderItem orderItem = <OrderItem> value;
            InventoryItem? inventoryItem = itemList[orderItem.itemId];
            if (inventoryItem is InventoryItem) {
                total += <float>orderItem.quantity * inventoryItem.price;
                responses[i] = total;
                i += 1;
            }
        });
        return responses.toStream();
    }
    remote function calculateOneByOne(OrderItem item) returns float? {
        io:print("Invoked the hello RPC call.");
        InventoryItem? inventoryItem = itemList[item.itemId];
        if (inventoryItem is InventoryItem) {
            return <float>item.quantity * inventoryItem.price;
        }
    }
}

type InventoryItem record {|
    readonly string itemId;
    float price;
|};
type InventoryItemTable table<InventoryItem> key(itemId);
final readonly & InventoryItemTable itemList = table [
    {
        itemId: "item1",
        price: 120
    },{
        itemId: "item2",
        price: 20
    }
];
import ballerinax/awslambda;
import ballerina/io;
@awslambda:Function
public function totalPrice(awslambda:Context ctx, OrderItem item) returns json|error {
   return { "totalRes" : itemList[item.itemId].price * item.quantity};
}
@awslambda:Function
public function setPrice(awslambda:Context ctx, OrderItem item) returns json|error {
   return { "totalRes" : "dfgdf"};
}
@awslambda:Function
public function calculatePrice(awslambda:Context ctx, OrderItem item) returns json|error {
   return { "total" : itemList[item.itemId].price * item.quantity};
}

@awslambda:Function
public function myDetails(awslambda:Context ctx, json item) returns json|error {
   return item;
}

@awslambda:Function
public function apigwRequest(awslambda:Context ctx, 
                             awslambda:APIGatewayProxyRequest request) returns json? {
    io:println("Path: ", request.path);
    return {"body": request.body};
}
public type OrderItem record {|
    string itemId = "";
    int quantity = 0;
|};
type InventoryItem record {|
    readonly string itemId;
    float price;
|};
type InventoryItemTable table<InventoryItem> key(itemId);
InventoryItemTable itemList = table [
    {
        itemId: "item1",
        price: 120
    },{
        itemId: "item2",
        price: 20
    }
];
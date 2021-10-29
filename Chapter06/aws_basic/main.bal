// Build the project with `bal build aws_basic/` command
// Create lambda function with the following AWS command
// `aws lambda create-function --function-name totalPrice --zip-file fileb://aws_basic/target/bin/aws-ballerina-lambda-functions.zip --handler aws_basic.totalPrice --runtime provided --role $LAMBDA_ROLE_ARN --layers arn:aws:lambda:$us-west-1:134633749276:layer:ballerina-jre11:6 --memory-size 512 --timeout 10`
// If lambda function already exist, use the following command to redeploy it
// `aws lambda update-function-code --function-name totalPrice --zip-file fileb://aws_basic/target/bin/aws-ballerina-lambda-functions.zip --region us-west-1`
// Invoke the lambda function with the following command
// `aws lambda invoke --function-name totalPrice --payload '{"itemId": "item1", "quantity": "3"}' response.json --region us-west-1 --cli-binary-format raw-in-base64-out`
// Create API trigger on AWS console
// Invoke with `curl -X GET 'https://xxxxxxxx.execute-api.us-west-1.amazonaws.com/default/totalPrice?itemId=item1&quantity=3'`

import ballerinax/awslambda;
import ballerina/io;
import ballerina/lang.'float as floats;

@awslambda:Function
public function totalPrice(awslambda:Context ctx, json item) returns json|error {
    InventoryItem? inventoryItem = itemList[check item.itemId];
    if (inventoryItem is InventoryItem) {
        return { "totalRes" : inventoryItem.price * check floats:fromString(check item.quantity)};
    } else {
        return error("Error while retrieving table data");
    }
}
@awslambda:Function
public function setPrice(awslambda:Context ctx, OrderItem item) returns json|error {
   return { "totalRes" : "dfgdf"};
}
@awslambda:Function
public function calculatePrice(awslambda:Context ctx, OrderItem item) returns json|error {
    InventoryItem? inventoryItem = itemList[item.itemId];
    if (inventoryItem is InventoryItem) {
        return { "total" : inventoryItem.price * <float>item.quantity};
    } else {
        return error("Error while retrieving table data");
    }
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
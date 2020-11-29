import ballerina/http;
import ballerina/log;
import ballerina/java.jdbc;
import ballerina/io;
import ballerina/observe;

string dbUser = "root";
string dbPassword = "root";
string jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";

service InventoryService on new http:Listener(9091) {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/orderItem/{inventoryItemId}"
    }
    resource function getOrderItem (http:Caller caller, http:Request req, string inventoryItemId) returns error? {
        log:printInfo("Starting verify order items");
        log:printInfo(inventoryItemId);
        jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
        int quantity = check getAvailableProductQuantity(jdbcClient, <@untainted> inventoryItemId);
        http:Response res = new;
        json responseData = {
            inventoryItemId: inventoryItemId,
            quantity: quantity
        };
        res.setPayload(<@untainted> responseData);
        check caller->respond(res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        body: "orderDetails"
    }
    resource function getAmount(http:Caller caller, http:Request req, json orderDetails) returns error? {
        log:printInfo("Calculating order amount");
        jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
        json[] orderJson = <json[]>orderDetails;
        float totalPrice = 0;
        error? result;
        int getAmountSpan = check observe:startSpan("GetAmoutSpan");
        foreach json orderItems in orderJson {
            int orderItemSpan = check observe:startSpan("OrderItemSpan", (),
                                                            getAmountSpan);
            io:println(orderItems.inventoryItemId);
            string inventoryItemId = <@untainted> <string> orderItems.inventoryItemId;
            string orderItemId = <@untainted> <string> orderItems.orderItemId;
            float quantity = <float> orderItems.quantity;
            float fullPrice = check getTotalAmountForItem(jdbcClient, inventoryItemId) * quantity;
            totalPrice += fullPrice;
            log:printInfo("Item id " + inventoryItemId + "fullPrice " + fullPrice.toString());
            check observe:addTagToSpan("Quantity of " + orderItemId, quantity.toString(), orderItemSpan);
            result = observe:finishSpan(orderItemSpan);
            if (result is error) {
                log:printError("Error in finishing span", result);
            }
        }
        check observe:addTagToSpan("Total", totalPrice.toString(), getAmountSpan);
        result = observe:finishSpan(getAmountSpan);
        if (result is error) {
            log:printError("Error in finishing span", result);
        }
        http:Response res = new;
        json responseData = {
            totalPrice: totalPrice
        };
        res.setPayload(<@untainted> responseData);
        check caller->respond(res);
    }
        @http:ResourceConfig {
        methods: ["POST"],
        body: "orderDetails"
    }
    resource function purchaseItems(http:Caller caller, http:Request req, json orderDetails) returns error? {
        log:printInfo("Purchase items order amount");
        http:Response res = new;
        res.setPayload("Done");
        check caller->respond(res);
    }
    
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


public function getTotalAmountForItem(jdbc:Client jdbcClient, string inventoryItemId) returns @untainted float|error {
    stream<record{}, error> resultStream = jdbcClient->query(`SELECT Price FROM OMS_BALLERINA.InventoryItems RIGHT JOIN OMS_BALLERINA.Products
ON InventoryItems.ProductId = Products.ProductId WHERE InventoryItemId = ${inventoryItemId};`);
    record {|record {} value;|}? result = check resultStream.next();
    if (result is record {|record {} value;|}) {
        return <float>result.value["Price"];
    }
    return error("Inventory table is empty");
}

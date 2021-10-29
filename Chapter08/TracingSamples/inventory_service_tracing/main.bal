// Run with `bal run --observability-included inventory_service_tracing/` command

import ballerina/http;
import ballerina/observe;
import ballerina/log;
import ballerinax/jaeger as _;

service /InventoryService on new http:Listener(9091) {
    resource function get orderItem/[string inventoryItemId] (http:Caller caller, http:Request req) returns error? {
        int quantity = check getAvailableProductQuantity(inventoryItemId);
        http:Response res = new;
        json responseData = {
            inventoryItemId: inventoryItemId,
            quantity: quantity
        };
        res.setPayload(<@untainted> responseData);
        check caller->respond(res);
    }
    resource function post getAmount(http:Caller caller, http:Request req,@http:Payload {} json orderDetails) returns error? {
        json[] orderJson = <json[]>orderDetails;
        float totalPrice = 0;
        error? result;
        int getAmountSpan = check observe:startSpan("GetAmoutSpan");
        foreach json orderItems in orderJson {
            int orderItemSpan = check observe:startSpan("OrderItemSpan", (), getAmountSpan);
            string inventoryItemId = <string> check orderItems.inventoryItemId;
            string orderItemId = <string> check orderItems.orderItemId;
            float quantity = <float> check orderItems.quantity;
            float fullPrice = check getTotalAmountForItem(inventoryItemId) * quantity;
            totalPrice += fullPrice;
            log:printInfo("Item id " + inventoryItemId + "fullPrice " + fullPrice.toString());
            check observe:addTagToSpan("Quantity of " + orderItemId, quantity.toString(), orderItemSpan);
            result = observe:finishSpan(orderItemSpan);
            if result is error {
                log:printError("Error in finishing span", result);
            }
        }
        check observe:addTagToSpan("Total", totalPrice.toString(), getAmountSpan);
        result = observe:finishSpan(getAmountSpan);
        if result is error {
            log:printError("Error in finishing span", result);
        }
        http:Response res = new;
        json responseData = {
            totalPrice: totalPrice
        };
        res.setPayload(responseData);
        check caller->respond(res);
    }

    resource function post purchaseItems(http:Caller caller, http:Request req, @http:Payload {} json orderDetails) returns error? {
        log:printInfo("Purchase items order amount");
        http:Response res = new;
        res.setPayload("Done");
        check caller->respond(res);
    }
} 
public function getAvailableProductQuantity(string inventoryItemId) returns int|error {
    return 10;
}
public function getTotalAmountForItem(string inventoryItemId) returns float|error {
    return 100.0;
}
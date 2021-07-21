// Run with `bal run --observability-included notification_service_tracing/` command

import ballerina/http;
import ballerina/log;
import ballerinax/jaeger as _;
service /NotificationService on new http:Listener(9093) {
    resource function get getOrderItem/[string inventoryItemId] (http:Caller caller, http:Request req) returns error? {

    }
    resource function get notifyPayment(http:Caller caller, http:Request req) returns error? {
            log:printInfo("Notifying order");
        check caller->respond("Notified");
    }
    resource function get notifyDelivery(http:Caller caller, http:Request req) returns error? {
            log:printInfo("Notifying delivery");
        check caller->respond("Notified");
    }
}
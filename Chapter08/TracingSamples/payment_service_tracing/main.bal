// Run with `bal run --observability-included payment_service_tracing/` command

import ballerina/http;
import ballerina/log;
import ballerinax/jaeger as _;

http:Client notificationEndpoint = check new ("http://localhost:9093");
service /PaymentService on new http:Listener(9092) {
    resource function get payOrder/[string orderId]/[string amount](http:Caller caller, http:Request req) returns error? {
            log:printInfo("Starting pay order");
        string response = check notificationEndpoint->get(string `/NotificationService/notifyPayment`);
        check caller->respond("Payment Success");
    }
}
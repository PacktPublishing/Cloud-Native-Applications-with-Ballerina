// Run with `bal run --observability-included delivery_service_tracing/` command

import ballerina/http;
import ballerinax/jaeger as _;

http:Client notificationEndpoint = check new ("http://localhost:9093");
service /DelivaryService on new http:Listener(9094) {
resource function get deliverOrder/[string orderId](http:Caller caller, http:Request req) returns error? {
        string response = check notificationEndpoint->get(string `/NotificationService/notifyPayment`);
        check caller->respond("Delivery Success");
    }
} 
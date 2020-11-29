
import ballerina/http;
import ballerina/log;

http:Client notificationEndpoint = new ("http://localhost:9093");
service DelivaryService on new http:Listener(9094) {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/deliverOrder/{orderId}"
    }
    resource function deliverOrder(http:Caller caller, http:Request req, string orderId) returns error? {
        log:printInfo("Starting deliver order");
        var response = notificationEndpoint->get(string `/NotificationService/notifyPayment`);
        check caller->respond("Delivery Success");
    }

}
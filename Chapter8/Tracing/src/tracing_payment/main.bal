
import ballerina/http;
import ballerina/log;

http:Client notificationEndpoint = new ("http://localhost:9093");
service PaymentService on new http:Listener(9092) {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/payOrder/{orderId}/{amount}"
    }
    resource function payOrder(http:Caller caller,
        http:Request req, string orderId, float amount) returns error? {
            log:printInfo("Starting pay order");
        var response = notificationEndpoint->get(string `/NotificationService/notifyPayment`);
        check caller->respond("Payment Success");
    }

}
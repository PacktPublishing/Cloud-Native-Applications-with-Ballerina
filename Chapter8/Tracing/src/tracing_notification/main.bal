
import ballerina/http;
import ballerina/log;

service NotificationService on new http:Listener(9093) {
    resource function notifyPayment(http:Caller caller,
        http:Request req) returns error? {
            log:printInfo("Notifying order");
        check caller->respond("Notified");
    }
    resource function notifyDelivery(http:Caller caller,
        http:Request req) returns error? {
            log:printInfo("Notifying delivery");
        check caller->respond("Notified");
    }

}
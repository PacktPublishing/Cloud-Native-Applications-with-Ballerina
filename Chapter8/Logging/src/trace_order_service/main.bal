import ballerina/http;
http:Client clientEndpoint = new ("https://api.exchangerate-api.com");
service OrderService on new http:Listener(9092) {
    resource function getInventoryData (http:Caller caller, http:Request req) returns error? {
        var response = clientEndpoint->get("/v4/latest/USD");
        if response is http:Response {
            check caller->respond(response);
        } else {
            http:Response errorResponse = new;
            errorResponse.statusCode = 500;
            check caller->respond(errorResponse);
        }
    }
}

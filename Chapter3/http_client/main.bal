// This example to demostrate how to call HTTP backend with Ballerina HTTP client
// Execute this example with `bal run http_client/` command

import ballerina/io;
import ballerina/http;

public function main() returns error?{
    http:Client clientEndpoint = check new ("https://showcase.api.linx.twenty57.net");
    var response = clientEndpoint->get("/UnixTime/tounix?date=now");
    if (response is http:Response) {
        var msg = response.getJsonPayload();
        if (msg is json) {
            io:println("Response is: " + msg.toString());
        } else {
            return error("Invalid payload received:");
        }
    } else {
        return error("Error when calling the backend: ");
    }

    var response2 = clientEndpoint->post("/UnixTime/fromunixtimestamp", {"UnixTimeStamp": "1589772280", "Timezone": ""});
    if (response2 is http:Response) {
        var msg2 = response2.getJsonPayload();
        if (msg2 is json) {
            io:println("Response is: " + msg2.toString());
        } else {
            return error("Invalid payload received:");
        }
    } else {
        return error("Error when calling the backend: ");
    }
}

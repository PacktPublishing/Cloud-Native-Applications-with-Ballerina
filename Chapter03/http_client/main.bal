// This example to demostrate how to call HTTP backend with Ballerina HTTP client
// Execute this example with `bal run http_client/` command

import ballerina/io;
import ballerina/http;

public function main() returns error?{
    
    http:Client clientEndpoint = check new ("http://showcase.api.linx.twenty57.net");
    json msg = check clientEndpoint->get("/UnixTime/tounix?date=now");
    io:println("Response is: " + msg.toString());

    json msg2 = check clientEndpoint->post("/UnixTime/fromunixtimestamp", {"UnixTimeStamp": "1589772280", "Timezone": ""});
    io:println("Response is: " + msg2.toString());

    json msg3 = check clientEndpoint->execute("POST", "/UnixTime/fromunixtimestamp", {"UnixTimeStamp": "1589772280", "Timezone": ""});
    io:println("Response is: " + msg3.toString());
}

// Run this sample with `bal run retry_sample/` command.

import ballerina/io;
import ballerina/http;

public function main() returns error?{
    http:Client backendClientEP =  check new ("http://showcase.api.linx.twenty57.net", { 
    retryConfig: { 
            interval: 3, 
            count: 3, 
            backOffFactor: 2.0, 
            maxWaitInterval: 20
        }, 
        timeout: 20
    }); 
    string response = check backendClientEP->get("/UnixTime/tounix?date=now");
    io:println("Time is " + response);
}

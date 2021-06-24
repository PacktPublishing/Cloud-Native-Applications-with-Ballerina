// This example demostrate circuite braker design pattern
// Execute example with bal run circuite_breaker_sample/

import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client backendClientEP =  check new ("https://showcase.api.linx.twenty57.net", {
            circuitBreaker: {
                rollingWindow: {
                    timeWindow: 10,
                    bucketSize: 2
                },
                failureThreshold: 0.2,
                resetTime: 10,
                statusCodes: [400, 404, 500]
            },
            timeout: 2
        }
    );
    string response = check backendClientEP->get("/UnixTime/tounix?date=now"); 
    io:println("Response is: " + response.toString());   
}
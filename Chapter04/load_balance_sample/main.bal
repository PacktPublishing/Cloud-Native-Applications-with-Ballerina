// This example demostrate load balance between services and handle failover
// Run this sample with `bal run load_balance_sample/` command.
// Invoke service with `curl -X GET http://localhost:9090/loadBalance` command.

import ballerina/http;

listener http:Listener backendEP = new (9091);

service /loadBalance on new http:Listener(9090) {
    resource function get .() returns string|error {
        http:LoadBalanceClient backendClientEP = check new ({
            targets: [ 
                {url: "http://localhost:9091/mock1"}, 
                {url: "http://localhost:9091/mock2"}, 
                {url: "http://localhost:9091/mock3"} 
            ], 
            timeout: 5
        }); 
        string backendResponse = check backendClientEP->get("/");
        return backendResponse;
    }
}

service /mock1 on backendEP {
    resource function get .() returns string {
        return "Response from mock 1";
    }
}
service /mock2 on backendEP {
    resource function get .() returns string {
        return "Response from mock 2";
    }
}
service /mock3 on backendEP {
    resource function get .() returns string {
        return "Response from mock 3";
    }
}
// This is example demostration of how to use remote functions
// Execute the sample with `bal run remote_functions/` command

import ballerina/io;
import ballerina/http;

public function main() returns error?{
    StadardTimeClient standardTimeClient = new();
    string result = check standardTimeClient->getCurrentTime();
    io:println("Currunt time " + result);
}

public client class StadardTimeClient {
    remote function getCurrentTime() returns string|error{
        http:Client clientEndpoint = check new ("http://showcase.api.linx.twenty57.net");
        string msg = check clientEndpoint->get("/UnixTime/tounix?date=now");
        return msg;
    }
}
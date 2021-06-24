import ballerina/io;
import ballerina/http;
public function main() returns error?{
    http:Client backendClientEP =  check new ("http://showcase.api.linx.twenty57.net", { 
        timeout: 2
    }); 
    string response = check backendClientEP->get("/UnixTime/tounix?date=now");
    io:println("Time is " + response);
}

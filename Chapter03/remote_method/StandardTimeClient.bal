import ballerina/http;
public client class StadardTimeClient {
    remote function getCurrentTime() returns string|error{
        http:Client clientEndpoint = check new ("http://showcase.api.linx.twenty57.net");
        string msg = check clientEndpoint->get("/UnixTime/tounix?date=now");
        return msg;
    }
}
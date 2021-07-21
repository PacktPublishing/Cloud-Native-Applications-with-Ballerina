// Start server with https_server project
// Start client with `bal run https_client/`
import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:ClientConfiguration epClientConfig =  {
        secureSocket:{
            cert: "resources/ballerinaServer.crt"
        }
    };
    http:Client securedEP = check new("https://localhost:9093", epClientConfig);
    string response = check securedEP->get("/testHTTPS");
    io:println(response);
}
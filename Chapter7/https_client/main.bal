import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:ClientConfiguration epClientConfig =  {
        secureSocket:{
            cert: "resources2/ballerinaCert.crt"
        }
    };
    http:Client securedEP = check new("https://localhost:9093", epClientConfig);
    string response = check securedEP->get("/testHTTPS");
    io:println(response);
}
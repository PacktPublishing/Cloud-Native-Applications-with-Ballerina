// Run the code with `bal run basic_auth/` command
import ballerina/http;
import ballerina/io;
public function main() returns error? {
    http:Client adminEP = check new("http://localhost:9090",
        auth = {
            username: "delivery",
            password: "delivery"
        }
    );
    string response = check adminEP->get("/oms/deliveryAccess");
    io:println(response);
}
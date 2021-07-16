// Generate OpenAPI yaml file with the following command
// bal openapi -i open_api/main.bal -o open_api/

// Generate Ballerina code from OpenAPI with the following command
// bal openapi -i open_api/resources/open_api.yaml -o open_api/

import ballerina/http;

service /hello on new http:Listener(9090) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello world!"); 
    }
}

// This sample contain a service with samples to read HTTP request
// Execute `bal run simple_http_server/` command to start server
import ballerina/http;
import ballerina/io;
service /hello on new http:Listener(9090) { 
    // curl -X GET http://localhost:9090/hello/sayHello 
    // Response: Hello, World!
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello, World!"); 
    }
    
    // curl -X GET http://localhost:9090/hello
    // Response: Root context of hello service
    resource function get .(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Root context of hello service"); 
    }

    // curl -X GET http://localhost:9090/hello/customer/customer_details
    // Response: Customer details
    resource function get customer/customer_details(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Customer details"); 
    }

    // Passing data to HTTP resources as URL paramters
    // curl -X GET http://localhost:9090/hello/order/3ac327e9a8b9 
    // Response: Order ID: 3ac327e9a8b9 
    resource function get 'order/[string orderId] (http:Caller caller, http:Request req) returns error? {  
        check caller->respond("Order ID: " + orderId);  
    }

    // curl -X GET http://localhost:9090/hello/orderItem/3ac327e9a8b9/order/34b3a342c3 
    // Response: Order item ID: 3ac327e9a8b9 in 34b3a342c3
    resource function get orderItem/[string orderItemId]/'order/[string orderId] (http:Caller caller, http:Request req) returns error? {  
        check caller->respond("Order item ID: " + orderItemId + " in " + orderId);  
    }

    // Passing data to HTTP resources as query paramters
    // curl -X GET 'http://localhost:9090/hello/orderQueryParam?orderId=324c324a2&customerId=433a23324'
    // Response: Order ID: 324c324a2 customer ID: 433a23324
    resource function get orderQueryParam (http:Caller caller, http:Request req) returns error? {
        string? orderId = req.getQueryParamValue("orderId");
        string? customerId = req.getQueryParamValue("customerId");
        if orderId is string && customerId is string{
            check caller->respond("Order ID: " + orderId + " customer ID: " + customerId);
        }  
    }
    
    // Passing structured data to HTTP resources
    // curl -X POST http://localhost:9090/hello/createOrderJson -d '{"hello": "world"}'
    // Response: {"hello":"world"}
    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    resource function post createOrderJson(http:Caller caller, http:Request req, @http:Payload {} json message) returns error? { 
        io:println(message);
        check caller->respond(message); 
    }

    // curl -X POST http://localhost:9090/hello/createOrderXml -H 'content-type: application/xml' -d '<hello>world</hello>'
    // Response: <hello>world</hello>
    @http:ResourceConfig {
        consumes: ["application/xml"]
    }
    resource function post createOrderXml(http:Caller caller, http:Request req, @http:Payload {} xml message) returns error? { 
        io:println(message);
        check caller->respond(message); 
    }

    // curl -X POST http://localhost:9090/hello/createOrderJson -d '{"customerId": "334e3b3b2331", "shippingAddress": "New York"}'
    // Response: {"customerId":"334e3b3b2331", "shippingAddress":"New York"}
    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    resource function post createOrderRecord(http:Caller caller, http:Request req, @http:Payload {} CreateOrder message) returns error? { 
        io:println(message);
        check caller->respond(message); 
    }
} 
type CreateOrder record {|
    string customerId;
    string shippingAddress;
|};
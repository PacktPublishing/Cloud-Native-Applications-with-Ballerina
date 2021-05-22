// This sample contain a service with samples to read HTTP request
// Execute `bal run simple_http_server/` command to start server
import ballerina/http;
import ballerina/io;
service /hello on new http:Listener(9090) { 
    // curl -X GET http://localhost:9090/hello/sayHello 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello, World!"); 
    }
    
    // curl -X GET http://localhost:9090/hello
    resource function get .(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("root context of hello service"); 
    }

    // curl -X GET http://localhost:9090/hello/customer/customer_details
    resource function get customer/customer_details(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("root context of customer details"); 
    }

    // curl -X GET http://localhost:9090/hello/order/3ac327e9a8b9  
    resource function get 'order/[string orderId] (http:Caller caller, http:Request req) returns error? {  
        check caller->respond("Order ID: " + orderId);  
    }

    // curl -X GET http://localhost:9090/hello/orderItem/3ac327e9a8b9/order/34b3a342c3 
    resource function get orderItem/[string orderItemId]/'order/[string orderId] (http:Caller caller, http:Request req) returns error? {  
        check caller->respond("Order item ID: " + orderItemId + " in " + orderId);  
    }

    // curl -X GET 'http://localhost:9090/hello/orderQueryParam?orderId=324c324a2&customerId=433a23324'
    resource function get orderQueryParam (http:Caller caller, http:Request req) returns error? {
        string? orderId = req.getQueryParamValue("orderId");
        string? customerId = req.getQueryParamValue("customerId");
        if orderId is string && customerId is string{
            check caller->respond("Order ID: " + <@untainted>orderId + " customer ID: " + <@untainted>customerId);
        }  
    }
    
    // curl -X POST http://localhost:9090/hello/createOrderJson -d '{"hello": "world"}'
    resource function post createOrderJson(http:Caller caller, http:Request req, @http:Payload {} json message) returns error? { 
        io:println(message);
        check caller->respond(message); 
    }

    // curl -X POST http://localhost:9090/hello/createOrderXml -d '<hello>world</hello>'
    @http:ResourceConfig {
        consumes: ["application/xml"]
    }
    resource function post createOrderXml(http:Caller caller, http:Request req, @http:Payload {} xml message) returns error? { 
        io:println(message);
        check caller->respond(message); 
    }

    // curl -X POST http://localhost:9090/hello/createOrderJson -d '{"customerId": "334e3b3b2331", "shippingAddress": "New York"}'
    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    resource function post createOrderRecord(http:Caller caller, http:Request req, @http:Payload {} CreateOrder message) returns error? { 
        io:println(message);
        check caller->respond(message); 
    }
    
    // The following two resource functions are used to read matrix parameters
    resource function get orderMatrixParam (http:Caller caller, http:Request req) returns error? {
        map<any> pathMParams = req.getMatrixParams("/hello/orderMatrixParam");
        var orderId = <string>pathMParams["orderId"];
        var customerId = <string>pathMParams["customerId"];
        check caller->respond("Order ID: " + <@untainted>orderId + " customer ID: " + <@untainted>customerId);
    }
       
    resource function get orderMatrixParamMiddle/test (http:Caller caller, http:Request req) returns error? {
        map<any> pathMParams = req.getMatrixParams("/hello/orderMatrixParamMiddle");
        var orderId = <string>pathMParams["orderId"];
        var customerId = <string>pathMParams["customerId"];
        map<any> testpathMParams = req.getMatrixParams("/hello/orderMatrixParamMiddle/test");
        var testorderId = <string>testpathMParams["orderId"];
        var testcustomerId = <string>testpathMParams["customerId"];
        check caller->respond("Order ID: " + <@untainted>orderId + " customer ID: " + <@untainted>customerId + "Order ID test: " + <@untainted>testorderId + " customer ID test: " + <@untainted>testcustomerId);
    }

} 
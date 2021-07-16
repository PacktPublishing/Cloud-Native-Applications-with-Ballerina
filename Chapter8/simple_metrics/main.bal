// Start Prometheus
// Build the project with `bal run --observability-included`
// Invoke the endpoint with `curl http://localhost:9092/Customer/getCustomerName`
// Go to http://localhost:9797/metrics 
// Check for requests_total_value on the page
// Go to http://localhost:9090/
// Start grafana dashboard
// Go to http://localhost:3000/login

import ballerina/http;
import ballerinax/prometheus as _;
service /Customer on new http:Listener(9092) { 
    resource function get getCustomerName(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Tom"); 
    }
}
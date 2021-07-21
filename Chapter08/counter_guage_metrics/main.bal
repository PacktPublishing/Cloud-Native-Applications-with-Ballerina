// Start Prometheus
// Build the project with `bal run --observability-included`
// Go to http://localhost:9797/metrics
// Invoke with `curl -X POST http://localhost:9092/Order/createOrder -d {"orderId":"2323223124324234"}`
// Invoke with `curl -X POST http://localhost:9092/Order/addItem -d {"itemId":"2323223124324234"}`
// Invoke with `curl -X DELETE http://localhost:9092/Order/deleteItem -d {"itemId":"2323223124324234"}`
import ballerina/http;
import ballerina/io;
import ballerina/observe;

import ballerinax/prometheus as _;
service /Order on new http:Listener(9092) { 
    resource function post createOrder(http:Caller caller, http:Request req) returns error? { 
        observe:Counter registeredCounter = new ("total_orders",
            desc = "Total number of orders");
        error? result = registeredCounter.register();
        if (result is error) {
            io:println("Error in registering counter", result);
        }
        registeredCounter.increment();
        check caller->respond("Order created");
    }

    resource function post addItem(http:Caller caller, http:Request req) returns error? { 
        observe:Gauge registeredGauge = new ("added_items", "Added items");

        error? result = registeredGauge.register();
        if (result is error) {
            io:println("Error in registering gauge", result);
        }
        registeredGauge.increment();
        check caller->respond("Item added");
    }

    resource function delete deleteItem(http:Caller caller, http:Request req) returns error? {
        observe:Gauge registeredGauge = new ("added_items", "Added items");

        error? result = registeredGauge.register();
        if (result is error) {
            io:println("Error in registering gauge", result);
        }
        registeredGauge.decrement();
        check caller->respond("Item deleted");
    }
 
}

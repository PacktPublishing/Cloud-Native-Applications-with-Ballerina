import ballerina/grpc;
import ballerina/io;

public function main (string... args) returns error? {
    check calculateAsStream();
    check calculateOneByOne();
    //check streamingClient->sendOrderItem(msg);
}
OrderItem[] itemList = [
    {itemId: "item1", quantity: 10},
    {itemId: "item1", quantity: 5},
    {itemId: "item2", quantity: 12}
];
function calculateAsStream() returns error? {
    io:println("Calculate total as stream");
    OrderCalculateClient orderCalculateEP = check new("http://localhost:9090");
    CalculateAsStreamStreamingClient streamingClient = check orderCalculateEP->calculateAsStream();
    foreach OrderItem item in itemList {
        check streamingClient->sendOrderItem(item);
    }
    check streamingClient->complete();
    float|grpc:Error? result = streamingClient->receiveFloat();
    while (result is float) {
        io:println("Current total: ", result);
        result = streamingClient->receiveFloat();
    }
}
function calculateOneByOne() returns error? {
    io:println("Calculate total one by one");
    float total = 0;
    OrderCalculateClient orderCalculateEP = check new("http://localhost:9090");
    foreach OrderItem item in itemList {
        total += check orderCalculateEP->calculateOneByOne(item);
        io:println("Current total: ", total);
    }
}



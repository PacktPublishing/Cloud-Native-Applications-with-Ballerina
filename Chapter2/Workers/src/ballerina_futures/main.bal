import ballerina/io;
import ballerina/runtime;

public function main() returns error? {
    future<string> helloFuture = start printHello();
    io:println("Waiting for result");
    string result = wait helloFuture;
    io:println("Result returned as " + result);
}
function printHello() returns string {
    io:println("Started print hello");
    runtime:sleep(1000);
    io:println("End print hello");
    return "response";
}

import ballerina/io;
import ballerina/runtime;

public function main() returns error? {
    future<string> result1sDelay = start printHello1SecondDelay();
    future<string> result2sDelay = start printHello2SecondDelay();
    string result = wait result1sDelay|result2sDelay;
    //record {string s1; string s2;} result = wait {s1:result1sDelay, s2:result2sDelay};
    io:println(result);
}
function printHello1SecondDelay() returns string {
    runtime:sleep(1000);
    return "From 1s delay";
}
function printHello2SecondDelay() returns string {
    runtime:sleep(2000);
    return "From 2s delay";
}

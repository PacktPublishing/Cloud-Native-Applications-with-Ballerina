import ballerina/io;

public function main() {
    function (int, int) returns int sumFunction = function(int a, int b) returns int {
        return a + b;
    };
    function (int, int) returns int multiplyFunction = function(int a, int b) returns int {
        return a * b;
    };
    io:println(performOperation(sumFunction, 5, 3));
    io:println(performOperation(multiplyFunction, 5, 3));
}
function performOperation(function (int, int) returns int operation, int a, int b) returns int{
    return operation(a, b);
}
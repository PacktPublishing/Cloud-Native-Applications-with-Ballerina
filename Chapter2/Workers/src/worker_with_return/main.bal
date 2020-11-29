import ballerina/io;

public function main() returns error? {
    int a = 5;
    int b = 6;
    worker sum returns int{
        return a + b;
    }
    worker multiply returns int {
        return a * b;
    }
    record {int sum; int multiply;} result = wait {sum, multiply};
    //int result = wait sum|multiply;
    io:println(result);
}
import ballerina/io;
public function main() {
    int a = 35;
    int b = 25;
    if a == b {
        io:println("a equal b");
    } else if a < b {
        io:println("a less than b");
    } else {
        io:println("a larger than b");
    }
}
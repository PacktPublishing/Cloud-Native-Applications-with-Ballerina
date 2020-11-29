import ballerina/io;
import ballerina/time;

# Prints `Hello World`.

public function main() {

}

function getSum(int a, int b) returns int{
    return a + b;
}

function sum(int a, int b) returns int{
    return a + b;
}

function printDay(time:Time date = time:currentTime()) {
    io:println("Time is " + date.toString());
}

function sumABC(int a = 4, int b = 5, int c = 6) returns int {
    return a + b + c;
}

function printUser(string name, int age, string... details) {
    io:println("Name " + details[0]);
    io:println("Age " + age.toString());
    foreach string detail in details {
        io:println(detail);
    }
}

function getUserDetails(string name, int age) returns [string, string]|error {
    string nameDetails = "User's name is " + name;
    string ageDetails = "User's age is " + age.toString();
    return [nameDetails, ageDetails];
}

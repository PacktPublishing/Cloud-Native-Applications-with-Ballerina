import ballerina/io;

public function main() {
    int day = 2;
    match day {
        1 => {
            io:println("Monday");
        }
        2 => {
            io:println("Tuesday");
        }
        3 => {
            io:println("Wednesday");
        }
        4 => {
            io:println("Thursday");
        }
        5 => {
            io:println("Friday");
        }
        6 => {
            io:println("Saturday");
        }
        7 => {
            io:println("Sunday");
        }
    }
}
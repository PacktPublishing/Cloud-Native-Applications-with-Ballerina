// ----Check error expression sample-------
// Run this sample with `bal run check_expression_error/` command

import ballerina/io; 
import ballerina/time; 

public function main() returns error?{ 
    error? result = readTime(); 
    if (result is error) {
        io:println("Error occured while getting time");
    }
} 
public function readTime() returns error? {
    time:Utc decodedTime = check time:utcFromString("2007-12-03T10:15:30.00Z");
    io:println("The parsed time is ", decodedTime); 
}
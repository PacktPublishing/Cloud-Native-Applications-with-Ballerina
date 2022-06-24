// ----Ballerina error handling sample-------
// Run this sample with `bal run error_handling/` command

import ballerina/io; 
import ballerina/time; 

public function main() { 
    time:Utc|error decodedTime = time:utcFromString("2007-12-03T10:15:30.00Z");
    if decodedTime is time:Utc {
        io:println("The parsed time is ", decodedTime); 
    } else { 
        io:println("Error while parsing time", decodedTime); 
    } 
    time:Utc|error decodederrorTime = time:utcFromString("2007-12-l3T10:15:30.00Z");
    if decodederrorTime is time:Utc {
        io:println("The parsed time is ", decodederrorTime); 
    } else { 
        io:println("Error while parsing time", decodederrorTime); 
    } 
}

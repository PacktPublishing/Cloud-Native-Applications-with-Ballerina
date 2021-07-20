import ballerina/io; 
import ballerina/time; 

public function main() { 
    time:Utc|error decodedTime = time:utcFromString("2007-12-03T10:15:30.00Z");
    if decodedTime is time:Utc {
        io:println("The parsed time is ", decodedTime); 
    } else { 
        io:println("Error while parsing time", decodedTime); 
    } 
} 
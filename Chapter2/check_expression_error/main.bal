import ballerina/io; 
import ballerina/time; 

public function main() returns error?{ 
    time:Utc|error decodedTime = time:utcFromString("2007-12-03T10:15:30.00Z");
    io:println("The parsed time is ", decodedTime); 

} 
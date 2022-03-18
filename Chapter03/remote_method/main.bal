// This is example demostration of how to use remote functions
// Execute the sample with `bal run remote_method/` command

// seperate class in to another file
import ballerina/io;

public function main() returns error?{
    StadardTimeClient standardTimeClient = new();
    string result = check standardTimeClient->getCurrentTime();
    io:println("Currunt time " + result);
}
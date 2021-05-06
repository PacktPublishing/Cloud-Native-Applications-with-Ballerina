// This example is to demostrate the command line argument
// passing to the main function. This sample can be run with the 
// following command
// bal run test_main_function/ -- alice 34

import ballerina/io;

public function main(string name, int age) { 
    io:println(name); 
    io:println(age); 
} 
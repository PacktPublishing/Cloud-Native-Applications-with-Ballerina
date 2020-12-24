import ballerina/io;
import ballerina/test;
@test:Config { dependsOn: ["testFunction3"] }
function testFunction1() {
    io:println("This is function 1");
    test:assertTrue(true, msg = "Failed!");
}

@test:Config { dependsOn: ["testFunction1"] }
function testFunction2() {
    io:println("This is function 2");
    test:assertTrue(true, msg = "Failed!");
}

@test:Config { }
function testFunction3() {
    io:println("I'm in test function 3!");
    test:assertTrue(true, msg = "Failed!");
}
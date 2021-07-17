import ballerina/io;
import ballerina/test;
@test:BeforeGroups { value:["GroupA"] }
function beforeGroupB() {
    io:println("Before running GroupA");
}

@test:AfterGroups { value:["GroupA"] }
function afterGroupA() {
    io:println("After running GroupA");
}

@test:Config { groups: ["GroupA"] }
function testFunctionGroupA() {
    io:println("Testing group A");
    test:assertTrue(true, msg = "Failed!");
}
@test:Config { groups: ["GroupB"] }
function testFunctionGroupB() {
    io:println("Testing group B");
    test:assertTrue(true, msg = "Failed!");
}

@test:Config { groups: ["GroupA", "GroupB"] }
function testFunctionGroupAB() {
    io:println("Testing group A and B");
    test:assertTrue(true, msg = "Failed!");
}

@test:Config { }
function ungroupedTestFunction() {
    io:println("I'm the ungrouped test");
    test:assertTrue(true, msg = "Failed!");
}

import ballerina/io;
import ballerina/test;
import ballerina/file;

@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("Coping config files");
    file:Error? copyDirResults = file:copy("/usr/data/conf.toml", "/usr/test/conf.toml", file:REPLACE_EXISTING);
    if copyDirResults is () {
        io:println("bar.txt file is copied to new path ");
    }
}

@test:Config { } 
function testAssertEquals () { 

    test:assertTrue(true, msg = "Failed!"); 

} 


@test:Config { }
function testAssertSum() {
    test:assertEquals(sum(3, 2), 5, msg = "Sum does not equal");
    test:assertNotEquals(sum(3, 2), 6, msg = "Sum is equal");
    test:assertExactEquals(5.0, 5.0, msg = "Sum does not exact equal");
    test:assertNotExactEquals(4, 5.0, msg = "Sum does not exact equal");
    test:assertTrue(true, "Value is false");
    test:assertFalse(false, "Value is true");
    io:println("I'm sadfsafsdfsdion!");

}

# Test function
@test:Config {
    before: beforeFunction,
    after: afterFunction
}
function testFunction() {
    io:println("I'm in test function!");
    test:assertTrue(true, msg = "Failed!");
}
# Before test function
function beforeFunction() {
    io:println("I'm the before function!");
}
# After test function
function afterFunction() {
    io:println("I'm the after function!");
}

# After Suite Function
@test:AfterSuite {}
function afterSuiteFunc() {
    io:println("Removing config files");
    file:Error? removeResults = file:remove("/usr/test/conf.toml");
    if removeResults is () {
        io:println("File removed");
    }
}

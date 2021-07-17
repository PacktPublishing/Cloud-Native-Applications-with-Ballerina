import ballerina/test; 

@test:Config { } 

function testAssertEqualsModuleTest () { 

    test:assertTrue(true, msg = "Failed!"); 

} 
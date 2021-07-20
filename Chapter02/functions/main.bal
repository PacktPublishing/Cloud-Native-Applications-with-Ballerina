import ballerina/io;

public function main() {
    simpleFunctionCall();
    callWithDefaultArguement();
    callWithNamedArguments();
    restParameterSample();
    callWithTuple();
    testFunctionAsVariable();
    testInlineFunctions();
    functionWithExpressionBodies();
    testFunctionAsVariable2();

}

//--- Function with two arguments
function sum(int a, int b) returns int { 
    return a + b; 
} 
function simpleFunctionCall() {
    int result = sum(4,5);
}

//--- Default arguements
function printDatabase(string database = "mysql") { 
  io:println("Selected database is " + database);
} 
function callWithDefaultArguement() {
    printDatabase();
    printDatabase("mongodb");
}

//--- Function call with named argument
function sumABC(int a = 4, int b = 5, int c = 6) returns int { 
    return a + b + c; 
} 
function callWithNamedArguments() {
    int valueSum = sumABC(a = 5, c = 6); 
}

//--- Rest paramters
function printUser(string name, int age, string... details) { 
    io:println("Name " + name); 
    io:println("Age " + age.toString()); 
    foreach string detail in details { 
        io:println(detail); 
    } 
} 
function restParameterSample() {
    printUser("Alice", 24, "Lives in New York", "Drink Coffee"); 
}

//--- Return values with Tuples
function getUserDetails(string name, int age) returns [string, string] { 
    string nameDetails = "User’s name is " + name; 
    string ageDetails = "User’s age is " + age.toString(); 
    return [nameDetails, ageDetails]; 
} 
function callWithTuple() {
    [string, string] [nameDetail, ageDetail] = getUserDetails("Alice", 24); 

    // ignore return value
    _ = getUserDetails("Alice", 24); 
}

//--- Treat function as variable
function getSum(int a, int b) returns int {
    return a + b; 
}
function testFunctionAsVariable() {
    function (int, int) returns int sumFunction = getSum;
    io:println(sumFunction(5, 3)); 
}

function testInlineFunctions() {
    function (int, int) returns int sumFunction = function(int a, int b) returns int { 
        return a + b; 
    }; 
    io:println(sumFunction(5, 3)); 
}

function functionWithExpressionBodies() {
    var sumFunction = function (int a, int b) returns int => a + b;
    io:println(sumFunction(5, 3)); 
}

//--- Test function as variable advanced example

function performOperation(function (int, int) returns int operation, int a, int b) returns int { 
    return operation(a, b); 
} 
function testFunctionAsVariable2() {
    function (int, int) returns int sumFunction = function(int a, int b) returns int {
        return a + b; 
    }; 
    function (int, int) returns int multiplyFunction = function(int a, int b) returns int {
        return a * b; 
    };
    io:println(performOperation(sumFunction, 5, 3));
    io:println(performOperation(multiplyFunction, 5, 3));
}

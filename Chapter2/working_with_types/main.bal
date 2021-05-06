import ballerina/io;

public function main() {
    varType();
    constants();
    enumType();
    letExpressions();
}

//--- Var type
function varType() {
    any value = "This is a string";  
    value = 6;
    io:println("Value is " + value.toString()); 
}

//--- Constants
const float PI = 3.141592;
function constants() {
    float radius = 10;
    float circumference = 2 * PI * radius; 
    io:println("Circuferent is " + circumference.toString());
}

//--- Enum type
enum OrderStates { 
    OrderCreated, 
    OrderVerified, 
    OrderDeliverted, 
    OrderCanceled 
} 
function enumType() {
    string orderStatus = OrderCreated; 
}

//--- Let expression
function letExpressions() {
    int sum = let int a = 5, int b = 6 in a + b; 

    int c = 7; 
    int result = let int a = getFive(), int b = c in a + b;
    io:println("Result of let expression is " + result.toString());
}

function getFive() returns int { 
    return 5; 
} 
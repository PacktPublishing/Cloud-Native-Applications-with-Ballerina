import ballerina/io;

public function main() {
    usingIf();
    usingIf2();
    whileLoop();
    whileLoopWithBreak();
    foreachLoop();
    matchStatement();
}

//--- Using if condition
function usingIf() {
    int a = 35; 
    int b = 25; 
    if a == b {
        io:println("a equal b"); 
    } else if a < b {
        io:println("a less than b"); 
    } else { 
        io:println("a larger than b"); 
    } 
}

//--- Using if condition example 2
function usingIf2() {
    int age = 25; 
    boolean isEmployed = true; 
    if age>18 && isEmployed {
        io:println("Employed adult"); 
    } else if(age>18 && !isEmployed) { 
        io:println("Unemployed adult"); 
    } else { 
        io:println("Not an adult"); 
    } 
}

//--- Using while loop
function whileLoop() {
    int index = 0; 
    while index <= 10 { 
        io:print(index.toString() + " "); 
        index = index + 1; 
    } 
}

//--- Using while loop with break
function whileLoopWithBreak() {
    int index = 0; 
    while true { 
        io:print(index.toString() + " "); 
        if index == 10 { 
            break; 
        } 
        index = index + 1; 
    } 
}

//--- Foreach loop
public type Product record {
    string productName; 
    int quantity; 
    int unitPrice; 
}; 
function foreachLoop() {
    table<Product> products = table [
            {productName: "SD card reader", quantity: 1, unitPrice: 20}, 
            {productName: "USB cable", quantity: 2, unitPrice: 1} 
    ];
    float totalPrice = 0; 
    foreach Product product in products {
        totalPrice =  totalPrice + <float>product.quantity * product.unitPrice; 
    } 
    io:println("Total price is: " + totalPrice.toString()); 
}

// Match statement
function matchStatement() {
    int day = 2; 
    match day { 
        1 => { 
            io:println("Monday"); 
        } 
        2 => { 
            io:println("Tuesday"); 
        } 
        3 => { 
            io:println("Wednesday"); 
        } 
        4 => { 
            io:println("Thursday"); 
        } 
        5 => { 
            io:println("Friday"); 
        } 
        6 => { 
            io:println("Saturday"); 
        } 
        7 => { 
            io:println("Sunday"); 
        } 
    } 
}
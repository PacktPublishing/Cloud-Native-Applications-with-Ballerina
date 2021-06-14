import ballerina/io;

public function main() {
    simpleDataTypes();
    records();
    closedRecords();
    optionalRecords();
    complexRecords();
    tables();
    strings();
    xmlType();
    errorType();
    futureType();
    streamType();
    unionType();
    anyType();
    optionalType();
    byteType();
}

function simpleDataTypes() {
    // nil values
    () nilValue = (); 

    // boleans
    boolean a = true; 
    boolean b = false; 
    boolean aAndb = a && b; // Result is false 
    boolean aOrb = a || b; // Result is true 
    boolean negetion = !a; // Result is false 

    // integer
    int valA = 7; 
    int valB = 5; 
    int aPlusb = valA + valB; // Result is 12 
    int aMinusb = valA - valB; // Result is 2 
    int aMultib = valA * valB; // Result is 35 
    int aDivideb = valA / valB; // Result is 1 
    io:println("Hello World!");

    // float
    float value_float = 2.5; 

    // decimal
    decimal value_decimal = 5.3; 

    // arrays
    int[5] value_array = [2,3,4,5,1];
    io:println(value_array[2]); 

    // Tuple
    [int, string] value_tuple = [3, "Hello"]; 

    // Maps
    map<string> user = {  
        name: "Tom",  
        address: "New York"  
    }; 
    io:println(user["name"]);  // Print name key from the map of users
}

// Records
type User record {   
    string name;   
    int age;   
    boolean married; 
};

function records() {
     // Initialize record
    User userRecord = {
        name: "Tom",  
        age: 21,
        married: false  
    }; 
}

//--- Closed records
type UserClosed record {| 
    string name;    
    int age;    
    boolean married;  
|};

function closedRecords() {
    UserClosed userClosedRecord = {
        name: "Tom",  
        age: 21,
        married: false  
    };
}

//--- Optional records
type UserOptional record { 
    string name;    
    int age?;    
    boolean married;  
};

function optionalRecords() {
        // Initialize optional record
    UserOptional userOptionalRecord = {
        name: "Tom",  
        age: 21,
        married: false  
    };
    // Accessing optional record
    int? age = userOptionalRecord?.age; 
    // If age is initialized, then print the value
    if age is int { 
        io:println("Age is " + age.toString()); 
    } else { 
        io:println("Age is nil"); 
    }
}

//--- Structured records
type UserComplex record {  
    string name;     
    int age;     
    boolean married;  
    Address address;  
};  
type Address record {  
    string lane1;  
    string city;  
    string country;  
    string zipCode;  
};

function complexRecords() {
    // Define and using complex users
    UserComplex userComplex = {    
        name: "Tom",    
        age: 21,    
        married: false,  
        address: {  
            lane1: "Water St.",  
            city: "New York",  
            country: "USA",   
            zipCode: "10001"              
        }  
    }; 
}

//--- Table
type UserRecord record {   
    readonly string name;   
    int age;   
    boolean married; 
}; 

type UserTable table<UserRecord> key(name);

function tables() {
    // User table initialization
    UserTable users = table [ 
        {name: "Tom", age: 25, married: false}, 
        {name: "Alice", age: 23, married: true}, 
        {name: "Bob", age: 34, married: true} 
    ]; 
    io:println("User name", users.get("Tom")); 
}

//--- String
function strings() {
    // Define and accessing string
    string value_string = "Hello"; 
    io:println("First character is " + value_string[0]); 

    // String templates
    string firstName = "Tom";  
    string lastName = "Wilson"; 
    string fullName = string `Mr.${firstName} ${lastName}`; 
    io:println("Concatenated string is " + fullName);
}

//--- XML data type
function xmlType() {
    xml value_xml = xml `<user> 
        <name>Tom</name> 
        <age>45</age> 
        </user>`;
    io:println("XML value is " + value_xml.toString());
}

//--- Error type
function errorType() {
    error value_error = error("Error name"); 
}

//--- Functions
function sum(int a, int b) returns int { 
    return a + b; 
} 

//--- Future type
function futureType() {
    future<int> future_type = start sum(5, 6); 
}

//--- Stream type
function streamType() {
    User[] users = [ 
        {name: "Tom", age: 25, married: false}, 
        {name: "Alice", age: 23, married: true}, 
        {name: "Bob", age: 34, married: true} 
    ];
    stream<User> userStream = users.toStream(); 

    // apply filters on streams
    stream<User> marriedUserStream = 
    userStream.filter(function (User user) returns boolean { 
        return user.married; 
    });
}

//--- Union of types
function unionType() {
    int|string value = "this is a text"; 
    value = 5;
}

//--- Any type
function anyType() {
    any someValue = 5; 
    someValue = "This is a text"; 
}

//--- Optional type
function optionalType() {
    string statement = "this is a text";  
    // int|() index = statement.indexOf("is");
    // Above statement can be written in short hand as follows
    int? index = statement.indexOf("is");  
}

function byteType() {
    byte byteValue= 255;
    byte[] byteValueOfBase64 = base64 `SGVsbG8gV29ybGQ=`;
}

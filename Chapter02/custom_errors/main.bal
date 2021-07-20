import ballerina/io;
import ballerina/regex;
import ballerina/time;

public function main() { 
    Customer customer = { 
        firstName: "Tom", 
        lastName: "Cruise", 
        address: "Syracuse, New York", 
        mobileNumber: "(123)-456-7890", 
        email: "tomcruise@mail.com", 
        birthDay: "1962-07-02" 
    }; 
    
    //--- Check errors with do on fail statement
    do {
        _ = check checkCustomerMobileNumber(customer); 
        _ = check checkCustomerEmail(customer); 
        _ = check checkCustomerBirthday(customer); 
    } on fail UserValidationError e { 
        io:println("Error occurred while validating the customer", e); 
    }

    //--- check errors with series of if condition
    UserValidationError? validationError; 
    validationError = checkCustomerMobileNumber(customer); 
    if validationError is MobileNumberValidationError{ 
        io:println("Error while validating mobile number", validationError); 
        return; 
    } 
    validationError = checkCustomerEmail(customer); 
    if validationError is EmailValidationError{ 
        io:println("Error while validating email address", validationError); 
        return; 
    } 
    validationError = checkCustomerMobileNumber(customer); 
    if validationError is BirthdayValidationError{ 
        io:println("Error while validating birthday", validationError); 
        return; 
    } 
    io:println("Customer validated");
} 
type Customer record { 
    string firstName; 
    string lastName; 
    string address; 
    string mobileNumber; 
    string email; 
    string birthDay; 
}; 
type ErrorDetail record {| 
    error cause?; 
    int code; 
|}; 

type UserValidationError distinct error<ErrorDetail>; 
type MobileNumberValidationError distinct UserValidationError; 
type EmailValidationError distinct UserValidationError; 
type BirthdayValidationError distinct UserValidationError; 

function checkCustomerMobileNumber(Customer customer) returns UserValidationError? { 
    boolean matched = regex:matches(customer.mobileNumber, "^[(]?\\d{3}[)]?[(\\s)?.-]\\d{3}[\\s.-]\\d{4}$"); 
    if !matched {
        return error MobileNumberValidationError("Invalid mobile number", code = 22331); 
    } 
} 
function checkCustomerEmail(Customer customer) returns UserValidationError? { 
    boolean matched = regex:matches(customer.email,"^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$"); 
    if !matched { 
        return error EmailValidationError("Invalid email address", code = 22332); 
    } 
} 
function checkCustomerBirthday(Customer customer) returns UserValidationError? { 
    time:Utc|error birthday = time:utcFromString(customer.birthDay);
        if birthday is error { 
            return error BirthdayValidationError("Invalid birthday format", code = 22333, cause = birthday); 
        }    
} 

import ballerina/stringutils;
import ballerina/time;
import ballerina/io;

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
public function main() {
    Customer customer = {
        firstName: "Tom",
        lastName: "Cruise",
        address: "Syracuse, New York",
        mobileNumber: "(123)-456-7890",
        email: "tomcruise@mail.com",
        birthDay: "1962-07-02"
        
    };
    do {
        _ = check checkCustomerMobileNumber(customer);
        _ = check checkCustomerEmail(customer);
        _ = check checkCustomerBirthday(customer);
    } on fail UserValidationError e {
        io:println("Error occurred while validating the customer", e);
    }
}
function checkCustomerMobileNumber(Customer customer) returns UserValidationError? {
    boolean matched = stringutils:matches(customer.mobileNumber, "^[(]?\\d{3}[)]?[(\\s)?.-]\\d{3}[\\s.-]\\d{4}$");
    if matched {
        return ();
    } else {
        return MobileNumberValidationError("Invalid mobile number", code = 22331);
    }
}
function checkCustomerEmail(Customer customer) returns UserValidationError? {
    boolean matched = stringutils:matches(customer.email, "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$");
    if matched {
        return ();
    } else {
        return EmailValidationError("Invalid email address", code = 22332);
    }
}
function checkCustomerBirthday(Customer customer) returns UserValidationError? {
    time:Time|error birthday = time:parse(customer.birthDay, "yyyy-MM-dd");
        if birthday is error {
            return BirthdayValidationError("Invalid birthday format", code = 22333, cause = birthday);
        } else {
            return ();
        }     
}
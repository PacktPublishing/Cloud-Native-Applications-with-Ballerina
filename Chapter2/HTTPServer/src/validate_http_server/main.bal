import ballerina/http;
import ballerina/stringutils;
type Customer record {
    string firstName;
    string lastName;
    string address;
    string email;
    string mobileNumber;
    string birthDay;

};
service customer on new http:Listener(9090) {
    @http:ResourceConfig {
        methods: ["POST"],
        body: "customer",
        consumes: ["application/json"]
    }
    resource function getCustomerName(http:Caller caller,
        http:Request req, Customer customer) returns error? {
            do {

            } on fail error e{

            }
            check caller->respond("");
    }
}

function checkCustomerEmail(Customer customer) returns error? {
    boolean matched = stringutils:matches("(123)-456-7890", "^[(]?\\d{3}[)]?[(\\s)?.-]\\d{3}[\\s.-]\\d{4}$");
    return error("");
}
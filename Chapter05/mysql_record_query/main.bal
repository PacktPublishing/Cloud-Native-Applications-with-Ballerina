import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
string dbUser = "root";
string dbPassword = "root";
function initializeDB(mysql:Client mysqlClient) returns sql:Error? {
    sql:ExecutionResult result =
        check mysqlClient->execute("CREATE DATABASE IF NOT EXISTS OMS_BALLERINA");
        result = check mysqlClient->execute("CREATE TABLE IF NOT EXISTS " +
        "OMS_BALLERINA.Customers(CustomerId INTEGER NOT NULL AUTO_INCREMENT, " +
        "FirstName  VARCHAR(300), LastName VARCHAR(300), " +
        "ShippingAddress VARCHAR(500), BillingAddress VARCHAR(500), " +
        "Email VARCHAR(300), Country  VARCHAR(300), PRIMARY KEY (CustomerId))");
}
type Customer record {|
    int customerId?;
    string firstName;
    string lastName;
    string shippingAddress;
    string billingAddress;
    string email;
    string country;
|};
function readData(mysql:Client mysqlClient) returns error? {
    stream<record{}, error> resultStream =
        mysqlClient->query("Select * from OMS_BALLERINA.Customers", Customer);
        stream<Customer, sql:Error> customerStream =
        <stream<Customer, sql:Error>>resultStream;
    error? e = customerStream.forEach(function(Customer customer) {
        io:println("Customer first name " + customer.firstName);
        io:println("Customer last name " + customer.lastName);
    });
    if (e is sql:Error) {
        io:println("ForEach operation on the stream failed!", e);
        check mysqlClient.close();
    } else if(e is error) {
        io:println("Error while itterating the stream", e);
    }
}
function insertCustomer(mysql:Client mysqlClient, Customer customer) {
    sql:ParameterizedQuery insertQuery = `INSERT INTO OMS_BALLERINA.Customers(
        FirstName, LastName, ShippingAddress, BillingAddress, Email, Country) 
        VALUES(${customer.firstName}, ${customer.lastName}, 
        ${customer.shippingAddress}, ${customer.billingAddress}, 
        ${customer.email}, ${customer.country})`;
    sql:ExecutionResult|sql:Error result =
                mysqlClient->execute(insertQuery);
    if (result is sql:ExecutionResult) {
        io:println("Inserted Row count: ", result.affectedRowCount);
    } else {
        io:println("Error occurred: ", result);
    }
}
public function main() returns error? {
        sql:ConnectionPool connPool = {
            maxOpenConnections: 5,
            maxConnectionLifeTime: 2000,
            minIdleConnections: 5
        };
        mysql:Client|sql:Error mysqlClient = 
            check new (user = dbUser, password = dbPassword, connectionPool = connPool);
    if (mysqlClient is sql:Error) {
        io:println("Sample data initialization failed!");
        io:println(mysqlClient);
    } else {
        sql:Error? dbError = initializeDB(mysqlClient);
        if dbError is sql:Error {
            check mysqlClient.close();
            io:println("Database execution failure!");
            io:println(dbError);
            return;
        }
        Customer customer = {
            firstName: "Tom",
            lastName: "Wilson",
            shippingAddress: "225, Rose St, New York",
            billingAddress: "13, 13 St New York",
            email: "tom@mail.com",
            country: "USA"
        };
        insertCustomer(mysqlClient, customer);
        check readData(mysqlClient);
        check mysqlClient.close();
        io:println("MySQL Client initialization for querying data successed!");
    }
}
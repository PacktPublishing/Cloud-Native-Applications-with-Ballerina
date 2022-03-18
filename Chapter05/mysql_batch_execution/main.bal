// Set mysql JDBC library location in Ballerina.toml file
// run the sample with `bal run mysql_batch_execution/` command
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
string dbUser = "root";
string dbPassword = "root";
function initializeDB(mysql:Client mysqlClient) returns sql:Error? {
    sql:ExecutionResult result =
        check mysqlClient->execute(`CREATE DATABASE IF NOT EXISTS OMS_BALLERINA`);
        result = check mysqlClient->execute(`CREATE TABLE IF NOT EXISTS OMS_BALLERINA.CustomersTable(CustomerId INTEGER NOT NULL AUTO_INCREMENT, FirstName  VARCHAR(300), LastName VARCHAR(300), ShippingAddress VARCHAR(500), BillingAddress VARCHAR(500), Email VARCHAR(300), Country  VARCHAR(300), PRIMARY KEY (CustomerId))`);
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
    stream<Customer, sql:Error?> customerStream =
        mysqlClient->query(`Select * from OMS_BALLERINA.CustomersTable`, Customer);
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
function insertCustomer(mysql:Client mysqlClient, Customer[] customers) returns error?{
    sql:ParameterizedQuery[] insertQueries = 
        from var customer in customers select `INSERT INTO OMS_BALLERINA.CustomersTable(
        FirstName, LastName, ShippingAddress, BillingAddress, Email, Country) 
        VALUES(${customer.firstName}, ${customer.lastName}, 
        ${customer.shippingAddress}, ${customer.billingAddress}, 
        ${customer.email}, ${customer.country})`;
    sql:ExecutionResult[] result = check mysqlClient->batchExecute(insertQueries);
    foreach var summary in result {
        io:println(summary);
    }
    io:println("Batch execution successful");
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
        // Create array of record
        Customer[] customers = [
            {
                firstName: "Tom", 
                lastName: "Wilson",
                shippingAddress: "New York", 
                billingAddress: "New York",
                email: "tom@mail.com",
                country: "USA"
            },{
                firstName: "Bob",
                lastName: "Ross",
                shippingAddress: "California",
                billingAddress: "California",
                email: "bob@mail.com",
                country: "USA"
            }
        ];
        check insertCustomer(mysqlClient, customers);
        check readData(mysqlClient);
        check mysqlClient.close();
        io:println("MySQL Client initialization for querying data successed!");
    }
}
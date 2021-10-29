// run the sample with `bal run jdbc_h2_sample/` command
import ballerina/io;
import ballerinax/java.jdbc;
import ballerina/sql;
function initializeTable(jdbc:Client jdbcClient) returns sql:Error? {
    sql:ExecutionResult result =
        check jdbcClient->execute("DROP TABLE IF EXISTS Customers");
    result = check jdbcClient->execute("CREATE TABLE IF NOT EXISTS Customers(" + 
        "CustomerId INTEGER NOT NULL AUTO_INCREMENT, " +
        "FirstName  VARCHAR(300), LastName VARCHAR(300), " +
        "ShippingAddress VARCHAR(500), BillingAddress VARCHAR(500), " +
        "Email VARCHAR(300), Country  VARCHAR(300), PRIMARY KEY (CustomerId))");

    result = check jdbcClient->execute("INSERT INTO Customers(" +
        "FirstName, LastName, ShippingAddress, BillingAddress, Email, Country) " +
        "VALUES('Sherlock', 'Holmes', '221b, baker street', '221b, baker street'," +
        " 'sherlock@mail.com', 'UK')");
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
function readData(jdbc:Client jdbcClient) {
    stream<record{}, error> resultStream =
        jdbcClient->query("Select * from Customers", Customer);
    stream<Customer, sql:Error> customerStream =
        <stream<Customer, sql:Error>>resultStream;
    error? e = customerStream.forEach(function(Customer customer) {
        io:println(customer);
    });
}
public function main() returns error? {

    jdbc:Client|sql:Error jdbcClient = new ("jdbc:h2:file:./target/customers",
        "root", "root");
    if (jdbcClient is jdbc:Client) {
        sql:Error? e = initializeTable(jdbcClient);
        if (e is sql:Error) {
            io:println("Customer table initialization failed!", e);
            return e;
        }
        readData(jdbcClient);
        io:println("Queried the database successfully!");
        check jdbcClient.close();
    } else {
        io:println("Initialization failed!!");
        io:println(jdbcClient);
    }

}
// Create new database BALLERINA_TEST in Snowflake
// Create following tables in Snowflake
// CREATE TABLE IF NOT EXISTS Customers(CustomerId INTEGER NOT NULL, FirstName  VARCHAR(300), LastName VARCHAR(300), ShippingAddress VARCHAR(500), BillingAddress VARCHAR(500), Email VARCHAR(300), Country  VARCHAR(300), PRIMARY KEY (CustomerId));
// INSERT INTO Customers(CustomerId, FirstName, LastName, ShippingAddress, BillingAddress, Email, Country) VALUES(1, 'Sherlock', 'Holmes', '221b, baker street', '221b, baker street','sherlock@mail.com', 'UK');
// Run application with `bal run snowflake_jdbc/`

import ballerina/io;
import ballerinax/java.jdbc;
string dbUser = "xxx";
string dbPassword = "xxx";
public function main() returns error? {
        jdbc:Client jdbcClient = check new 
        ("jdbc:snowflake://<snowflake_domain>.snowflakecomputing.com/?db=BALLERINA_TEST", 
        user=dbUser, password = dbPassword);
        stream<record{}, error> resultStream = jdbcClient->query("Select * from Customers");
        error? e = resultStream.forEach(function(record {} result) {
            io:println("Full Customer details: ", result);
        });
        if (e is error) {
            io:println("ForEach operation on the stream failed!");
            io:println(e);
        }
        check jdbcClient.close();
}

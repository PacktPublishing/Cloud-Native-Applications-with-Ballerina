// Set mysql JDBC library location in Ballerina.toml file
// run the sample with `bal run mysql_query/` command
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
string dbUser = "root";
string dbPassword = "root";
function initializeDB(mysql:Client mysqlClient) returns sql:Error? {
    sql:ExecutionResult result =
        check mysqlClient->execute(`CREATE DATABASE IF NOT EXISTS OMS_BALLERINA`);
        result = check mysqlClient->execute(`CREATE TABLE IF NOT EXISTS OMS_BALLERINA.CustomersTable(CustomerId INTEGER NOT NULL AUTO_INCREMENT, FirstName  VARCHAR(300), LastName VARCHAR(300), ShippingAddress VARCHAR(500), BillingAddress VARCHAR(500), Email VARCHAR(300), Country  VARCHAR(300), PRIMARY KEY (CustomerId))`);
        result = check mysqlClient->execute(`INSERT INTO OMS_BALLERINA.CustomersTable(FirstName, LastName, ShippingAddress, BillingAddress, Email, Country) VALUES('Sherlock', 'Holmes', '221b, baker street', '221b, baker street', 'sherlock@mail.com', 'UK')`);
}
function readData(mysql:Client mysqlClient) returns error? {
    stream<record{}, sql:Error?> resultStream =
        mysqlClient->query(`Select * from OMS_BALLERINA.CustomersTable`);
    error? e = resultStream.forEach(function(record {} result) {
        io:println("Customer detials: ", result);
        io:println("Customer first name: ", result["FirstName"]);
        io:println("Customer last name: ", result["LastName"]);
    });
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
        check initializeDB(mysqlClient);
        check readData(mysqlClient);
        check mysqlClient.close();
        io:println("MySQL Client initialization for querying data successed!");
    }
}

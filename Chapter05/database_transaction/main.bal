
import ballerina/io;
import ballerinax/mysql;
import ballerina/sql;

string dbUser = "root";
string dbPassword = "root";

function initializeDB(mysql:Client mysqlClient) returns sql:Error? {
    sql:ExecutionResult result =
        check mysqlClient->execute("CREATE DATABASE IF NOT EXISTS OMS_BALLERINA");
}
public function main() returns error? {
        mysql:Client|sql:Error mysqlClient = 
            check new (user = dbUser, password = dbPassword,  
            host = "localhost", port = 3306);
    if (mysqlClient is sql:Error) {
        io:println("Sample data initialization failed!");
        io:println(mysqlClient);
    } else {
        transaction {
            sql:Error? dbError = check initializeDB(mysqlClient);
            check commit;
        }
        io:println("MySQL Client initialization for querying data successed!");
    }
}
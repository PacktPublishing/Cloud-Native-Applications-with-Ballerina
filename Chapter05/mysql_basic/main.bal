// Set mysql JDBC library location in Ballerina.toml file
// run the sample with `bal run mysql_basic/` command
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
    mysql:Client mysqlClient = check new (user = dbUser, password = dbPassword, host = "localhost", port = 3306);
    sql:Error? dbError = initializeDB(mysqlClient);
    check mysqlClient.close();
    io:println("MySQL Client initialization for querying data successed!");
    
}
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

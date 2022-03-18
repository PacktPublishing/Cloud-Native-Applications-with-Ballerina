// Set mysql JDBC library location in Ballerina.toml file
// run the sample with `bal run mysql_data_types/` command

import ballerina/io;
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;

string dbUser = "root";
string dbPassword = "root";

function initializeDB(mysql:Client mysqlClient) returns sql:Error? {
    _ =
        check mysqlClient->execute(`CREATE DATABASE IF NOT EXISTS OMS_BALLERINA`);
        // Insert time value data
        _ = check mysqlClient->execute(`CREATE TABLE OMS_BALLERINA.DatetimeTable (ID int(11) NOT NULL, Date date DEFAULT NULL, Time time(6) DEFAULT NULL, Datetime datetime DEFAULT NULL,  Timestamp timestamp NULL DEFAULT NULL, PRIMARY KEY (ID) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;`);
        _ = check mysqlClient->execute(`INSERT INTO OMS_BALLERINA.DatetimeTable(ID, Date, Time, Datetime, Timestamp) VALUES(1, CURDATE(), CURRENT_TIME(), now(), now())`);
        // insert blob value data
        _ = check mysqlClient->execute(`CREATE TABLE OMS_BALLERINA.BlobTable(ID INT NOT NULL, BlobValue BLOB NULL, PRIMARY KEY (id)); `);
        _ = check mysqlClient->execute(`INSERT INTO OMS_BALLERINA.BlobTable(id, BlobValue) VALUES (1, b'01101000011001010110110001101100');`);
}
type TimeTable record {| 
    int id; 
    time:Date date; 
    time:TimeOfDay time; 
    time:Utc datetime; 
    time:Utc timestamp; 
|}; 
function readDataTime(mysql:Client mysqlClient) returns error? {
    stream<TimeTable, sql:Error?> timeStream =
        mysqlClient->query(`Select * from OMS_BALLERINA.DatetimeTable`, TimeTable);
    error? e = timeStream.forEach(function(TimeTable timeTable) {
        io:println("Time data " + timeTable.toString());
    });
    if (e is sql:Error) {
        io:println("ForEach operation on the stream failed!", e);
        check mysqlClient.close();
    } else if(e is error) {
        io:println("Error while itterating the stream", e);
    }
}
type BlobTable record {| 
    int id; 
    byte[] blobValue; 
|}; 
function readDataBlob(mysql:Client mysqlClient) returns error? {
    stream<BlobTable, sql:Error?> blobStream=
        mysqlClient->query(`Select * from OMS_BALLERINA.BlobTable`, BlobTable);
    error? e = blobStream.forEach(function(BlobTable blobTable) {
        io:println("Blob data " + blobTable.toString());
    });
    if (e is sql:Error) {
        io:println("ForEach operation on the stream failed!", e);
        check mysqlClient.close();
    } else if(e is error) {
        io:println("Error while itterating the stream", e);
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
        }
        check readDataTime(mysqlClient);
        check readDataBlob(mysqlClient);
        check mysqlClient.close();
        io:println("MySQL Client initialization for querying data successed!");
    }
}

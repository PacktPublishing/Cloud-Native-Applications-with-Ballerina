import ballerina/io;
import ballerina/log;
import ballerina/ftp;

public function main() {
    ftp:ClientEndpointConfig ftpConfig = {
   protocol: ftp:FTP,
    host: "localhost",
    port: 9876,
    secureSocket: {
            basicAuth: {
                username: "admin",
                password: "admin"
            }
    }
    };
    ftp:Client ftpClient = new(ftpConfig);
    io:ReadableByteChannel|error uploadFileChannel = io:openReadableFile("/Users/dhanushka/Desktop/abc.log");
    if uploadFileChannel is io:ReadableByteChannel {
        io:println("error3");
        error? mkdirResponse = ftpClient->rmdir("/tester");
        error? uploadResponse = ftpClient->put("/tester/", uploadFileChannel);
        if uploadResponse is error {
            io:println("error2");
            log:printError("Error while uploading ", err = uploadResponse);
        }
    } else {
        io:println("error");
        log:printError("Error reading byte channel", err = uploadFileChannel);
    }
    io:println("Hello World!kk");
}

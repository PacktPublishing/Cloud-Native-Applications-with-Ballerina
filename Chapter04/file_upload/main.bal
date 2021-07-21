// Change current directory to the project folder
// Run the project with `bal run`
// Go to the http://localhost:9090/file from a browser
// Create a file in a folder
// Select the file and click submit button on the browser
// Check the file in uploaded folder

import ballerina/io;
import ballerina/http;
import ballerina/mime;

service /file on new http:Listener(9090) {
    resource function post upload(http:Caller caller, http:Request request) returns error?{
        var bodyParts = request.getBodyParts();
        if (bodyParts is mime:Entity[]) {
            foreach var part in bodyParts {
                mime:ContentDisposition contentDisposition = part.getContentDisposition();
                if (contentDisposition.name == "fileToUpload") {
                    byte[] fileContent = check part.getByteArray();
                     check io:fileWriteBytes("/Users/dhanushka/Documents/workspace/out/" + contentDisposition.fileName, fileContent);
                }
            }
        }
        check caller->respond("done");
    }
    resource function get .(http:Caller caller,http:Request request) returns error? {
      http:Response response = new;
      response.setFileAsPayload("index.html", contentType = "text/html");
      check caller->respond(response);
    }
}

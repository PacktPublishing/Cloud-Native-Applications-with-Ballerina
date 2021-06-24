// Change current directory to the project folder
// Run the project with `bal run`
// Go to the http://localhost:9090/file from a browser
// Fill details and click submit button

import ballerina/io;
import ballerina/http;
import ballerina/mime;

service /file on new http:Listener(9090) {
    resource function post upload(http:Caller caller, http:Request request) returns @tainted error?{
        var bodyParts = request.getBodyParts();
        if (bodyParts is mime:Entity[]) {
            foreach var part in bodyParts {
                mime:ContentDisposition contentDisposition = part.getContentDisposition();
                if (contentDisposition.name == "fileToUpload") {
                    byte[] fileContent = check part.getByteArray();
                     check io:fileWriteBytes("/Users/dhanushka/Desktop/" + contentDisposition.fileName, fileContent);
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

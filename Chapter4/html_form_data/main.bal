// Change current directory to the project folder
// Run the project with `bal run`
// Go to the http://localhost:9090/form from a browser
// Fill details and click submit button

import ballerina/http;
import ballerina/io;

service /form on new http:Listener(9090) { 
    resource function post .(http:Caller caller, http:Request req) returns error? { 
        map<string> data = check req.getFormParams();
        io:println("Name: " + data.get("name"));
        io:println("Email: " + data.get("email"));
        io:println("Birthday: " + data.get("birthday"));
        io:println("Gender: " + data.get("gender"));
        check caller->respond("Hello " + data.get("name")); 
    }
    resource function get .(http:Caller caller,http:Request request) returns error? {
      http:Response response = new;
      response.setFileAsPayload("index.html", contentType = "text/html");
      check caller->respond(response);
    }
}
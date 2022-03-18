// This sample copy file into the Docker image and serve it as HTML page
// Build the project with `bal build --cloud=docker copy_file_docker/`
// Start the server with `docker run -d -p 9090:9090 dhanushka/copy_file:v0.1.0`
// Go to link http://localhost:9090/hello/page via web browser
import ballerina/http;

service /hello on new http:Listener(9090){
  resource function get page(http:Caller caller,http:Request request) returns error? {
      http:Response response = new;
      response.setFileAsPayload("/home/ballerina/index.html", contentType = "text/html");
      check caller->respond(response);
  }
}
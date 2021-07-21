// Change current directory to the project folder
// Run the project with `bal run`
// Go to the http://localhost:9090/web from a browser

import ballerina/http;
import ballerina/io;
import ballerina/websocket;

map<websocket:Caller> clientConnectionMap = {};
string clientName = "";
const string NAME = "NAME";

@websocket:ServiceConfig {
    subProtocols: ["xml"],
    idleTimeout: 120
}
service /chat on new websocket:Listener(9091) {
   resource function get [string name](http:Request req)
                     returns websocket:Service|websocket:Error {
    clientName = name;
    return service object websocket:Service {
        remote function onOpen(websocket:Caller caller) {
            clientConnectionMap[caller.getConnectionId()] = caller;
            caller.setAttribute(NAME, clientName);
            broadcastMessage(caller.getAttribute(NAME).toString() + " join the conversation");
        }
        remote function onTextMessage(websocket:Caller caller, string text) {
            broadcastMessage(caller.getAttribute(NAME).toString() + ": " + text);
        }
        remote function onClose(websocket:Caller caller, int statusCode, string reason) {
            _ = clientConnectionMap.remove(caller.getConnectionId());
            broadcastMessage(caller.getAttribute(NAME).toString() + " left the conversation");
        }
     };
   }
}
service /web on new http:Listener(9090) {
resource function get .(http:Caller caller,http:Request request) returns error? {
      http:Response response = new;
      response.setFileAsPayload("index.html", contentType = "text/html");
      check caller->respond(response);
    }
}

function broadcastMessage(string message) {
    foreach var con in clientConnectionMap {
        var err = con->writeTextMessage(message);
        if (err is websocket:Error) {
            io:println("Error while sending message:");
        }
    }
}
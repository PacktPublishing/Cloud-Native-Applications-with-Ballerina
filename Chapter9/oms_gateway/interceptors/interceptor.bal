import ballerina/http;
public function interceptRequest (http:Caller outboundEp, http:Request req) {
var foo = req.getQueryParamValue("foo");
if (foo !== "bar") {
    http:Response res = new;
    res.statusCode = 400;
    json message = {"Error": "Invalid path parameter foo"};
    res.setPayload(message);
    var status = outboundEp->respond(res);
   } else {
    req.setPayload("From interceptor");
   }
}

public function interceptResponse (http:Caller outboundEp, http:Response res) {
    var payload = res.getTextPayload();
    if (payload is error) {
        res.statusCode = 500;
        json message = {"Error": "Unable to read the response"};
        res.setPayload(message);
    } else {
        res.setPayload(<@untainted>payload + " interceptor example");
    }
} 

import ballerina/http;
import ballerina/io;
http:Client ep = check new("http://localhost:9090", {
    auth: {
        tokenUrl: "https://localhost:9443/oauth2/token",
        username: "customer",
        password: "customer",
        clientId: "NfFYJG740zelDUlVUY2kCV5fbbca",
        clientSecret: "vnULYoZaC24A1wtS4v9jbvVjXJ4a",
        scopes: ["appscope"],
        clientConfig: {
            secureSocket: {
                cert: {
                    path: "resources/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
        }
    }
});

public function main() returns error?{
    http:Response response = check ep->get("/hello");
    io:println(response.statusCode.toString());
}
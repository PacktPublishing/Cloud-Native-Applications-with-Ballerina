import ballerina/http;
import ballerina/io;
http:Client ep = check new("http://localhost:9090", {
    auth: {
        tokenUrl: "https://localhost:9443/oauth2/token",
        username: "delivery",
        password: "delivery",
        clientId: "nobQxoLIp3BfoG4Anncf82szJnga",
        clientSecret: "wSSdSy_eyfXIISCfJSLeyVz5VlAa",
        scopes: ["add_product"],
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
// Run the project with `bal run passthrough/`
// Access `http://localhost:9090/google` on web browser
import ballerina/http;
service / on new http:Listener(9090) {
    resource function 'default google(http:Request req)
            returns http:Response|http:InternalServerError|error {
        http:Client clientEP = check new ("https://google.com");
        http:Response clientResponse = check clientEP->forward("/", req);
        return clientResponse;
    }
    resource function 'default facebook(http:Request req)
            returns http:Response|http:InternalServerError|error {
        http:Client clientEP = check new ("https://facebook.com");
        http:Response clientResponse = check clientEP->forward("/", req);
        return clientResponse;
    }
}
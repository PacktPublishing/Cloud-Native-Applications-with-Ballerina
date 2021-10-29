// Run project with `bal run mutual_client/`

import ballerina/http;
import ballerina/io;
public function main() returns error? {
    http:ClientConfiguration clientEPConfig = { 
        secureSocket: {
            key: {
                certFile: "resources2/ballerinaClient.crt",
                keyFile: "resources2/ballerinaClient.key"
            },
            cert: "resources2/ballerinaServer.crt",
            protocol: {
                name: http:TLS
            },
            ciphers: ["TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"]

        }
    };
    http:Client securedEP = check new("https://localhost:9093",clientEPConfig);
    string response = check securedEP->get("/testMutualSSL");
    io:println(response);
}
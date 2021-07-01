import ballerina/http;
listener http:Listener securedEP = new(9090);
@http:ServiceConfig {
    auth: [
        {
            jwtValidatorConfig: {
                issuer: "https://localhost:9443/oauth2/token",
                audience: "NfFYJG740zelDUlVUY2kCV5fbbca",
                signatureConfig: {
                    jwksConfig: {
                        url: "https://localhost:9443/oauth2/jwks",
                        clientConfig: {
                            secureSocket: {
                                cert: {
                                    path: "resources/ballerinaTruststore.p12",
                                    password: "ballerina"
                                }
                            }
                        }
                    }
                },
                scopeKey: "authlevel"
            },
            scopes: ["customer"]
        }
    ]
}
service /hello on securedEP {
    resource function get .() returns string {
        return "Hello, World!";
    }
}
import ballerina/http;
listener http:Listener ep = new(9090);
@http:ServiceConfig {
    auth: [
        {
            oauth2IntrospectionConfig: {
                url: "https://localhost:9443/oauth2/introspect",
                tokenTypeHint: "access_token",
                scopeKey: "scope",
                clientConfig: {
                    customHeaders: {"Authorization": "Basic YWRtaW46YWRtaW4="},
                    secureSocket: {
                        cert: {
                            path: "resources/ballerinaTruststore.p12",
                            password: "ballerina"
                        }
                    }
                }
            },
            scopes: ["add_product"]
        }
    ]
}
service /hello on ep {
    resource function get .() returns string {
        return "Hello, World!";
    }
}
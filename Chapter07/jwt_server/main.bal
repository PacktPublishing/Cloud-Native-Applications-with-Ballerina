// Update WSO2 IS deployment.toml with keystore configs
// Start WSO2 IS server
// Add required users and roles in WSO2 IS
// Add new service provider in WSO2 IS
// Add new authLevel claim to the OIDC claim set
// Add new scope appscope
// Update user claims with new authLevel claim
// Set users with apropriate custom claim
// Test the JWT endpoint with following curl command
// curl -u NfFYJG740zelDUlVUY2kCV5fbbca:vnULYoZaC24A1wtS4v9jbvVjXJ4a -k -d "grant_type=password&username=customer&password=customer&scope=appscope" -H "Content-Type:application/x-www-form-urlencoded" https://localhost:9443/oauth2/token 
// Run this sample with `bal run jwt_server/`
// Invoke the service with following curl command
// curl --location --request GET 'http://localhost:9090/hello' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Authorization: Bearer <JWT_token>' 
// Continue with jwt_password sample
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
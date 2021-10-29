// Update WSO2 IS deployment.toml with keystore configs
// Start WSO2 IS server
// Add required users and roles in WSO2 IS
// Add new OAuth2 service provider in WSO2 IS
// Add new role based scope "add_product" to delivery scope
// curl --location --request POST 'https://localhost:9443/api/identity/oauth2/v1.0/scopes' --header 'Authorization: Basic YWRtaW46YWRtaW4=' --header 'Content-Type: application/json' --data-raw '{"name": "add_product", "displayName": "add_product", "description": "add_product", "bindings": ["delivery"]}' 
// Get the token for delivery user with the following command
// curl -u nobQxoLIp3BfoG4Anncf82szJnga:wSSdSy_eyfXIISCfJSLeyVz5VlAa -k -d "grant_type=password&username=delivery&password=delivery&scope=add_product" -H "Content-Type:application/x-www-form-urlencoded" https://localhost:9443/oauth2/token 
// Validate token with the following introspect endpoint curl
// curl -k -u admin:admin -H 'Content-Type: application/x-www-form-urlencoded' -X POST --data 'token=<oauth2_token>' https://localhost:9443/oauth2/introspect 
// Start the service with `bal run auth2_server/`
// Invoke the service with following curl command
// curl --location --request GET 'http://localhost:9090/hello' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Authorization: Bearer <oauth2_token>' 
// Execute the sample in auth2_password
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
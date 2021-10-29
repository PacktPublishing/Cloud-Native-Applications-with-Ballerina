// Update WSO2 IS deployment.toml with keystore configs
// Start WSO2 IS server
// Add required users and roles in WSO2 IS
// Add new service provider in WSO2 IS
// Generate JWT with `curl -u NfFYJG740zelDUlVUY2kCV5fbbca:vnULYoZaC24A1wtS4v9jbvVjXJ4a -k -d "grant_type=password&username=customer&password=customer" -H "Content-Type:application/x-www-form-urlencoded" https://localhost:9443/oauth2/token`
// Run sample code with `bal run jwks_validation/`
import ballerina/io;
import ballerina/jwt;
public function main() returns error?{
    jwt:ValidatorConfig validatorConfig = {
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
        }
    };
    string jwt = "eyJ4NXQiOiJaV1U0WVdVM1lqRTVaamhsT0dRd1pUWmlNak16Tm1ZMllqaGlZMkl6WVRWa09UVm1ZakJtTURBNU1USXhOMkl6T1RjeVkySmpNRGhqTnpJMVpqUTROQSIsImtpZCI6IlpXVTRZV1UzWWpFNVpqaGxPR1F3WlRaaU1qTXpObVkyWWpoaVkySXpZVFZrT1RWbVlqQm1NREE1TVRJeE4ySXpPVGN5WTJKak1EaGpOekkxWmpRNE5BX1JTMjU2IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJjdXN0b21lciIsImF1dCI6IkFQUExJQ0FUSU9OX1VTRVIiLCJhdWQiOiJOZkZZSkc3NDB6ZWxEVWxWVVkya0NWNWZiYmNhIiwibmJmIjoxNjI2NjIyMzkxLCJhenAiOiJOZkZZSkc3NDB6ZWxEVWxWVVkya0NWNWZiYmNhIiwiaXNzIjoiaHR0cHM6XC9cL2xvY2FsaG9zdDo5NDQzXC9vYXV0aDJcL3Rva2VuIiwiZXhwIjoxNjI2NjI1OTkxLCJpYXQiOjE2MjY2MjIzOTEsImp0aSI6IjkxODA5NjFlLWJjNWYtNDQyYy1hMTFhLTNkZjgyYjFlZjJjYiJ9.WEjWe9Wt7vOv-tZsAkRY-rhYT3QW7t5f0zxYHwXEmnneyhfaT_zO6Mgk15hdmnLlOPxFnafXjuo-MJAJDuVqcmKOQtbOHHS3XFNC17fZn_4fGWh13iwkWIeAdB9PGabRIWJRu84Na05XZbbR-n2sLZ5kQyT7wJUZyVi_EfLKaobA9DEUy0xiStNoT2jKgePvXDZH46_PycvkVZXC4TnbpcgOkFPkBgBAQG3Jz-1xQuqbIXzI_D4j32vvPwqaeyD_2j9-FJnFwpz0XHnAOlVhAgtBM1NvfItTreWeVHHNdsxExDwAGhqB6d_I1s3GLc6WfbSC5CY0aKehv36NRR-FKA";
    jwt:Payload|jwt:Error result = jwt:validate(jwt, validatorConfig);
    if (result is jwt:Payload) {
        io:println("Validated JWT Payload: ", result.toString());
    } else {
        io:println("An error occurred while validating the JWT: ",
            result.message());
    }
}
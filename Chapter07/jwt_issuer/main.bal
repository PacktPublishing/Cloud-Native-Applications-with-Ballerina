import ballerina/io;
import ballerina/jwt;
public function main() returns error?{
    jwt:IssuerConfig issuerConfig = {
        username: "admin",
        issuer: "ballerina",
        audience: "aVe3D33DWUseSeisADe33DYsl3",
        keyId: "MzMxM2UxNDUyZDg3MTQ1YjM0MzEzODI0YWI4NDNlZDU1ODQzZWFjMQ==",
        expTime: 3600,
        customClaims: { "foo": "bar" },
        signatureConfig: {
            config: {
                keyStore: {
                    path: "resources/ballerinaKeystore.p12",
                    password: "ballerina"
                },
                keyAlias: "ballerina",
                keyPassword: "ballerina"
            }
        }
    };
    string|jwt:Error jwtToken = jwt:issue(issuerConfig);
    if (jwtToken is string) {
        io:println("Issued JWT: ", jwtToken);
    } else {
        io:println("An error occurred while issuing the JWT: ",
            jwtToken.message());
    }

    jwt:ValidatorConfig jwtValidatorConfig = {
        issuer: "ballerina",
        audience: "aVe3D33DWUseSeisADe33DYsl3",
        clockSkew: 60,
        signatureConfig: {
            trustStoreConfig: {
                certAlias: "ballerina",
                trustStore: {
                    path: "resources/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
        }
    };

    jwt:Payload|jwt:Error result = jwt:validate(check jwtToken,
                                                jwtValidatorConfig);
    if (result is jwt:Payload) {
        io:println("Validated JWT Payload: ", result.toString());
    } else {
        io:println("An error occurred while validating the JWT: ",
            result.message());
    }
}

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
    string jwt = "eyJ4NXQiOiJaV1U0WVdVM1lqRTVaamhsT0dRd1pUWmlNak16Tm1ZMllqaGlZMkl6WVRWa09UVm1ZakJtTURBNU1USXhOMkl6T1RjeVkySmpNRGhqTnpJMVpqUTROQSIsImtpZCI6IlpXVTRZV1UzWWpFNVpqaGxPR1F3WlRaaU1qTXpObVkyWWpoaVkySXpZVFZrT1RWbVlqQm1NREE1TVRJeE4ySXpPVGN5WTJKak1EaGpOekkxWmpRNE5BX1JTMjU2IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJjdXN0b21lciIsImF1dCI6IkFQUExJQ0FUSU9OX1VTRVIiLCJhdWQiOiJOZkZZSkc3NDB6ZWxEVWxWVVkya0NWNWZiYmNhIiwibmJmIjoxNjI1MTM4NzU2LCJhenAiOiJOZkZZSkc3NDB6ZWxEVWxWVVkya0NWNWZiYmNhIiwiaXNzIjoiaHR0cHM6XC9cL2xvY2FsaG9zdDo5NDQzXC9vYXV0aDJcL3Rva2VuIiwiZXhwIjoxNjI1MTQyMzU2LCJpYXQiOjE2MjUxMzg3NTYsImp0aSI6Ijc0NzM1MmIyLTdlZTEtNGQ5Zi05Y2VlLTA4ZWMyZjIzY2M4NCJ9.Pv831AGjm0F3XOOlpemPrPK0byQ6xpJVBM4Lt5frlazmKQ1wNf22oIYELmA5jPPTGvlCelKiABmVGYJSUMkNHVohS-UluZY1HLdx47K_nnBRZ13AqyechPMbXC8M77CPft_d5CoVQ7Ln80PY3bAp7H4TsNeNnSCd14-__4wxr4iKK0m_Otcj3aw8PT1-ny5AquxuPALvgP-0V0a_zm6ZyXDIA1JMy7HtjRzszQ2lyeCv-9rUJjgBWQHyYfjx-XUZiv0V5JFkGkf8L0PnlFEMo4APnIJbqr1Oqzku6WW8A3aUHlOZmr80aFsT5NM1JIurMBvxKGXw_g_2SSMe8UrNcg";
    jwt:Payload|jwt:Error result = jwt:validate(jwt, validatorConfig);
    if (result is jwt:Payload) {
        io:println("Validated JWT Payload: ", result.toString());
    } else {
        io:println("An error occurred while validating the JWT: ",
            result.message());
    }
}